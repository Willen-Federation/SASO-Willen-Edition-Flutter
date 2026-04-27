/// A price observation stored locally for an ISBN, used to track price trends.
class PriceHistoryEntry {
  const PriceHistoryEntry({
    required this.isbn,
    required this.price,
    required this.source,
    required this.fetchedAt,
    this.id,
    this.currency = 'JPY',
  });

  factory PriceHistoryEntry.fromMap(Map<String, dynamic> map) =>
      PriceHistoryEntry(
        id: map['id'] as int?,
        isbn: map['isbn'] as String,
        price: map['price'] as int,
        currency: map['currency'] as String? ?? 'JPY',
        source: map['source'] as String,
        fetchedAt: DateTime.parse(map['fetched_at'] as String),
      );

  final int? id;
  final String isbn;
  final int price;
  final String currency;
  /// 'openbd' | 'google_books' | 'manual'
  final String source;
  final DateTime fetchedAt;

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'isbn': isbn,
    'price': price,
    'currency': currency,
    'source': source,
    'fetched_at': fetchedAt.toIso8601String(),
  };
}
