import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/category_model.dart';
import '../../../models/item_model.dart';
import '../../../models/shelf_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../saso_api_client.dart';

/// Adapter for deprecated SASO legacy endpoints.
/// Migration note: Replace with RestV1ApiClient when M3 ships.
///
/// Endpoint map:
///   fetchItem       → GET  /item/start?id={id}
///   searchItems     → GET  /item/start (HTML search)
///   fetchCategories → GET  /category/list.json
///   fetchShelf      → GET  /shelf/outputPdf (metadata parse)
class LegacyApiClient implements SasoApiClient {
  LegacyApiClient({
    required this.serverUrl,
    required this.sessionCookie,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String serverUrl;
  final String? sessionCookie;
  final http.Client _http;

  @override
  bool get isMock => false;

  Map<String, String> get _headers => {
    'Accept': 'application/json, text/html',
    if (sessionCookie != null) 'Cookie': sessionCookie!,
  };

  @override
  Future<ItemModel> fetchItem(String itemId) async {
    final uri = Uri.parse(
      '$serverUrl/item/start',
    ).replace(queryParameters: {'id': itemId});
    final response = await _http
        .get(uri, headers: _headers)
        .timeout(AppConstants.httpTimeout);
    _assertOk(response);

    final json = _extractJson(response.body);
    if (json == null) {
      throw const FormatException('Could not extract item JSON from response');
    }
    return ItemModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<List<ItemModel>> searchItems({
    String? query,
    String? categoryId,
  }) async {
    final params = <String, String>{
      if (query != null) 'q': query,
      if (categoryId != null) 'category': categoryId,
    };
    final uri = Uri.parse(
      '$serverUrl/item/start',
    ).replace(queryParameters: params.isEmpty ? null : params);
    final response = await _http
        .get(uri, headers: _headers)
        .timeout(AppConstants.httpTimeout);
    _assertOk(response);

    final json = _extractJson(response.body);
    if (json is List) {
      return json.cast<Map<String, dynamic>>().map(ItemModel.fromJson).toList();
    }
    return [];
  }

  @override
  Future<List<CategoryModel>> fetchCategories() async {
    final uri = Uri.parse('$serverUrl/category/list.json');
    final response = await _http
        .get(uri, headers: _headers)
        .timeout(AppConstants.httpTimeout);
    _assertOk(response);

    final body = jsonDecode(response.body);
    if (body is List) {
      return body
          .cast<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();
    }
    return [];
  }

  @override
  Future<ShelfModel> fetchShelf(String shelfId) async {
    final uri = Uri.parse(
      '$serverUrl/shelf/outputPdf',
    ).replace(queryParameters: {'id': shelfId});
    final response = await _http
        .get(uri, headers: _headers)
        .timeout(AppConstants.httpTimeout);
    _assertOk(response);

    final json = _extractJson(response.body);
    if (json is Map<String, dynamic>) {
      return ShelfModel.fromJson(json);
    }
    return ShelfModel(id: shelfId);
  }

  @override
  Future<List<ItemModel>> fetchItemsByShelf(String shelfId) async {
    final shelf = await fetchShelf(shelfId);
    if (shelf.itemIds.isEmpty) return [];
    return Future.wait(shelf.itemIds.map(fetchItem));
  }

  void _assertOk(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  /// Extract embedded JSON from SASO legacy HTML pages.
  static dynamic _extractJson(String body) {
    if (body.trimLeft().startsWith('{') || body.trimLeft().startsWith('[')) {
      return jsonDecode(body);
    }
    // SASO embeds JSON as var data = {...}; in HTML
    final match = RegExp(
      r'var\s+data\s*=\s*(\{.*?\}|\[.*?\]);',
      dotAll: true,
    ).firstMatch(body);
    if (match != null) {
      return jsonDecode(match.group(1)!);
    }
    return null;
  }
}
