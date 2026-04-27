/// Response from POST /api/v1/mobile/connect and POST /api/v1/mobile/token/refresh.
///
/// access_token: HS256 JWT, 1h expiry.
/// refresh_token: opaque long-lived token (~1yr) rotated on every refresh call.
class TokenPairModel {
  const TokenPairModel({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
    required this.deviceId,
    required this.deviceName,
    required this.expiresAt,
  });

  factory TokenPairModel.fromJson(Map<String, dynamic> json) => TokenPairModel(
    accessToken: json['access_token'] as String,
    tokenType: json['token_type'] as String? ?? 'Bearer',
    expiresIn: json['expires_in'] as int? ?? 3600,
    refreshToken: json['refresh_token'] as String,
    deviceId: json['device_id'] as int,
    deviceName: json['device_name'] as String,
    expiresAt: DateTime.parse(json['expires_at'] as String),
  );

  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String refreshToken;
  final int deviceId;
  final String deviceName;
  final DateTime expiresAt;
}
