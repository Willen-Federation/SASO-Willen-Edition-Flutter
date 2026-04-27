/// Response from POST /api/v1/mobile/pairing-codes.
///
/// qrPayload  — SASO1:<base64url_token>|<server_url> — encode this as QR.
/// qrDataUri  — ready-to-use data URI (data:image/png;base64,...) for display.
class PairingCodeModel {
  const PairingCodeModel({
    required this.label,
    required this.qrPayload,
    required this.qrDataUri,
    required this.expiresAt,
  });

  factory PairingCodeModel.fromJson(Map<String, dynamic> json) =>
      PairingCodeModel(
        label: json['label'] as String,
        qrPayload: json['qrPayload'] as String,
        qrDataUri: json['qrDataUri'] as String,
        expiresAt: DateTime.parse(json['expiresAt'] as String),
      );

  final String label;
  final String qrPayload;
  final String qrDataUri;
  final DateTime expiresAt;
}
