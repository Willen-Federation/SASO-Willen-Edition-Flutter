/// Result returned by POST /api/v1/items/register-with-ai or
/// POST /api/v1/images/analyze-and-draft.
///
/// The server uses its registered AI provider to fill in missing fields
/// from the submitted image + any manually supplied inputs.
class AiAnalysisModel {
  const AiAnalysisModel({
    required this.confidence,
    this.draftId,
    this.imageUrl,
    this.name,
    this.categoryId,
    this.price,
    this.description,
  });

  factory AiAnalysisModel.fromJson(Map<String, dynamic> json) =>
      AiAnalysisModel(
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        draftId: json['draftId'] as String?,
        imageUrl: json['imageUrl'] as String?,
        name: json['name'] as String?,
        categoryId: json['categoryId'] as int?,
        price: json['price'] as int?,
        description: json['description'] as String?,
      );

  /// AI confidence score 0.0–1.0.
  final double confidence;

  /// Server-assigned draft item ID (present when the server created a draft).
  final String? draftId;

  /// URL of the uploaded image (returned by the server after upload).
  final String? imageUrl;

  final String? name;
  final int? categoryId;
  final int? price;
  final String? description;

  /// Human-readable confidence percentage, e.g. '87%'.
  String get confidenceLabel => '${(confidence * 100).round()}%';

  /// True when confidence is below the threshold warranting a user warning.
  bool get isLowConfidence => confidence < 0.6;
}
