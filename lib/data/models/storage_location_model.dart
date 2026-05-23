/// A warehouse storage location as returned by either the MCP
/// `list_storage_locations` tool or the REST `/api/v1/storage-locations`
/// endpoint.
///
/// The two sources disagree on the wire type of `id` / `parentId`:
/// MCP returns raw integers, while REST stringifies them
/// (`(string) $loc->id` in `ListStorageLocationsController`). Both shapes
/// are parsed here.
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

  /// Accepts both camelCase (MCP) and snake_case (REST) field names, and
  /// both numeric and stringified IDs.
  factory StorageLocationModel.fromJson(Map<String, dynamic> json) =>
      StorageLocationModel(
        id: _asInt(json['id'])!,
        parentId: _asInt(json['parentId'] ?? json['parent_id']),
        code: json['code'] as String,
        name: json['name'] as String,
        depth: json['depth'] as int? ?? 0,
        position: json['position'] as int? ?? 0,
        locationType:
            (json['locationType'] ?? json['location_type']) as String?,
        description: json['description'] as String?,
        capacity: json['capacity'] as int?,
        notes: json['notes'] as String?,
        operationalStatus:
            (json['operationalStatus'] ?? json['operational_status'])
                as String?,
        canReceive: (json['canReceive'] ?? json['can_receive']) as bool? ??
            true,
        canShip: (json['canShip'] ?? json['can_ship']) as bool? ?? true,
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

  static int? _asInt(Object? raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is String) return int.tryParse(raw);
    if (raw is num) return raw.toInt();
    return null;
  }
}
