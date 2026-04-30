import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/database_helper.dart';
import '../../data/datasources/local/price_history_dao.dart';
import '../../data/datasources/remote/isbn/isbn_lookup_service.dart';
import '../../data/models/book_info_model.dart';
import '../../data/models/price_history_entry.dart';

final isbnLookupServiceProvider = Provider<IsbnLookupService>(
  (_) => IsbnLookupService(),
);

/// Fetches [BookInfoModel] for [isbn]. Returns null when not found.
/// Only queries when the string looks like an ISBN.
final isbnInfoProvider = FutureProvider.family<BookInfoModel?, String>((
  ref,
  isbn,
) async {
  if (!IsbnLookupService.isIsbn(isbn)) return null;
  final service = ref.read(isbnLookupServiceProvider);
  return service.lookup(isbn);
});

/// Returns all locally stored price history entries for [isbn], sorted oldest→newest.
final priceHistoryProvider =
    FutureProvider.family<List<PriceHistoryEntry>, String>((ref, isbn) async {
      final db = await ref.watch(databaseHelperProvider.future);
      return PriceHistoryDao(db.db).getHistory(isbn);
    });
