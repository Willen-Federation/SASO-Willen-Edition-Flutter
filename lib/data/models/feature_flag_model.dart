/// A server-managed feature flag — used in GET /api/v1/feature-flags
/// and inside the config bundle from GET /api/v1/mobile/config.
class FeatureFlagModel {
  const FeatureFlagModel({
    required this.key,
    required this.description,
    required this.enabled,
    required this.rolloutPercent,
    this.conditions = const {},
  });

  factory FeatureFlagModel.fromJson(Map<String, dynamic> json) =>
      FeatureFlagModel(
        key: json['key'] as String,
        description: json['description'] as String? ?? '',
        enabled: json['enabled'] as bool? ?? false,
        rolloutPercent: json['rollout_percent'] as int? ?? 0,
        conditions: (json['conditions'] as Map<String, dynamic>?)
                ?.cast<String, dynamic>() ??
            const {},
      );

  final String key;
  final String description;
  final bool enabled;
  final int rolloutPercent;
  final Map<String, dynamic> conditions;

  Map<String, dynamic> toJson() => {
    'key': key,
    'description': description,
    'enabled': enabled,
    'rollout_percent': rolloutPercent,
    'conditions': conditions,
  };
}
