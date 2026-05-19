/// Local outbox record for a stock adjustment that is pending server sync.
///
/// Inserted into [pending_adjustments] SQLite table before every server call.
class PendingAdjustment {
  const PendingAdjustment({
    this.id,
    required this.itemId,
    required this.itemName,
    required this.delta,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.shelfId,
    this.locationId,
    this.errorMessage,
    this.syncedAt,
  });

  factory PendingAdjustment.fromMap(Map<String, dynamic> map) =>
      PendingAdjustment(
        id: map['id'] as int?,
        itemId: map['item_id'] as int,
        itemName: map['item_name'] as String,
        delta: map['delta'] as int,
        reason: map['reason'] as String,
        status: map['status'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        shelfId: map['shelf_id'] as String?,
        locationId: map['location_id'] as int?,
        errorMessage: map['error_message'] as String?,
        syncedAt: map['synced_at'] != null
            ? DateTime.tryParse(map['synced_at'] as String)
            : null,
      );

  final int? id;
  final int itemId;
  final String itemName;

  /// Positive = increase, negative = decrease.
  final int delta;

  /// 'check_in' | 'check_out' | 'audit'
  final String reason;

  /// 'pending' | 'syncing' | 'completed' | 'failed'
  final String status;

  final DateTime createdAt;
  final String? shelfId;
  final int? locationId;
  final String? errorMessage;
  final DateTime? syncedAt;

  Map<String, dynamic> toMap() => <String, dynamic>{
    if (id != null) 'id': id,
    'item_id': itemId,
    'item_name': itemName,
    'delta': delta,
    'reason': reason,
    'status': status,
    'created_at': createdAt.toIso8601String(),
    'shelf_id': shelfId,
    'location_id': locationId,
    'error_message': errorMessage,
    'synced_at': syncedAt?.toIso8601String(),
  };

  PendingAdjustment copyWith({
    String? status,
    String? errorMessage,
    DateTime? syncedAt,
  }) => PendingAdjustment(
    id: id,
    itemId: itemId,
    itemName: itemName,
    delta: delta,
    reason: reason,
    status: status ?? this.status,
    createdAt: createdAt,
    shelfId: shelfId,
    locationId: locationId,
    errorMessage: errorMessage ?? this.errorMessage,
    syncedAt: syncedAt ?? this.syncedAt,
  );
}
