import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../models/product_info_model.dart';

/// Looks up product metadata for a JAN/EAN/UPC barcode using Open Food Facts
/// (https://world.openfoodfacts.org/). Works for food products, daily goods,
/// and many retail items.
///
/// For ISBN codes use [IsbnLookupService] instead — this service returns null
/// for ISBN-prefixed codes.
class ProductLookupService {
  ProductLookupService({http.Client? httpClient})
    : _http = httpClient ?? http.Client();

  final http.Client _http;
  static const _timeout = Duration(seconds: 10);

  /// Look up product information for [barcode].
  ///
  /// Returns null when the barcode is not found or the network call fails.
  Future<ProductInfoModel?> lookup(String barcode) async {
    try {
      return await _lookupOpenFoodFacts(barcode.trim());
    } catch (_) {
      return null;
    }
  }

  // ── Open Food Facts ────────────────────────────────────────────────────────

  Future<ProductInfoModel?> _lookupOpenFoodFacts(String barcode) async {
    // Use the v2 product endpoint; request only the fields we need for speed.
    final uri = Uri.parse(
      'https://world.openfoodfacts.org/api/v2/product/$barcode.json'
      '?fields=product_name,brands,quantity,image_front_thumb_url',
    );

    final resp = await _http
        .get(uri, headers: {'User-Agent': 'SASO-Willen-Edition/1.0'})
        .timeout(_timeout);

    if (resp.statusCode != 200) return null;

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if ((data['status'] as int? ?? 0) != 1) return null;

    final product = data['product'] as Map<String, dynamic>?;
    if (product == null) return null;

    // Prefer the localised Japanese name, fall back to the generic product name.
    final name =
        (product['product_name_ja'] as String?)?.trim() ??
        (product['product_name'] as String?)?.trim() ??
        '';
    if (name.isEmpty) return null;

    return ProductInfoModel(
      barcode: barcode,
      name: name,
      brand: (product['brands'] as String?)?.trim(),
      quantity: (product['quantity'] as String?)?.trim(),
      imageUrl: product['image_front_thumb_url'] as String?,
      source: 'open_food_facts',
    );
  }
}
