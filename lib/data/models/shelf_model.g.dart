// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shelf_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ShelfModel _$ShelfModelFromJson(Map<String, dynamic> json) => _ShelfModel(
  id: json['id'] as String,
  label: json['label'] as String?,
  location: json['location'] as String?,
  itemIds:
      (json['itemIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$ShelfModelToJson(_ShelfModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'location': instance.location,
      'itemIds': instance.itemIds,
    };
