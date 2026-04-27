/// A warehouse storage location as returned by the MCP `list_storage_locations` tool.
class StorageLocationModel {
  const StorageLocationModel({
    required this.id,
    required this.code,
    required this.name,
    required this.depth,
    this.parentId,
  });

  factory StorageLocationModel.fromJson(Map<String, dynamic> json) =>
      StorageLocationModel(
        id: json['id'] as int,
        parentId: json['parentId'] as int?,
        code: json['code'] as String,
        name: json['name'] as String,
        depth: json['depth'] as int? ?? 0,
      );

  final int id;
  final int? parentId;
  final String code;
  final String name;
  final int depth;
}
