import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/problem_details.dart';
import '../../../models/ai_analysis_model.dart';
import '../../../models/category_model.dart';
import '../../../models/config_bundle_model.dart';
import '../../../models/device_token_model.dart';
import '../../../models/feature_flag_model.dart';
import '../../../models/item_model.dart';
import '../../../models/mcp_item_model.dart';
import '../../../models/pairing_code_model.dart';
import '../../../models/shelf_model.dart';
import '../../../models/token_pair_model.dart';
import '../saso_api_client.dart';

/// Callback invoked when the access token has been silently refreshed, so the
/// hosting layer (Riverpod) can rebuild dependents with the new token.
typedef TokenRefreshCallback =
    Future<void> Function({
      required String accessToken,
      required String refreshToken,
      required int deviceId,
    });

/// Loads the current refresh token from secure storage, or returns null if
/// no refresh token has been issued yet.
typedef RefreshTokenLoader = Future<String?> Function();

/// Invoked when the refresh token itself is rejected (expired / revoked).
/// Lets the auth layer flip to unauthenticated and surface a login redirect.
typedef RefreshFailureCallback = Future<void> Function();

/// SASO M3 REST API v1 client.
/// Activated when ff_rest_api_v1 = true.
///
/// All endpoints: /api/v1/*
/// Auth: Bearer JWT HS256 (1h expiry) + opaque refresh token (~1yr, rotated)
/// Errors: RFC 7807 Problem Details (SASO-DOMAIN-NNNN)
///
/// Resilience:
/// * Transient network failures and 5xx responses are retried with
///   exponential backoff (1 / 2 / 4 s). Non-idempotent POST/PATCH calls are
///   only retried when an `Idempotency-Key` is provided.
/// * On `401`, the client silently exchanges the stored refresh token for a
///   fresh access token and retries the original request once.
class RestV1ApiClient implements SasoApiClient {
  RestV1ApiClient({
    required this.serverUrl,
    required String jwtToken,
    http.Client? httpClient,
    this.refreshTokenLoader,
    this.onTokenRefreshed,
    this.onRefreshFailed,
  }) : _jwtToken = jwtToken,
       _http = httpClient ?? http.Client();

  final String serverUrl;
  String _jwtToken;

  /// The current bearer access token. Updated in-place when a 401-triggered
  /// refresh succeeds, so downstream callers see the latest value.
  String get jwtToken => _jwtToken;

  final http.Client _http;

  final RefreshTokenLoader? refreshTokenLoader;
  final TokenRefreshCallback? onTokenRefreshed;
  final RefreshFailureCallback? onRefreshFailed;

  static const _retryDelays = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
  ];

  @override
  bool get isMock => false;

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_jwtToken',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ---------------------------------------------------------------------------
  // Existing inventory endpoints
  // ---------------------------------------------------------------------------

  @override
  Future<ItemModel> fetchItem(String itemId) async {
    final response = await _authenticatedRequest(
      () => _http
          .get(Uri.parse('$serverUrl/api/v1/items/$itemId'), headers: _headers)
          .timeout(AppConstants.httpTimeout),
      idempotent: true,
    );
    _handleErrors(response);
    return ItemModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<List<ItemModel>> searchItems({
    String? query,
    String? categoryId,
  }) async {
    final params = <String, String>{
      if (query != null) 'q': query,
      if (categoryId != null) 'category_id': categoryId,
      'limit': '20',
    };
    final uri = Uri.parse(
      '$serverUrl/api/v1/items',
    ).replace(queryParameters: params);
    final response = await _authenticatedRequest(
      () => _http.get(uri, headers: _headers).timeout(AppConstants.httpTimeout),
      idempotent: true,
    );
    _handleErrors(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.cast<Map<String, dynamic>>().map(ItemModel.fromJson).toList();
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final response = await _authenticatedRequest(
      () => _http
          .get(Uri.parse('$serverUrl/api/v1/categories'), headers: _headers)
          .timeout(AppConstants.httpTimeout),
      idempotent: true,
    );
    _handleErrors(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }

  @override
  Future<ShelfModel> fetchShelf(String shelfId) async {
    final response = await _authenticatedRequest(
      () => _http
          .get(
            Uri.parse('$serverUrl/api/v1/storage-locations/$shelfId'),
            headers: _headers,
          )
          .timeout(AppConstants.httpTimeout),
      idempotent: true,
    );
    _handleErrors(response);
    return ShelfModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<List<ItemModel>> fetchItemsByShelf(String shelfId) async {
    final response = await _authenticatedRequest(
      () => _http
          .get(
            Uri.parse('$serverUrl/api/v1/storage-locations/$shelfId/items'),
            headers: _headers,
          )
          .timeout(AppConstants.httpTimeout),
      idempotent: true,
    );
    _handleErrors(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.cast<Map<String, dynamic>>().map(ItemModel.fromJson).toList();
  }

  @override
  Future<ItemModel> createItem(
    Map<String, dynamic> body, {
    String? idempotencyKey,
  }) async {
    final response = await _authenticatedRequest(
      () {
        final headers = {
          ..._headers,
          if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
        };
        return _http
            .post(
              Uri.parse('$serverUrl/api/v1/items'),
              headers: headers,
              body: jsonEncode(body),
            )
            .timeout(AppConstants.httpTimeout);
      },
      idempotent: idempotencyKey != null,
    );
    _handleErrors(response);
    return ItemModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<ItemModel> updateItem(
    String itemId,
    Map<String, dynamic> patch, {
    String? idempotencyKey,
  }) async {
    final response = await _authenticatedRequest(
      () async {
        final headers = {
          ..._headers,
          if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
        };
        final request = http.Request(
          'PATCH',
          Uri.parse('$serverUrl/api/v1/items/$itemId'),
        );
        request.headers.addAll(headers);
        request.body = jsonEncode(patch);
        final streamed = await _http
            .send(request)
            .timeout(AppConstants.httpTimeout);
        return http.Response.fromStream(streamed);
      },
      idempotent: idempotencyKey != null,
    );
    _handleErrors(response);
    return ItemModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile QR pairing & token management
  // ---------------------------------------------------------------------------

  /// Generate a short-lived QR pairing code (10 min).
  Future<PairingCodeModel> createPairingCode() async {
    final response = await _authenticatedRequest(
      () => _http
          .post(
            Uri.parse('$serverUrl/api/v1/mobile/pairing-codes'),
            headers: _headers,
          )
          .timeout(AppConstants.httpTimeout),
      // POST with no body / idempotency key, but server-side this endpoint is
      // safe to retry — the pairing-code generation is itself idempotent.
      idempotent: true,
    );
    _handleErrors(response);
    return PairingCodeModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Exchange a QR pairing token for an access+refresh token pair.
  /// This variant is for authenticated contexts (device already has a token).
  Future<TokenPairModel> connect({
    required String pairingToken,
    required String deviceName,
  }) async {
    final response = await _retry(
      () => _http
          .post(
            Uri.parse('$serverUrl/api/v1/mobile/connect'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'token': pairingToken,
              'deviceName': deviceName,
            }),
          )
          .timeout(AppConstants.httpTimeout),
      // Pairing-token exchange is one-shot on the server — never retry on 5xx
      // because the token may already have been spent.
      idempotent: false,
    );
    _handleErrors(response);
    return TokenPairModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Exchange a QR pairing token for an access+refresh token pair (no Bearer).
  Future<TokenPairModel> connectWithPairingToken({
    required String pairingToken,
    required String deviceName,
  }) async {
    final response = await _retry(
      () => _http
          .post(
            Uri.parse('$serverUrl/api/v1/mobile/connect'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'token': pairingToken,
              'deviceName': deviceName,
            }),
          )
          .timeout(AppConstants.httpTimeout),
      idempotent: false,
    );
    _handleErrors(response);
    return TokenPairModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Rotate the access token using a refresh token.
  /// The old refresh token is invalidated; store the new one.
  Future<TokenPairModel> refreshAccessToken(String refreshToken) async {
    final response = await _retry(
      () => _http
          .post(
            Uri.parse('$serverUrl/api/v1/mobile/token/refresh'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'refresh_token': refreshToken}),
          )
          .timeout(AppConstants.httpTimeout),
      // Refresh rotates the token; retrying after a 5xx is safe — the
      // server returns the same fresh pair until success.
      idempotent: true,
    );
    _handleErrors(response);
    return TokenPairModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Register a push notification token (FCM or SNS) for the current device.
  /// Server upserts on (deviceId, platform). See issue #19.
  Future<void> registerPushToken({
    required String platform,
    required String token,
  }) async {
    final response = await _authenticatedRequest(
      () => _http
          .post(
            Uri.parse('$serverUrl/api/v1/mobile/devices/push-token'),
            headers: _headers,
            body: jsonEncode({'platform': platform, 'token': token}),
          )
          .timeout(AppConstants.httpTimeout),
      // Server-side upsert keyed on (device, platform) — safe to retry.
      idempotent: true,
    );
    _handleErrors(response);
  }

  /// Fetch the offline config bundle — contains server-managed feature flags.
  Future<ConfigBundleModel> fetchConfigBundle() async {
    final response = await _authenticatedRequest(
      () => _http
          .get(Uri.parse('$serverUrl/api/v1/mobile/config'), headers: _headers)
          .timeout(AppConstants.httpTimeout),
      idempotent: true,
    );
    _handleErrors(response);
    return ConfigBundleModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// List all device tokens registered for the current account.
  Future<List<DeviceTokenModel>> fetchDeviceTokens() async {
    final response = await _authenticatedRequest(
      () => _http
          .get(Uri.parse('$serverUrl/api/v1/mobile/tokens'), headers: _headers)
          .timeout(AppConstants.httpTimeout),
      idempotent: true,
    );
    _handleErrors(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(DeviceTokenModel.fromJson)
        .toList();
  }

  /// Revoke a device token by its ID (remote logout for a specific device).
  Future<void> revokeDeviceToken(int tokenId) async {
    final response = await _authenticatedRequest(
      () => _http
          .delete(
            Uri.parse('$serverUrl/api/v1/mobile/tokens/$tokenId'),
            headers: _headers,
          )
          .timeout(AppConstants.httpTimeout),
      idempotent: true,
    );
    _handleErrors(response);
  }

  // ---------------------------------------------------------------------------
  // Feature flags (admin / debug)
  // ---------------------------------------------------------------------------

  /// List all feature flags defined on the server.
  Future<List<FeatureFlagModel>> fetchFeatureFlags() async {
    final response = await _authenticatedRequest(
      () => _http
          .get(Uri.parse('$serverUrl/api/v1/feature-flags'), headers: _headers)
          .timeout(AppConstants.httpTimeout),
      idempotent: true,
    );
    _handleErrors(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data
        .cast<Map<String, dynamic>>()
        .map(FeatureFlagModel.fromJson)
        .toList();
  }

  /// Create a new feature flag.
  Future<FeatureFlagModel> createFeatureFlag(FeatureFlagModel flag) async {
    final response = await _authenticatedRequest(
      () => _http
          .post(
            Uri.parse('$serverUrl/api/v1/feature-flags'),
            headers: _headers,
            body: jsonEncode(flag.toJson()),
          )
          .timeout(AppConstants.httpTimeout),
      idempotent: false,
    );
    _handleErrors(response);
    return FeatureFlagModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Fetch a single feature flag by key.
  Future<FeatureFlagModel> fetchFeatureFlag(String key) async {
    final response = await _authenticatedRequest(
      () => _http
          .get(
            Uri.parse('$serverUrl/api/v1/feature-flags/$key'),
            headers: _headers,
          )
          .timeout(AppConstants.httpTimeout),
      idempotent: true,
    );
    _handleErrors(response);
    return FeatureFlagModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Partially update a feature flag (PATCH).
  Future<FeatureFlagModel> updateFeatureFlag(
    String key,
    Map<String, dynamic> patch,
  ) async {
    final response = await _authenticatedRequest(
      () async {
        final request = http.Request(
          'PATCH',
          Uri.parse('$serverUrl/api/v1/feature-flags/$key'),
        );
        request.headers.addAll(_headers);
        request.body = jsonEncode(patch);
        final streamed = await _http
            .send(request)
            .timeout(AppConstants.httpTimeout);
        return http.Response.fromStream(streamed);
      },
      idempotent: false,
    );
    _handleErrors(response);
    return FeatureFlagModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Delete a feature flag by key.
  Future<void> deleteFeatureFlag(String key) async {
    final response = await _authenticatedRequest(
      () => _http
          .delete(
            Uri.parse('$serverUrl/api/v1/feature-flags/$key'),
            headers: _headers,
          )
          .timeout(AppConstants.httpTimeout),
      idempotent: true,
    );
    _handleErrors(response);
  }

  // ---------------------------------------------------------------------------
  // AI-assisted item registration
  // ---------------------------------------------------------------------------

  Future<McpItemModel> registerItemWithAi({
    String? name,
    String? janCode,
    int? categoryId,
    int price = 0,
    int stock = 0,
    XFile? image,
    String? draftId,
  }) async {
    final uri = Uri.parse('$serverUrl/api/v1/items/register-with-ai');

    Future<http.Response> doSend() async {
      final request =
          http.MultipartRequest('POST', uri)
            ..headers['Authorization'] = 'Bearer $_jwtToken'
            ..headers['Accept'] = 'application/json';

      if (name != null && name.isNotEmpty) request.fields['name'] = name;
      if (janCode != null && janCode.isNotEmpty) {
        request.fields['janCode'] = janCode;
      }
      if (categoryId != null) request.fields['categoryId'] = '$categoryId';
      request.fields['price'] = '$price';
      request.fields['stock'] = '$stock';
      if (draftId != null && draftId.isNotEmpty) {
        request.fields['draftId'] = draftId;
      }

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }

      final streamed = await _http
          .send(request)
          .timeout(AppConstants.httpTimeout);
      return http.Response.fromStream(streamed);
    }

    // Non-idempotent multipart upload — do not retry on transient failures,
    // but still attempt one refresh on 401.
    final response = await _authenticatedRequest(doSend, idempotent: false);
    _handleErrors(response);
    return McpItemModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  Future<AiAnalysisModel> analyzeAndDraftImage({
    XFile? image,
    String? name,
    String? janCode,
    int? categoryId,
    int? price,
  }) async {
    final uri = Uri.parse('$serverUrl/api/v1/images/analyze-and-draft');

    Future<http.Response> doSend() async {
      final request =
          http.MultipartRequest('POST', uri)
            ..headers['Authorization'] = 'Bearer $_jwtToken'
            ..headers['Accept'] = 'application/json';

      if (name != null && name.isNotEmpty) request.fields['name'] = name;
      if (janCode != null && janCode.isNotEmpty) {
        request.fields['janCode'] = janCode;
      }
      if (categoryId != null) request.fields['categoryId'] = '$categoryId';
      if (price != null) request.fields['price'] = '$price';

      if (image != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', image.path),
        );
      }

      final streamed = await _http
          .send(request)
          .timeout(AppConstants.httpTimeout);
      return http.Response.fromStream(streamed);
    }

    final response = await _authenticatedRequest(doSend, idempotent: false);
    _handleErrors(response);
    return AiAnalysisModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // Full data sync
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> fetchAllItemsRaw({
    int page = 1,
    int limit = 200,
  }) async {
    final uri = Uri.parse(
      '$serverUrl/api/v1/items',
    ).replace(queryParameters: {'limit': '$limit', 'page': '$page'});
    final response = await _authenticatedRequest(
      () => _http.get(uri, headers: _headers).timeout(AppConstants.httpTimeout),
      idempotent: true,
    );
    _handleErrors(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>? ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  // ---------------------------------------------------------------------------
  // Meta
  // ---------------------------------------------------------------------------

  Future<bool> checkHealth() async {
    final uri = Uri.parse('$serverUrl/api/v1/health');
    try {
      final response = await _http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(AppConstants.httpTimeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Internal — retry, refresh, error mapping
  // ---------------------------------------------------------------------------

  /// Runs [send] with retry-on-transient-failure semantics, and on `401`
  /// rotates the access token via the refresh endpoint and retries once.
  ///
  /// [idempotent] gates whether 5xx / network-error retries are attempted at
  /// all — non-idempotent writes (POST/PATCH without an Idempotency-Key) are
  /// run exactly once.
  Future<http.Response> _authenticatedRequest(
    Future<http.Response> Function() send, {
    required bool idempotent,
  }) async {
    var response = await _retry(send, idempotent: idempotent);
    if (response.statusCode != 401) return response;

    final refreshed = await _attemptTokenRefresh();
    if (!refreshed) return response;

    return _retry(send, idempotent: idempotent);
  }

  /// Tries to obtain a fresh access token using the stored refresh token.
  /// Returns true on success.
  Future<bool> _attemptTokenRefresh() async {
    final loader = refreshTokenLoader;
    final onRefreshed = onTokenRefreshed;
    if (loader == null || onRefreshed == null) return false;

    final stored = await loader();
    if (stored == null || stored.isEmpty) return false;

    try {
      final pair = await refreshAccessToken(stored);
      _jwtToken = pair.accessToken;
      await onRefreshed(
        accessToken: pair.accessToken,
        refreshToken: pair.refreshToken,
        deviceId: pair.deviceId,
      );
      return true;
    } on ProblemDetails catch (e) {
      // Refresh token revoked / expired → propagate logout signal.
      if (e.status == 401 || e.status == 404) {
        await onRefreshFailed?.call();
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Runs [send] up to four times total (1 initial + 3 retries) with
  /// exponential backoff on transient errors. Returns the final response.
  Future<http.Response> _retry(
    Future<http.Response> Function() send, {
    required bool idempotent,
  }) async {
    for (var attempt = 0; attempt <= _retryDelays.length; attempt++) {
      try {
        final response = await send();
        // Only retry server-side transient failures; 4xx is a client error.
        if (response.statusCode < 500 || !idempotent) return response;
        if (attempt == _retryDelays.length) return response;
      } on TimeoutException {
        if (!idempotent || attempt == _retryDelays.length) rethrow;
      } on SocketException {
        if (!idempotent || attempt == _retryDelays.length) rethrow;
      } on http.ClientException {
        if (!idempotent || attempt == _retryDelays.length) rethrow;
      }
      await Future<void>.delayed(_retryDelays[attempt]);
    }
    throw StateError('unreachable: _retry exhausted without return');
  }

  void _handleErrors(http.Response response) {
    if (response.statusCode < 400) return;
    Map<String, dynamic>? json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('HTTP ${response.statusCode}');
    }
    try {
      throw ProblemDetails.fromJson(json);
    } on ProblemDetails {
      rethrow;
    } catch (_) {
      throw Exception('HTTP ${response.statusCode}');
    }
  }
}

