/// A warehouse storage location as returned by the MCP `list_storage_locations` tool.
class StorageLocationModel {
  const StorageLocationModel({
    required this.id,
    required this.code,
    required this.name,
    required this.depth,
    required this.position,
    required this.canReceive,
    required this.canShip,
    this.parentId,
    this.locationType,
    this.description,
    this.capacity,
    this.notes,
    this.operationalStatus,
  });

  factory StorageLocationModel.fromJson(Map<String, dynamic> json) =>
      StorageLocationModel(
        id: json['id'] as int,
        parentId: json['parentId'] as int?,
        code: json['code'] as String,
        name: json['name'] as String,
        depth: json['depth'] as int? ?? 0,
        position: json['position'] as int? ?? 0,
        locationType: json['locationType'] as String?,
        description: json['description'] as String?,
        capacity: json['capacity'] as int?,
        notes: json['notes'] as String?,
        operationalStatus: json['operationalStatus'] as String?,
        canReceive: json['canReceive'] as bool? ?? true,
        canShip: json['canShip'] as bool? ?? true,
      );

  final int id;
  final int? parentId;
  final String code;
  final String name;
  final int depth;
  final int position;
  final String? locationType;
  final String? description;
  final int? capacity;
  final String? notes;
  final String? operationalStatus;
  final bool canReceive;
  final bool canShip;
}
