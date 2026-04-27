import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../data/models/book_info_model.dart';

/// Looks up book metadata from an ISBN using OpenBD (Japanese books) with a
/// Google Books fallback.  Does not require any API key.
class IsbnLookupService {
  IsbnLookupService({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;

  static const _timeout = Duration(seconds: 10);

  // ── ISBN format detection ──────────────────────────────────────────────────

  /// Returns true when [s] looks like an ISBN-13 (978/979 prefix) or ISBN-10.
  static bool isIsbn(String s) {
    final trimmed = s.trim();
    if (_isIsbn13(trimmed)) return true;
    if (_isIsbn10(trimmed)) return true;
    return false;
  }

  static bool _isIsbn13(String s) =>
      s.length == 13 &&
      RegExp(r'^\d{13}$').hasMatch(s) &&
      (s.startsWith('978') || s.startsWith('979'));

  static bool _isIsbn10(String s) =>
      s.length == 10 && RegExp(r'^\d{9}[\dX]$').hasMatch(s);

  /// Converts an ISBN-10 to ISBN-13; returns ISBN-13 unchanged.
  static String normalize(String isbn) {
    final s = isbn.trim();
    if (_isIsbn10(s)) {
      final body = '978${s.substring(0, 9)}';
      int sum = 0;
      for (int i = 0; i < 12; i++) {
        sum += int.parse(body[i]) * (i.isEven ? 1 : 3);
      }
      final check = (10 - (sum % 10)) % 10;
      return '$body$check';
    }
    return s;
  }

  // ── Public lookup ──────────────────────────────────────────────────────────

  /// Fetches [BookInfoModel] for the given ISBN.
  /// Returns null when the ISBN is not found in any source.
  Future<BookInfoModel?> lookup(String isbn) async {
    final normalized = normalize(isbn.trim());
    try {
      final ob = await _lookupOpenBD(normalized);
      if (ob != null) return ob;
    } catch (_) {}
    try {
      return await _lookupGoogleBooks(normalized);
    } catch (_) {}
    return null;
  }

  // ── OpenBD (Japanese books) ────────────────────────────────────────────────

  Future<BookInfoModel?> _lookupOpenBD(String isbn) async {
    final uri = Uri.parse('https://api.openbd.jp/v1/get?isbn=$isbn');
    final resp = await _http.get(uri).timeout(_timeout);
    if (resp.statusCode != 200) return null;

    final List<dynamic> data =
        jsonDecode(resp.body) as List<dynamic>;
    if (data.isEmpty || data[0] == null) return null;

    final book = data[0] as Map<String, dynamic>;
    final summary = book['summary'] as Map<String, dynamic>?;
    if (summary == null) return null;

    // Price lives deep inside the ONIX tree.
    int? price;
    try {
      final onix = book['onix'] as Map<String, dynamic>?;
      final ps = onix?['ProductSupply'] as Map<String, dynamic>?;
      final sd = ps?['SupplyDetail'] as Map<String, dynamic>?;
      final priceList = sd?['Price'] as List<dynamic>?;
      if (priceList != null && priceList.isNotEmpty) {
        final pa = (priceList[0] as Map<String, dynamic>)['PriceAmount'];
        price = int.tryParse(pa?.toString() ?? '');
      }
    } catch (_) {}

    // Description from ONIX CollateralDetail.
    String? description;
    try {
      final onix = book['onix'] as Map<String, dynamic>?;
      final cd = onix?['CollateralDetail'] as Map<String, dynamic>?;
      final td = cd?['TextContent'];
      if (td is List && td.isNotEmpty) {
        description = (td[0] as Map<String, dynamic>)['Text'] as String?;
      } else if (td is Map) {
        description = td['Text'] as String?;
      }
    } catch (_) {}

    return BookInfoModel(
      isbn: isbn,
      title: (summary['title'] as String?)?.trim() ?? '',
      author: summary['author'] as String?,
      publisher: summary['publisher'] as String?,
      pubDate: summary['pubdate'] as String?,
      coverUrl: summary['cover'] as String?,
      price: price,
      description: description,
      source: 'openbd',
    );
  }

  // ── Google Books (international fallback) ──────────────────────────────────

  Future<BookInfoModel?> _lookupGoogleBooks(String isbn) async {
    final uri = Uri.parse(
      'https://www.googleapis.com/books/v1/volumes?q=isbn:$isbn',
    );
    final resp = await _http.get(uri).timeout(_timeout);
    if (resp.statusCode != 200) return null;

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>?;
    if (items == null || items.isEmpty) return null;

    final item = items[0] as Map<String, dynamic>;
    final vi = item['volumeInfo'] as Map<String, dynamic>?;
    if (vi == null) return null;

    final saleInfo = item['saleInfo'] as Map<String, dynamic>?;
    int? price;
    final retailPrice =
        saleInfo?['retailPrice'] as Map<String, dynamic>?;
    if (retailPrice != null) {
      price = (retailPrice['amount'] as num?)?.round();
    }

    final authors = (vi['authors'] as List<dynamic>?)?.cast<String>();
    final imageLinks = vi['imageLinks'] as Map<String, dynamic>?;
    // Prefer higher-res thumbnail over smallThumbnail.
    final coverUrl =
        (imageLinks?['thumbnail'] ?? imageLinks?['smallThumbnail']) as String?;

    return BookInfoModel(
      isbn: isbn,
      title: (vi['title'] as String?)?.trim() ?? '',
      author: authors?.join(', '),
      publisher: vi['publisher'] as String?,
      pubDate: vi['publishedDate'] as String?,
      coverUrl: coverUrl,
      price: price,
      description: vi['description'] as String?,
      source: 'google_books',
    );
  }
}
