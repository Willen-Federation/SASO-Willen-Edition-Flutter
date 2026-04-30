import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/data/models/ai_analysis_model.dart';

void main() {
  group('AiAnalysisModel', () {
    test('fromJson parses all fields', () {
      final json = {
        'confidence': 0.875,
        'draftId': 'draft-123',
        'imageUrl': 'https://example.com/img.jpg',
        'name': 'Test Item',
        'categoryId': 42,
        'price': 1980,
        'description': 'A test item',
      };
      final model = AiAnalysisModel.fromJson(json);
      expect(model.confidence, 0.875);
      expect(model.draftId, 'draft-123');
      expect(model.imageUrl, 'https://example.com/img.jpg');
      expect(model.name, 'Test Item');
      expect(model.categoryId, 42);
      expect(model.price, 1980);
      expect(model.description, 'A test item');
    });

    test('fromJson defaults confidence to 0.0 when absent', () {
      final model = AiAnalysisModel.fromJson(<String, dynamic>{});
      expect(model.confidence, 0.0);
    });

    test('fromJson handles null optional fields', () {
      final model = AiAnalysisModel.fromJson(<String, dynamic>{
        'confidence': 0.5,
      });
      expect(model.draftId, isNull);
      expect(model.imageUrl, isNull);
      expect(model.name, isNull);
      expect(model.categoryId, isNull);
      expect(model.price, isNull);
      expect(model.description, isNull);
    });

    test('confidenceLabel formats as percent', () {
      expect(const AiAnalysisModel(confidence: 0.875).confidenceLabel, '88%');
      expect(const AiAnalysisModel(confidence: 1.0).confidenceLabel, '100%');
      expect(const AiAnalysisModel(confidence: 0.0).confidenceLabel, '0%');
    });

    test('isLowConfidence returns true below 0.6', () {
      expect(const AiAnalysisModel(confidence: 0.59).isLowConfidence, isTrue);
      expect(const AiAnalysisModel(confidence: 0.6).isLowConfidence, isFalse);
      expect(const AiAnalysisModel(confidence: 0.99).isLowConfidence, isFalse);
    });
  });
}
