import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/category.dart';
import '../../domain/entities/feature.dart';
import '../../domain/entities/item.dart';
import '../../domain/value_objects/feature_code.dart';
import '../../domain/value_objects/item_id.dart';

part 'item_model.freezed.dart';
part 'item_model.g.dart';

@freezed
abstract class FeatureModel with _$FeatureModel {
  const factory FeatureModel({
    required String code,
    required String colorCode,
    required String sizeCode,
    String? colorLabel,
    String? sizeLabel,
    @Default(0) int stockCount,
    String? shelfId,
  }) = _FeatureModel;

  factory FeatureModel.fromJson(Map<String, dynamic> json) =>
      _$FeatureModelFromJson(json);

  const FeatureModel._();

  Feature toDomain() => Feature(
    code: FeatureCode.parse(code),
    colorCode: colorCode,
    sizeCode: sizeCode,
    colorLabel: colorLabel,
    sizeLabel: sizeLabel,
    stockCount: stockCount,
  );
}

@freezed
abstract class ItemModel with _$ItemModel {
  const factory ItemModel({
    required String id,
    required String name,
    String? description,
    required String categoryId,
    String? categoryName,
    @Default([]) List<FeatureModel> features,
    String? janCode,
    String? isbnCode,
    String? labelCode,
    required String registeredAt,
    String? updatedAt,
  }) = _ItemModel;

  factory ItemModel.fromJson(Map<String, dynamic> json) =>
      _$ItemModelFromJson(json);

  const ItemModel._();

  Item toDomain({Category? category}) {
    final cat =
        category ?? Category(id: categoryId, name: categoryName ?? categoryId);
    return Item(
      id: ItemId.parse(id),
      name: name,
      description: description,
      category: cat,
      features: features.map((f) => f.toDomain()).toList(),
      janCode: janCode,
      isbnCode: isbnCode,
      labelCode: labelCode,
      registeredAt: DateTime.parse(registeredAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }
}
