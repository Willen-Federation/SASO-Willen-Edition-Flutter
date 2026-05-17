import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/barcode/product_lookup_service.dart';
import '../../data/models/product_info_model.dart';

final productLookupServiceProvider = Provider<ProductLookupService>(
  (_) => ProductLookupService(),
);

/// Fetches [ProductInfoModel] for [barcode] via Open Food Facts.
/// Returns null when the product is not found or on network error.
final productInfoProvider = FutureProvider.family<ProductInfoModel?, String>((
  ref,
  barcode,
) async {
  final service = ref.read(productLookupServiceProvider);
  return service.lookup(barcode);
});
