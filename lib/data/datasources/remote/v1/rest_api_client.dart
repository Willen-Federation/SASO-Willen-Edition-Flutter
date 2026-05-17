import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/problem_details.dart';
import '../../../models/barcode_resource_model.dart';
import '../../../models/category_model.dart';
import '../../../models/config_bundle_model.dart';
import '../../../models/feature_flag_model.dart';
import '../../../models/item_draft_model.dart';
import '../../../models/item_model.dart';
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
    _handleErrors(response);
    return ItemModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile QR pairing & tokens (phone-callable subset)
  // ---------------------------------------------------------------------------
  //
  // Pairing-code generation and device-token management live behind the
  // admin session and are *not* callable from a mobile JWT — see
  // docs/api-endpoint-map.md. The phone reaches them via /mypage on web.

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

  // ---------------------------------------------------------------------------
  // Feature flags (operator surface — kept for parity with backend spec)
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
  // Push notification registration
  // ---------------------------------------------------------------------------

  /// Register the device's push notification token with the backend so the
  /// server can deliver pushes to this device. Issue #19.
  ///
  /// Silent-degrades on 404 and 501 — the endpoint may not yet be deployed
  /// against older backends. Any other 4xx/5xx surfaces as an exception.
  Future<void> registerPushToken({
    required String token,
    required String platform,
  }) async {
    final uri = Uri.parse('$serverUrl/api/v1/mobile/devices/push-token');
    final response = await _authenticatedRequest(
      () => _http
          .post(
            uri,
            headers: _headers,
            body: jsonEncode({'token': token, 'platform': platform}),
          )
          .timeout(AppConstants.httpTimeout),
    );
    if (response.statusCode == 404 || response.statusCode == 501) return;
    _handleErrors(response);
  }

  // ---------------------------------------------------------------------------
  // Item-draft upload (replaces the /items/register-with-ai path).
  // ---------------------------------------------------------------------------

  /// Upload an image + optional hints to `POST /api/v1/items/drafts`.
  ///
  /// The server stores an `item_draft` row and enqueues background
  /// enrichment (barcode lookup → AI vision → merge). The HTTP response
  /// returns only the draft id and initial status; the mobile app re-checks
  /// the items list after the worker finishes.
  ///
  /// Field names match the backend's `multipart/form-data` schema —
  /// `item_name`, `jan_code`, `price`, `barcode_hint`, `isbn`, `image`.
  Future<ItemDraftModel> createItemDraftWithAi({
    String? itemName,
    String? janCode,
    String? isbn,
    String? price,
    String? barcodeHint,
    XFile? image,
  }) async {
    final uri = Uri.parse('$serverUrl/api/v1/items/drafts');
    final response = await _authenticatedRequest(() async {
      final request =
          http.MultipartRequest('POST', uri)
            ..headers['Authorization'] = 'Bearer $_accessToken'
            ..headers['Accept'] = 'application/json';

      if (itemName != null && itemName.isNotEmpty) {
        request.fields['item_name'] = itemName;
      }
      if (janCode != null && janCode.isNotEmpty) {
        request.fields['jan_code'] = janCode;
      }
      if (isbn != null && isbn.isNotEmpty) request.fields['isbn'] = isbn;
      if (price != null && price.isNotEmpty) request.fields['price'] = price;
      if (barcodeHint != null && barcodeHint.isNotEmpty) {
        request.fields['barcode_hint'] = barcodeHint;
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
    _handleErrors(response);
    return ItemDraftModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // Full data sync (cursor pagination per OpenAPI spec).
  // ---------------------------------------------------------------------------

  /// Fetch one page of items for offline sync.
  ///
  /// Pass [cursor] = `null` for the first page; pass the value returned in
  /// `next_cursor` for subsequent pages. Returns both the page contents and
  /// the cursor for the next call (or `null` when no more pages remain).
  Future<({List<Map<String, dynamic>> items, int? nextCursor})>
  fetchAllItemsRaw({int? cursor, int limit = 200}) async {
    final params = <String, String>{
      'limit': '$limit',
      if (cursor != null) 'cursor': '$cursor',
    };
    final uri = Uri.parse(
      '$serverUrl/api/v1/items',
    ).replace(queryParameters: params);
    final response = await _authenticatedRequest(
      () => _http.get(uri, headers: _headers).timeout(AppConstants.httpTimeout),
    );
    _handleErrors(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (body['data'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final nextCursor = body['next_cursor'] as int?;
    return (items: data, nextCursor: nextCursor);
  }

  // ---------------------------------------------------------------------------
  // Barcode lookup
  // ---------------------------------------------------------------------------

  /// Look up a barcode string. Returns the linked item id if any, plus any
  /// barcode metadata the server has cached.
  Future<BarcodeResourceModel> lookupBarcode(String code) async {
    final uri = Uri.parse(
      '$serverUrl/api/v1/barcode/${Uri.encodeComponent(code)}',
    );
    final response = await _authenticatedRequest(
      () => _http.get(uri, headers: _headers).timeout(AppConstants.httpTimeout),
    );
    _handleErrors(response);
    return BarcodeResourceModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
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
    Map<String, dynamic>? json;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) json = decoded;
    } catch (_) {
      // Not JSON — fall through to the generic HTTP exception.
    }
    if (json != null) {
      throw ProblemDetails.fromJson(json);
    }
    throw Exception('HTTP ${response.statusCode}');
  }
}
