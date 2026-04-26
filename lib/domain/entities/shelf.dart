import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/shelf_id.dart';

part 'shelf.freezed.dart';

@freezed
abstract class Shelf with _$Shelf {
  const factory Shelf({
    required ShelfId id,
    String? label,
    String? location,
    @Default([]) List<String> itemIds,
  }) = _Shelf;
}
