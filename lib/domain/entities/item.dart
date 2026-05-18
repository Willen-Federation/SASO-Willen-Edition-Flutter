import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/item_id.dart';
import 'category.dart';
import 'feature.dart';
import 'item_status.dart';

part 'item.freezed.dart';

@freezed
abstract class Item with _$Item {
  const factory Item({
    required ItemId id,
    required String name,
    String? description,
    required Category category,
    @Default([]) List<Feature> features,
    String? janCode,
    String? isbnCode,
    String? labelCode,
    String? note,
    required DateTime registeredAt,
    DateTime? updatedAt,
    @Default(ItemStatus.active) ItemStatus status,
  }) = _Item;

  const Item._();

  bool get hasPla => false;
  bool get hasPaper => false;
  int get totalStock => features.fold(0, (sum, f) => sum + f.stockCount);
}
