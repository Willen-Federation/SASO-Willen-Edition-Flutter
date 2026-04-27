/// A registered Flutter device — response item from GET /api/v1/mobile/tokens.
class DeviceTokenModel {
  const DeviceTokenModel({
    required this.id,
    required this.deviceName,
    required this.revoked,
    required this.expiresAt,
    required this.createdAt,
    this.lastUsedAt,
  });

  factory DeviceTokenModel.fromJson(Map<String, dynamic> json) =>
      DeviceTokenModel(
        id: json['id'] as int,
        deviceName: json['deviceName'] as String,
        revoked: json['revoked'] as bool? ?? false,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
        lastUsedAt: json['lastUsedAt'] != null
            ? DateTime.parse(json['lastUsedAt'] as String)
            : null,
      );

  final int id;
  final String deviceName;
  final bool revoked;
  final DateTime expiresAt;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
}
