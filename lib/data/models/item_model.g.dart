// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FeatureModel _$FeatureModelFromJson(Map<String, dynamic> json) =>
    _FeatureModel(
      code: json['code'] as String,
      colorCode: json['colorCode'] as String,
      sizeCode: json['sizeCode'] as String,
      colorLabel: json['colorLabel'] as String?,
      sizeLabel: json['sizeLabel'] as String?,
      stockCount: (json['stockCount'] as num?)?.toInt() ?? 0,
      shelfId: json['shelfId'] as String?,
    );

Map<String, dynamic> _$FeatureModelToJson(_FeatureModel instance) =>
    <String, dynamic>{
      'code': instance.code,
      'colorCode': instance.colorCode,
      'sizeCode': instance.sizeCode,
      'colorLabel': instance.colorLabel,
      'sizeLabel': instance.sizeLabel,
      'stockCount': instance.stockCount,
      'shelfId': instance.shelfId,
    };

_ItemModel _$ItemModelFromJson(Map<String, dynamic> json) => _ItemModel(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  categoryId: json['categoryId'] as String,
  categoryName: json['categoryName'] as String?,
  features:
      (json['features'] as List<dynamic>?)
          ?.map((e) => FeatureModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  registeredAt: json['registeredAt'] as String,
  updatedAt: json['updatedAt'] as String?,
);

Map<String, dynamic> _$ItemModelToJson(_ItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'features': instance.features,
      'registeredAt': instance.registeredAt,
      'updatedAt': instance.updatedAt,
    };
