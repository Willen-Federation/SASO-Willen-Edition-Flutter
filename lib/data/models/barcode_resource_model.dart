/// Response body of `GET /api/v1/barcode/{code}`.
///
/// Returns whatever the server knows about a JAN/EAN/ISBN string:
/// if there is a linked item the [itemId] is populated, otherwise just
/// the barcode metadata so the mobile app can decide whether to register
/// a new item.
class BarcodeResourceModel {
  const BarcodeResourceModel({
    required this.code,
    this.itemId,
    this.name,
    this.symbology,
    this.lastSeenAt,
  });

  factory BarcodeResourceModel.fromJson(Map<String, dynamic> json) =>
      BarcodeResourceModel(
        code: json['code'] as String,
        itemId:
            (json['item_id'] as int?) ?? (json['itemId'] as int?),
        name: json['name'] as String?,
        symbology: json['symbology'] as String?,
        lastSeenAt: json['last_seen_at'] != null
            ? DateTime.tryParse(json['last_seen_at'] as String)
            : null,
      );

  final String code;
  final int? itemId;
  final String? name;
  final String? symbology;
  final DateTime? lastSeenAt;

  bool get isLinked => itemId != null;
}
