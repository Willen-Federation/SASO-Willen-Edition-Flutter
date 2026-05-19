/// Local outbox record for an item registration that is pending server sync.
///
/// Inserted into [pending_registrations] SQLite table before every server call.
/// Status transitions: pending → syncing → completed | failed.
class PendingRegistration {
  const PendingRegistration({
    this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    required this.stock,
    required this.status,
    required this.createdAt,
    this.janCode,
    this.imagePath,
    this.draftId,
    this.errorMessage,
    this.syncedAt,
  });

  factory PendingRegistration.fromMap(Map<String, dynamic> map) =>
      PendingRegistration(
        id: map['id'] as int?,
        name: map['name'] as String,
        categoryId: map['category_id'] as int,
        price: map['price'] as int,
        stock: map['stock'] as int,
        status: map['status'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        janCode: map['jan_code'] as String?,
        imagePath: map['image_path'] as String?,
        draftId: map['draft_id'] as String?,
        errorMessage: map['error_message'] as String?,
        syncedAt: map['synced_at'] != null
            ? DateTime.tryParse(map['synced_at'] as String)
            : null,
      );

  final int? id;
  final String name;
  final int categoryId;
  final int price;
  final int stock;

  /// 'pending' | 'syncing' | 'completed' | 'failed'
  final String status;

  final DateTime createdAt;
  final String? janCode;

  /// Absolute local file path to the captured image.
  final String? imagePath;

  /// Server-assigned draft ID, populated after AI analysis.
  final String? draftId;

  final String? errorMessage;
  final DateTime? syncedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    if (id != null) 'id': id,
    'name': name,
    'category_id': categoryId,
    'price': price,
    'stock': stock,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'jan_code': janCode,
    'image_path': imagePath,
    'draft_id': draftId,
    'error_message': errorMessage,
    'synced_at': syncedAt?.toIso8601String(),
  };

  PendingRegistration copyWith({
    String? status,
    String? errorMessage,
    DateTime? syncedAt,
  }) => PendingRegistration(
    id: id,
    name: name,
    categoryId: categoryId,
    price: price,
    stock: stock,
    status: status ?? this.status,
    createdAt: createdAt,
    janCode: janCode,
    imagePath: imagePath,
    draftId: draftId,
    errorMessage: errorMessage ?? this.errorMessage,
    syncedAt: syncedAt ?? this.syncedAt,
  );
}
