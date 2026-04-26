import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/feature_code.dart';
import '../value_objects/shelf_id.dart';

part 'feature.freezed.dart';

@freezed
abstract class Feature with _$Feature {
  const factory Feature({
    required FeatureCode code,
    required String colorCode,
    required String sizeCode,
    String? colorLabel,
    String? sizeLabel,
    @Default(0) int stockCount,
    ShelfId? shelfId,
  }) = _Feature;

  const Feature._();

  String get displayLabel {
    final color = colorLabel ?? colorCode;
    final size = sizeLabel ?? sizeCode;
    return '$color / $size';
  }
}
