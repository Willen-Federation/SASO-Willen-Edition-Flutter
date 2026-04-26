import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/category.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
abstract class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required String name,
    String? parentId,
    @Default([]) List<CategoryModel> children,
    @Default(0) int depth,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  const CategoryModel._();

  Category toDomain() => Category(
    id: id,
    name: name,
    parentId: parentId,
    children: children.map((c) => c.toDomain()).toList(),
    depth: depth,
  );
}
