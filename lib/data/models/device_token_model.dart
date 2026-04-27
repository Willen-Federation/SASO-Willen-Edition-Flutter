/// A registered Flutter device — response item from GET /api/v1/mobile/tokens.
class DeviceTokenModel {
  const DeviceTokenModel({
    required this.id,
    required this.deviceName,
    required this.expiresAt,
    required this.createdAt,
  });

  factory DeviceTokenModel.fromJson(Map<String, dynamic> json) =>
      DeviceTokenModel(
        id: json['id'] as int,
        deviceName: json['device_name'] as String,
        expiresAt: DateTime.parse(json['expires_at'] as String),
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  final int id;
  final String deviceName;
  final DateTime expiresAt;
  final DateTime createdAt;
}
