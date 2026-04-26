import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

@freezed
abstract class Category with _$Category {
  const factory Category({
    required String id,
    required String name,
    String? parentId,
    @Default([]) List<Category> children,
    @Default(0) int depth,
  }) = _Category;

  const Category._();

  bool get isRoot => parentId == null;
  bool get hasChildren => children.isNotEmpty;

  String breadcrumb(List<Category> ancestors) =>
      [...ancestors.map((c) => c.name), name].join(' > ');
}
