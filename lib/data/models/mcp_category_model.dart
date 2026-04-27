/// A classification category as returned by the MCP `list_categories` tool.
class McpCategoryModel {
  const McpCategoryModel({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameJa,
    required this.depth,
    required this.sortOrder,
    this.parentId,
    this.description,
  });

  factory McpCategoryModel.fromJson(Map<String, dynamic> json) =>
      McpCategoryModel(
        id: json['id'] as int,
        code: json['code'] as String,
        nameEn: json['nameEn'] as String? ?? '',
        nameJa: json['nameJa'] as String? ?? '',
        parentId: json['parentId'] as int?,
        depth: json['depth'] as int? ?? 0,
        sortOrder: json['sortOrder'] as int? ?? 0,
        description: json['description'] as String?,
      );

  final int id;
  final String code;
  final String nameEn;
  final String nameJa;
  final int? parentId;
  final int depth;
  final int sortOrder;
  final String? description;

  String get displayName => nameJa.isNotEmpty ? nameJa : nameEn;
}
