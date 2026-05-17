import 'dart:convert';

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

/// Callback invoked when an auto-refresh on 401 produces a new token pair.
///
/// The owning Riverpod notifier should persist the rotated pair so that
/// subsequent client rebuilds see the fresh tokens.
typedef OnTokenRefreshed =
    void Function({required String accessToken, required String refreshToken});

/// SASO M3 REST API v1 client.
/// Activated when ff_rest_api_v1 = true.
///
/// All endpoints: /api/v1/*
/// Auth: Bearer JWT HS256 (1h expiry) + opaque refresh token (~1yr, rotated)
/// Errors: RFC 7807 Problem Details (SASO-DOMAIN-NNNN)
///
/// When [refreshToken] is supplied, the client transparently retries any
/// authenticated request once on a 401: it calls `refreshAccessToken`,
/// updates its in-memory access/refresh tokens, notifies [onTokenRefreshed],
/// then re-issues the original request with the fresh access token.
class RestV1ApiClient implements SasoApiClient {
  RestV1ApiClient({
    required this.serverUrl,
    required String jwtToken,
    String? refreshToken,
    OnTokenRefreshed? onTokenRefreshed,
    http.Client? httpClient,
  }) : _accessToken = jwtToken,
       _refreshToken = refreshToken,
       _onTokenRefreshed = onTokenRefreshed,
       _http = httpClient ?? http.Client();

  final String serverUrl;
  String _accessToken;
  String? _refreshToken;
  final OnTokenRefreshed? _onTokenRefreshed;
  final http.Client _http;

  /// Snapshot of the active access token; updated when the client
  /// auto-refreshes after a 401.
  String get jwtToken => _accessToken;

  @override
  bool get isMock => false;

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $_accessToken',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Wrap an HTTP send closure with single-shot 401 → refresh → retry.
  ///
  /// The [send] closure must rebuild the request on each invocation so it
  /// can be safely re-issued after the access token rotates.
  Future<http.Response> _authenticatedRequest(
    Future<http.Response> Function() send,
  ) async {
    final response = await send();
    if (response.statusCode != 401) return response;

    final refresh = _refreshToken;
    if (refresh == null) return response;

    final TokenPairModel pair;
    try {
      pair = await refreshAccessToken(refresh);
    } catch (_) {
      // Refresh failed (revoked / expired / network) — surface the original 401.
      return response;
    }
    _accessToken = pair.accessToken;
    _refreshToken = pair.refreshToken;
    _onTokenRefreshed?.call(
      accessToken: pair.accessToken,
      refreshToken: pair.refreshToken,
    );

    return send();
  }

  // ---------------------------------------------------------------------------
  // Existing inventory endpoints
  // ---------------------------------------------------------------------------

  @override
  Future<ItemModel> fetchItem(String itemId) async {
    final uri = Uri.parse('$serverUrl/api/v1/items/$itemId');
    final response = await _authenticatedRequest(
      () => _http.get(uri, headers: _headers).timeout(AppConstants.httpTimeout),
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
    );
    _handleErrors(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.cast<Map<String, dynamic>>().map(ItemModel.fromJson).toList();
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final uri = Uri.parse('$serverUrl/api/v1/categories');
    final response = await _authenticatedRequest(
      () => _http.get(uri, headers: _headers).timeout(AppConstants.httpTimeout),
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
    final uri = Uri.parse('$serverUrl/api/v1/storage-locations/$shelfId');
    final response = await _authenticatedRequest(
      () => _http.get(uri, headers: _headers).timeout(AppConstants.httpTimeout),
    );
    _handleErrors(response);
    return ShelfModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<List<ItemModel>> fetchItemsByShelf(String shelfId) async {
    final uri = Uri.parse('$serverUrl/api/v1/storage-locations/$shelfId/items');
    final response = await _authenticatedRequest(
      () => _http.get(uri, headers: _headers).timeout(AppConstants.httpTimeout),
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
    final uri = Uri.parse('$serverUrl/api/v1/items');
    final response = await _authenticatedRequest(() {
      final headers = {
        ..._headers,
        if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
      };
      return _http
          .post(uri, headers: headers, body: jsonEncode(body))
          .timeout(AppConstants.httpTimeout);
    });
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
    final uri = Uri.parse('$serverUrl/api/v1/items/$itemId');
    final response = await _authenticatedRequest(() async {
      final headers = {
        ..._headers,
        if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
      };
      final request = http.Request('PATCH', uri);
      request.headers.addAll(headers);
      request.body = jsonEncode(patch);
      final streamed = await _http
          .send(request)
          .timeout(AppConstants.httpTimeout);
      return http.Response.fromStream(streamed);
    });
    final headers = {
      ..._headers,
      if (idempotencyKey != null) 'Idempotency-Key': idempotencyKey,
    };
    final request = http.Request('PATCH', uri);
    request.headers.addAll(headers);
    request.body = jsonEncode(patch);
    final streamed = await _http
        .send(request)
        .timeout(AppConstants.httpTimeout);
    final response = await http.Response.fromStream(streamed);
    _handleErrors(response);
    return ItemModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile QR pairing & token management
  // ---------------------------------------------------------------------------

  /// Generate a short-lived QR pairing code (10 min).
  ///
  /// The returned [PairingCodeModel.qrPayload] is the SASO1: string to encode
  /// as a QR code. [PairingCodeModel.qrDataUri] is a ready-to-display
  /// data URI image (data:image/png;base64,...).
  Future<PairingCodeModel> createPairingCode() async {
    final uri = Uri.parse('$serverUrl/api/v1/mobile/pairing-codes');
    final response = await _authenticatedRequest(
      () =>
          _http.post(uri, headers: _headers).timeout(AppConstants.httpTimeout),
    );
    _handleErrors(response);
    return PairingCodeModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Exchange a QR pairing token for an access+refresh token pair.
  /// [pairingToken] is the raw token from the QR payload (without the SASO1: prefix).
  ///
  /// This variant is for authenticated contexts (device already has a token).
  /// For the initial pairing scan use [connectWithPairingToken] instead.
  Future<TokenPairModel> connect({
    required String pairingToken,
    required String deviceName,
  }) async {
    final uri = Uri.parse('$serverUrl/api/v1/mobile/connect');
    final response = await _http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'token': pairingToken, 'deviceName': deviceName}),
        )
        .timeout(AppConstants.httpTimeout);
    _handleErrors(response);
    return TokenPairModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Exchange a QR pairing token for an access+refresh token pair.
  ///
  /// Use this for the initial pairing scan — no Bearer token is required.
  Future<TokenPairModel> connectWithPairingToken({
    required String pairingToken,
    required String deviceName,
  }) async {
    final uri = Uri.parse('$serverUrl/api/v1/mobile/connect');
    final response = await _http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'token': pairingToken, 'deviceName': deviceName}),
        )
        .timeout(AppConstants.httpTimeout);
    _handleErrors(response);
    return TokenPairModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Rotate the access token using a refresh token.
  /// The old refresh token is invalidated; store the new one.
  Future<TokenPairModel> refreshAccessToken(String refreshToken) async {
    final uri = Uri.parse('$serverUrl/api/v1/mobile/token/refresh');
    final response = await _http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'refresh_token': refreshToken}),
        )
        .timeout(AppConstants.httpTimeout);
    _handleErrors(response);
    return TokenPairModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Fetch the offline config bundle — contains server-managed feature flags.
  Future<ConfigBundleModel> fetchConfigBundle() async {
    final uri = Uri.parse('$serverUrl/api/v1/mobile/config');
    final response = await _authenticatedRequest(
      () => _http.get(uri, headers: _headers).timeout(AppConstants.httpTimeout),
    );
    _handleErrors(response);
    return ConfigBundleModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// List all device tokens registered for the current account.
  Future<List<DeviceTokenModel>> fetchDeviceTokens() async {
    final uri = Uri.parse('$serverUrl/api/v1/mobile/tokens');
    final response = await _authenticatedRequest(
      () => _http.get(uri, headers: _headers).timeout(AppConstants.httpTimeout),
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
    final uri = Uri.parse('$serverUrl/api/v1/mobile/tokens/$tokenId');
    final response = await _authenticatedRequest(
      () => _http
          .delete(uri, headers: _headers)
          .timeout(AppConstants.httpTimeout),
    );
    _handleErrors(response);
  }

  // ---------------------------------------------------------------------------
  // Feature flags (admin / debug)
  // ---------------------------------------------------------------------------

  /// List all feature flags defined on the server.
  Future<List<FeatureFlagModel>> fetchFeatureFlags() async {
    final uri = Uri.parse('$serverUrl/api/v1/feature-flags');
    final response = await _authenticatedRequest(
      () => _http.get(uri, headers: _headers).timeout(AppConstants.httpTimeout),
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
    final uri = Uri.parse('$serverUrl/api/v1/feature-flags');
    final response = await _authenticatedRequest(
      () => _http
          .post(uri, headers: _headers, body: jsonEncode(flag.toJson()))
          .timeout(AppConstants.httpTimeout),
    );
    _handleErrors(response);
    return FeatureFlagModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Fetch a single feature flag by key.
  Future<FeatureFlagModel> fetchFeatureFlag(String key) async {
    final uri = Uri.parse('$serverUrl/api/v1/feature-flags/$key');
    final response = await _authenticatedRequest(
      () => _http.get(uri, headers: _headers).timeout(AppConstants.httpTimeout),
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
    final uri = Uri.parse('$serverUrl/api/v1/feature-flags/$key');
    final response = await _authenticatedRequest(() async {
      final request = http.Request('PATCH', uri);
      request.headers.addAll(_headers);
      request.body = jsonEncode(patch);
      final streamed = await _http
          .send(request)
          .timeout(AppConstants.httpTimeout);
      return http.Response.fromStream(streamed);
    });
    _handleErrors(response);
    return FeatureFlagModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Delete a feature flag by key.
  Future<void> deleteFeatureFlag(String key) async {
    final uri = Uri.parse('$serverUrl/api/v1/feature-flags/$key');
    final response = await _authenticatedRequest(
      () => _http
          .delete(uri, headers: _headers)
          .timeout(AppConstants.httpTimeout),
    );
    _handleErrors(response);
  }

  // ---------------------------------------------------------------------------
  // AI-assisted item registration
  // ---------------------------------------------------------------------------

  /// Register an item with server-side AI completion.
  ///
  /// Sends all available inputs (name, janCode, categoryId, price, stock,
  /// optional image) as multipart/form-data to
  /// POST /api/v1/items/register-with-ai.
  ///
  /// The server fills blank fields using its registered AI provider and
  /// returns the created item.
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
    final http.Response response;
    try {
      response = await _authenticatedRequest(() async {
        final request =
            http.MultipartRequest('POST', uri)
              ..headers['Authorization'] = 'Bearer $_accessToken'
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
      });
    } catch (e) {
      throw Exception('registerItemWithAi network error: $e');
    }
    _handleErrors(response);
    return McpItemModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Send image + partial inputs to the server for AI analysis and draft creation.
  ///
  /// POST /api/v1/images/analyze-and-draft
  /// Returns [AiAnalysisModel] with suggested fields + optional draftId.
  Future<AiAnalysisModel> analyzeAndDraftImage({
    XFile? image,
    String? name,
    String? janCode,
    int? categoryId,
    int? price,
  }) async {
    final uri = Uri.parse('$serverUrl/api/v1/images/analyze-and-draft');
    final http.Response response;
    try {
      response = await _authenticatedRequest(() async {
        final request =
            http.MultipartRequest('POST', uri)
              ..headers['Authorization'] = 'Bearer $_accessToken'
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
      });
    } catch (e) {
      throw Exception('analyzeAndDraftImage network error: $e');
    }
    _handleErrors(response);
    return AiAnalysisModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // Full data sync
  // ---------------------------------------------------------------------------

  /// Fetch all items with pagination for full offline sync.
  /// Returns raw JSON list for storage in the local cache.
  Future<List<Map<String, dynamic>>> fetchAllItemsRaw({
    int page = 1,
    int limit = 200,
  }) async {
    final uri = Uri.parse(
      '$serverUrl/api/v1/items',
    ).replace(queryParameters: {'limit': '$limit', 'page': '$page'});
    final response = await _authenticatedRequest(
      () => _http.get(uri, headers: _headers).timeout(AppConstants.httpTimeout),
    );
    _handleErrors(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>? ?? [];
    return data.cast<Map<String, dynamic>>();
  }

  // ---------------------------------------------------------------------------
  // Meta
  // ---------------------------------------------------------------------------

  /// Lightweight health probe — no auth required.
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
  // Internal
  // ---------------------------------------------------------------------------

  void _handleErrors(http.Response response) {
    if (response.statusCode < 400) return;
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      throw ProblemDetails.fromJson(json);
    } catch (_) {
      throw Exception('HTTP ${response.statusCode}');
    }
  }
}
