/// Book metadata fetched from ISBN lookup APIs (OpenBD / Google Books).
class BookInfoModel {
  const BookInfoModel({
    required this.isbn,
    required this.title,
    required this.source,
    this.author,
    this.publisher,
    this.pubDate,
    this.coverUrl,
    this.price,
    this.description,
  });

  final String isbn;
  final String title;
  final String? author;
  final String? publisher;

  /// Raw publication date string (e.g. "20090101" or "2009-01").
  final String? pubDate;
  final String? coverUrl;

  /// 定価 (list price) in JPY, when available.
  final int? price;
  final String? description;

  /// Which API provided this record: 'openbd' | 'google_books'.
  final String source;
}
