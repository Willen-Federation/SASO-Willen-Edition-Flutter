/// A server-managed feature flag.
///
/// Used in two contexts with overlapping schemas:
///   - GET /api/v1/feature-flags (FeatureFlagResource): all fields present
///   - GET /api/v1/mobile/config (MobileFeatureFlag): id/description/timestamps absent
class FeatureFlagModel {
  const FeatureFlagModel({
    this.id,
    required this.key,
    this.description = '',
    required this.enabled,
    required this.rolloutPercent,
    this.conditions = const {},
    this.errorThreshold = 0,
    this.errorWindowMinutes = 60,
    this.autoDisabledAt,
    this.autoDisableReason,
    this.createdAt,
    this.updatedAt,
  });

  factory FeatureFlagModel.fromJson(Map<String, dynamic> json) =>
      FeatureFlagModel(
        id: json['id'] as int?,
        key: json['key'] as String,
        description: json['description'] as String? ?? '',
        enabled: json['enabled'] as bool? ?? false,
        rolloutPercent: json['rolloutPercent'] as int? ?? 0,
        conditions: (json['conditions'] as Map<String, dynamic>?)
                ?.cast<String, dynamic>() ??
            const {},
        errorThreshold: json['errorThreshold'] as int? ?? 0,
        errorWindowMinutes: json['errorWindowMinutes'] as int? ?? 60,
        autoDisabledAt: json['autoDisabledAt'] != null
            ? DateTime.parse(json['autoDisabledAt'] as String)
            : null,
        autoDisableReason: json['autoDisableReason'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  final int? id;
  final String key;
  final String description;
  final bool enabled;
  final int rolloutPercent;
  final Map<String, dynamic> conditions;
  final int errorThreshold;
  final int errorWindowMinutes;
  final DateTime? autoDisabledAt;
  final String? autoDisableReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
    'key': key,
    'description': description,
    'enabled': enabled,
    'rolloutPercent': rolloutPercent,
    if (conditions.isNotEmpty) 'conditions': conditions,
  };
}
