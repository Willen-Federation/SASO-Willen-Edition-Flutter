import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/category_model.dart';
import '../../../models/item_model.dart';
import '../../../models/shelf_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/problem_details.dart';
import '../saso_api_client.dart';

/// SASO M3 OpenAPI 3.1 REST API client.
/// Stub — not functional until M3 ships.
/// Activated when ff_rest_api_v1 = true.
///
/// All endpoints: /api/v1/*
/// Auth: Bearer JWT RS256 (15 min expiry)
/// Errors: RFC 7807 Problem Details (SASO-DOMAIN-NNNN)
class RestV1ApiClient implements SasoApiClient {
  RestV1ApiClient({
    required this.serverUrl,
    required this.jwtToken,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String serverUrl;
  final String jwtToken;
  final http.Client _http;

  @override
  bool get isMock => false;

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $jwtToken',
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  @override
  Future<ItemModel> fetchItem(String itemId) async {
    final uri = Uri.parse('$serverUrl/api/v1/items/$itemId');
    final response = await _http
        .get(uri, headers: _headers)
        .timeout(AppConstants.httpTimeout);
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
    final response = await _http
        .get(uri, headers: _headers)
        .timeout(AppConstants.httpTimeout);
    _handleErrors(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.cast<Map<String, dynamic>>().map(ItemModel.fromJson).toList();
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final uri = Uri.parse('$serverUrl/api/v1/categories');
    final response = await _http
        .get(uri, headers: _headers)
        .timeout(AppConstants.httpTimeout);
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
    final uri = Uri.parse('$serverUrl/api/v1/shelves/$shelfId');
    final response = await _http
        .get(uri, headers: _headers)
        .timeout(AppConstants.httpTimeout);
    _handleErrors(response);
    return ShelfModel.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  @override
  Future<List<ItemModel>> fetchItemsByShelf(String shelfId) async {
    final uri = Uri.parse('$serverUrl/api/v1/shelves/$shelfId/items');
    final response = await _http
        .get(uri, headers: _headers)
        .timeout(AppConstants.httpTimeout);
    _handleErrors(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.cast<Map<String, dynamic>>().map(ItemModel.fromJson).toList();
  }

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
