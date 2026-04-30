/// Reason for a stock adjustment operation.
enum AdjustmentReason {
  /// 入庫 — Goods received / stock intake.
  checkIn,

  /// 出庫 — Goods issued / stock dispatch.
  checkOut,

  /// 棚卸 — Physical inventory audit / correction.
  audit,
}

extension AdjustmentReasonExt on AdjustmentReason {
  String get label => switch (this) {
    AdjustmentReason.checkIn => '入庫',
    AdjustmentReason.checkOut => '出庫',
    AdjustmentReason.audit => '棚卸',
  };

  String get mcpValue => switch (this) {
    AdjustmentReason.checkIn => 'check_in',
    AdjustmentReason.checkOut => 'check_out',
    AdjustmentReason.audit => 'audit',
  };
}

/// Parameters sent to the MCP adjust_stock tool.
class StockAdjustmentParams {
  const StockAdjustmentParams({
    required this.itemId,
    required this.delta,
    required this.reason,
    this.shelfId,
    this.locationId,
  });

  final int itemId;

  /// Positive = increase, negative = decrease.
  final int delta;

  final AdjustmentReason reason;

  /// Shelf code string (alphanumeric), if applicable.
  final String? shelfId;

  /// Numeric location ID (storage location), if applicable.
  final int? locationId;

  Map<String, dynamic> toArgs() => <String, dynamic>{
    'itemId': itemId,
    'delta': delta,
    'reason': reason.mcpValue,
    if (shelfId != null) 'shelfId': shelfId,
    if (locationId != null) 'locationId': locationId,
  };
}

/// Result returned by the MCP adjust_stock tool.
class StockAdjustmentResult {
  const StockAdjustmentResult({
    required this.itemId,
    required this.previousStock,
    required this.newStock,
    required this.delta,
  });

  factory StockAdjustmentResult.fromJson(Map<String, dynamic> json) =>
      StockAdjustmentResult(
        itemId: json['itemId'] as int,
        previousStock: json['previousStock'] as int,
        newStock: json['newStock'] as int,
        delta: json['delta'] as int,
      );

  final int itemId;
  final int previousStock;
  final int newStock;
  final int delta;
}
