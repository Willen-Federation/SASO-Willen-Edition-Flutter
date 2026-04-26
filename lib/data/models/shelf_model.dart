import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/shelf.dart';
import '../../domain/value_objects/shelf_id.dart';

part 'shelf_model.freezed.dart';
part 'shelf_model.g.dart';

@freezed
abstract class ShelfModel with _$ShelfModel {
  const factory ShelfModel({
    required String id,
    String? label,
    String? location,
    @Default([]) List<String> itemIds,
  }) = _ShelfModel;

  factory ShelfModel.fromJson(Map<String, dynamic> json) =>
      _$ShelfModelFromJson(json);

  const ShelfModel._();

  Shelf toDomain() => Shelf(
    id: ShelfId.parse(id),
    label: label,
    location: location,
    itemIds: itemIds,
  );
}
