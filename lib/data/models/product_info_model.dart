/// Minimal product metadata returned by a barcode lookup (e.g. OpenFoodFacts).
class ProductInfoModel {
  const ProductInfoModel({
    required this.barcode,
    required this.name,
    this.brand,
    this.quantity,
    this.imageUrl,
    this.source = 'unknown',
  });

  final String barcode;

  /// Product / item name.
  final String name;

  /// Brand / manufacturer name (nullable).
  final String? brand;

  /// Quantity / weight description, e.g. "500g", "12 pcs" (nullable).
  final String? quantity;

  /// Product thumbnail URL (nullable).
  final String? imageUrl;

  /// Data source label, e.g. "open_food_facts".
  final String source;

  /// Human-readable display name combining brand and product name.
  String get displayName =>
      brand != null && brand!.isNotEmpty ? '$brand $name' : name;
}
