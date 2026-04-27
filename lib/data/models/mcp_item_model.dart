/// Item as returned by the MCP tools (search_items / get_item / register_item).
///
/// Uses integer [id] — the legacy DB primary key —
/// unlike the REST API's YYMMNNNN string format.
class McpItemModel {
  const McpItemModel({
    required this.id,
    required this.name,
    this.categoryId,
    this.price = 0,
    this.stock = 0,
    this.janCode,
    this.createdAt,
    this.score,
  });

  factory McpItemModel.fromJson(Map<String, dynamic> json) => McpItemModel(
    id: json['id'] as int,
    name: json['name'] as String,
    categoryId: json['categoryId'] as int? ?? json['category_id'] as int?,
    price: json['price'] as int? ?? 0,
    stock: json['stock'] as int? ?? 0,
    janCode: json['janCode'] as String? ?? json['jan_code'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String)
        : null,
    score: (json['score'] as num?)?.toDouble(),
  );

  final int id;
  final String name;
  final int? categoryId;
  final int price;
  final int stock;
  final String? janCode;
  final DateTime? createdAt;
  final double? score;
}
