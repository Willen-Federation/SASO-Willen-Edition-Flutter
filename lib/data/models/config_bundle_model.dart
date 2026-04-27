import 'feature_flag_model.dart';

/// Offline config bundle from GET /api/v1/mobile/config.
///
/// version is a SHA-256 hash of the bundle content — cache by comparing it
/// to the last stored version before applying updates.
class ConfigBundleModel {
  const ConfigBundleModel({
    required this.version,
    required this.generatedAt,
    required this.featureFlags,
  });

  factory ConfigBundleModel.fromJson(Map<String, dynamic> json) =>
      ConfigBundleModel(
        version: json['version'] as String,
        generatedAt: DateTime.parse(json['generatedAt'] as String),
        featureFlags: (json['featureFlags'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(FeatureFlagModel.fromJson)
            .toList(),
      );

  final String version;
  final DateTime generatedAt;
  final List<FeatureFlagModel> featureFlags;
}
