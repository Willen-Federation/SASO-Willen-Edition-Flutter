// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FeatureModel {

 String get code; String get colorCode; String get sizeCode; String? get colorLabel; String? get sizeLabel; int get stockCount; String? get shelfId;
/// Create a copy of FeatureModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeatureModelCopyWith<FeatureModel> get copyWith => _$FeatureModelCopyWithImpl<FeatureModel>(this as FeatureModel, _$identity);

  /// Serializes this FeatureModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeatureModel&&(identical(other.code, code) || other.code == code)&&(identical(other.colorCode, colorCode) || other.colorCode == colorCode)&&(identical(other.sizeCode, sizeCode) || other.sizeCode == sizeCode)&&(identical(other.colorLabel, colorLabel) || other.colorLabel == colorLabel)&&(identical(other.sizeLabel, sizeLabel) || other.sizeLabel == sizeLabel)&&(identical(other.stockCount, stockCount) || other.stockCount == stockCount)&&(identical(other.shelfId, shelfId) || other.shelfId == shelfId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,colorCode,sizeCode,colorLabel,sizeLabel,stockCount,shelfId);

@override
String toString() {
  return 'FeatureModel(code: $code, colorCode: $colorCode, sizeCode: $sizeCode, colorLabel: $colorLabel, sizeLabel: $sizeLabel, stockCount: $stockCount, shelfId: $shelfId)';
}


}

/// @nodoc
abstract mixin class $FeatureModelCopyWith<$Res>  {
  factory $FeatureModelCopyWith(FeatureModel value, $Res Function(FeatureModel) _then) = _$FeatureModelCopyWithImpl;
@useResult
$Res call({
 String code, String colorCode, String sizeCode, String? colorLabel, String? sizeLabel, int stockCount, String? shelfId
});




}
/// @nodoc
class _$FeatureModelCopyWithImpl<$Res>
    implements $FeatureModelCopyWith<$Res> {
  _$FeatureModelCopyWithImpl(this._self, this._then);

  final FeatureModel _self;
  final $Res Function(FeatureModel) _then;

/// Create a copy of FeatureModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? colorCode = null,Object? sizeCode = null,Object? colorLabel = freezed,Object? sizeLabel = freezed,Object? stockCount = null,Object? shelfId = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,colorCode: null == colorCode ? _self.colorCode : colorCode // ignore: cast_nullable_to_non_nullable
as String,sizeCode: null == sizeCode ? _self.sizeCode : sizeCode // ignore: cast_nullable_to_non_nullable
as String,colorLabel: freezed == colorLabel ? _self.colorLabel : colorLabel // ignore: cast_nullable_to_non_nullable
as String?,sizeLabel: freezed == sizeLabel ? _self.sizeLabel : sizeLabel // ignore: cast_nullable_to_non_nullable
as String?,stockCount: null == stockCount ? _self.stockCount : stockCount // ignore: cast_nullable_to_non_nullable
as int,shelfId: freezed == shelfId ? _self.shelfId : shelfId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeatureModel].
extension FeatureModelPatterns on FeatureModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeatureModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeatureModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeatureModel value)  $default,){
final _that = this;
switch (_that) {
case _FeatureModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeatureModel value)?  $default,){
final _that = this;
switch (_that) {
case _FeatureModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String colorCode,  String sizeCode,  String? colorLabel,  String? sizeLabel,  int stockCount,  String? shelfId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeatureModel() when $default != null:
return $default(_that.code,_that.colorCode,_that.sizeCode,_that.colorLabel,_that.sizeLabel,_that.stockCount,_that.shelfId);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String colorCode,  String sizeCode,  String? colorLabel,  String? sizeLabel,  int stockCount,  String? shelfId)  $default,) {final _that = this;
switch (_that) {
case _FeatureModel():
return $default(_that.code,_that.colorCode,_that.sizeCode,_that.colorLabel,_that.sizeLabel,_that.stockCount,_that.shelfId);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String colorCode,  String sizeCode,  String? colorLabel,  String? sizeLabel,  int stockCount,  String? shelfId)?  $default,) {final _that = this;
switch (_that) {
case _FeatureModel() when $default != null:
return $default(_that.code,_that.colorCode,_that.sizeCode,_that.colorLabel,_that.sizeLabel,_that.stockCount,_that.shelfId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FeatureModel extends FeatureModel {
  const _FeatureModel({required this.code, required this.colorCode, required this.sizeCode, this.colorLabel, this.sizeLabel, this.stockCount = 0, this.shelfId}): super._();
  factory _FeatureModel.fromJson(Map<String, dynamic> json) => _$FeatureModelFromJson(json);

@override final  String code;
@override final  String colorCode;
@override final  String sizeCode;
@override final  String? colorLabel;
@override final  String? sizeLabel;
@override@JsonKey() final  int stockCount;
@override final  String? shelfId;

/// Create a copy of FeatureModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeatureModelCopyWith<_FeatureModel> get copyWith => __$FeatureModelCopyWithImpl<_FeatureModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FeatureModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeatureModel&&(identical(other.code, code) || other.code == code)&&(identical(other.colorCode, colorCode) || other.colorCode == colorCode)&&(identical(other.sizeCode, sizeCode) || other.sizeCode == sizeCode)&&(identical(other.colorLabel, colorLabel) || other.colorLabel == colorLabel)&&(identical(other.sizeLabel, sizeLabel) || other.sizeLabel == sizeLabel)&&(identical(other.stockCount, stockCount) || other.stockCount == stockCount)&&(identical(other.shelfId, shelfId) || other.shelfId == shelfId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,colorCode,sizeCode,colorLabel,sizeLabel,stockCount,shelfId);

@override
String toString() {
  return 'FeatureModel(code: $code, colorCode: $colorCode, sizeCode: $sizeCode, colorLabel: $colorLabel, sizeLabel: $sizeLabel, stockCount: $stockCount, shelfId: $shelfId)';
}


}

/// @nodoc
abstract mixin class _$FeatureModelCopyWith<$Res> implements $FeatureModelCopyWith<$Res> {
  factory _$FeatureModelCopyWith(_FeatureModel value, $Res Function(_FeatureModel) _then) = __$FeatureModelCopyWithImpl;
@override @useResult
$Res call({
 String code, String colorCode, String sizeCode, String? colorLabel, String? sizeLabel, int stockCount, String? shelfId
});




}
/// @nodoc
class __$FeatureModelCopyWithImpl<$Res>
    implements _$FeatureModelCopyWith<$Res> {
  __$FeatureModelCopyWithImpl(this._self, this._then);

  final _FeatureModel _self;
  final $Res Function(_FeatureModel) _then;

/// Create a copy of FeatureModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? colorCode = null,Object? sizeCode = null,Object? colorLabel = freezed,Object? sizeLabel = freezed,Object? stockCount = null,Object? shelfId = freezed,}) {
  return _then(_FeatureModel(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,colorCode: null == colorCode ? _self.colorCode : colorCode // ignore: cast_nullable_to_non_nullable
as String,sizeCode: null == sizeCode ? _self.sizeCode : sizeCode // ignore: cast_nullable_to_non_nullable
as String,colorLabel: freezed == colorLabel ? _self.colorLabel : colorLabel // ignore: cast_nullable_to_non_nullable
as String?,sizeLabel: freezed == sizeLabel ? _self.sizeLabel : sizeLabel // ignore: cast_nullable_to_non_nullable
as String?,stockCount: null == stockCount ? _self.stockCount : stockCount // ignore: cast_nullable_to_non_nullable
as int,shelfId: freezed == shelfId ? _self.shelfId : shelfId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ItemModel {

 String get id; String get name; String? get description; String get categoryId; String? get categoryName; List<FeatureModel> get features; String? get janCode; String? get isbnCode; String? get labelCode; String get registeredAt; String? get updatedAt;
/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemModelCopyWith<ItemModel> get copyWith => _$ItemModelCopyWithImpl<ItemModel>(this as ItemModel, _$identity);

  /// Serializes this ItemModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&const DeepCollectionEquality().equals(other.features, features)&&(identical(other.janCode, janCode) || other.janCode == janCode)&&(identical(other.isbnCode, isbnCode) || other.isbnCode == isbnCode)&&(identical(other.labelCode, labelCode) || other.labelCode == labelCode)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,categoryId,categoryName,const DeepCollectionEquality().hash(features),janCode,isbnCode,labelCode,registeredAt,updatedAt);

@override
String toString() {
  return 'ItemModel(id: $id, name: $name, description: $description, categoryId: $categoryId, categoryName: $categoryName, features: $features, janCode: $janCode, isbnCode: $isbnCode, labelCode: $labelCode, registeredAt: $registeredAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ItemModelCopyWith<$Res>  {
  factory $ItemModelCopyWith(ItemModel value, $Res Function(ItemModel) _then) = _$ItemModelCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, String categoryId, String? categoryName, List<FeatureModel> features, String? janCode, String? isbnCode, String? labelCode, String registeredAt, String? updatedAt
});




}
/// @nodoc
class _$ItemModelCopyWithImpl<$Res>
    implements $ItemModelCopyWith<$Res> {
  _$ItemModelCopyWithImpl(this._self, this._then);

  final ItemModel _self;
  final $Res Function(ItemModel) _then;

/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? categoryId = null,Object? categoryName = freezed,Object? features = null,Object? janCode = freezed,Object? isbnCode = freezed,Object? labelCode = freezed,Object? registeredAt = null,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as List<FeatureModel>,janCode: freezed == janCode ? _self.janCode : janCode // ignore: cast_nullable_to_non_nullable
as String?,isbnCode: freezed == isbnCode ? _self.isbnCode : isbnCode // ignore: cast_nullable_to_non_nullable
as String?,labelCode: freezed == labelCode ? _self.labelCode : labelCode // ignore: cast_nullable_to_non_nullable
as String?,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ItemModel].
extension ItemModelPatterns on ItemModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ItemModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ItemModel value)  $default,){
final _that = this;
switch (_that) {
case _ItemModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ItemModel value)?  $default,){
final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String categoryId,  String? categoryName,  List<FeatureModel> features,  String? janCode,  String? isbnCode,  String? labelCode,  String registeredAt,  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.categoryId,_that.categoryName,_that.features,_that.janCode,_that.isbnCode,_that.labelCode,_that.registeredAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  String categoryId,  String? categoryName,  List<FeatureModel> features,  String? janCode,  String? isbnCode,  String? labelCode,  String registeredAt,  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ItemModel():
return $default(_that.id,_that.name,_that.description,_that.categoryId,_that.categoryName,_that.features,_that.janCode,_that.isbnCode,_that.labelCode,_that.registeredAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  String categoryId,  String? categoryName,  List<FeatureModel> features,  String? janCode,  String? isbnCode,  String? labelCode,  String registeredAt,  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ItemModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.categoryId,_that.categoryName,_that.features,_that.janCode,_that.isbnCode,_that.labelCode,_that.registeredAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ItemModel extends ItemModel {
  const _ItemModel({required this.id, required this.name, this.description, required this.categoryId, this.categoryName, final  List<FeatureModel> features = const [], this.janCode, this.isbnCode, this.labelCode, required this.registeredAt, this.updatedAt}): _features = features,super._();
  factory _ItemModel.fromJson(Map<String, dynamic> json) => _$ItemModelFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
@override final  String categoryId;
@override final  String? categoryName;
 final  List<FeatureModel> _features;
@override@JsonKey() List<FeatureModel> get features {
  if (_features is EqualUnmodifiableListView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_features);
}

@override final  String? janCode;
@override final  String? isbnCode;
@override final  String? labelCode;
@override final  String registeredAt;
@override final  String? updatedAt;

/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemModelCopyWith<_ItemModel> get copyWith => __$ItemModelCopyWithImpl<_ItemModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ItemModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ItemModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.categoryName, categoryName) || other.categoryName == categoryName)&&const DeepCollectionEquality().equals(other._features, _features)&&(identical(other.janCode, janCode) || other.janCode == janCode)&&(identical(other.isbnCode, isbnCode) || other.isbnCode == isbnCode)&&(identical(other.labelCode, labelCode) || other.labelCode == labelCode)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,categoryId,categoryName,const DeepCollectionEquality().hash(_features),janCode,isbnCode,labelCode,registeredAt,updatedAt);

@override
String toString() {
  return 'ItemModel(id: $id, name: $name, description: $description, categoryId: $categoryId, categoryName: $categoryName, features: $features, janCode: $janCode, isbnCode: $isbnCode, labelCode: $labelCode, registeredAt: $registeredAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ItemModelCopyWith<$Res> implements $ItemModelCopyWith<$Res> {
  factory _$ItemModelCopyWith(_ItemModel value, $Res Function(_ItemModel) _then) = __$ItemModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, String categoryId, String? categoryName, List<FeatureModel> features, String? janCode, String? isbnCode, String? labelCode, String registeredAt, String? updatedAt
});




}
/// @nodoc
class __$ItemModelCopyWithImpl<$Res>
    implements _$ItemModelCopyWith<$Res> {
  __$ItemModelCopyWithImpl(this._self, this._then);

  final _ItemModel _self;
  final $Res Function(_ItemModel) _then;

/// Create a copy of ItemModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? categoryId = null,Object? categoryName = freezed,Object? features = null,Object? janCode = freezed,Object? isbnCode = freezed,Object? labelCode = freezed,Object? registeredAt = null,Object? updatedAt = freezed,}) {
  return _then(_ItemModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,categoryName: freezed == categoryName ? _self.categoryName : categoryName // ignore: cast_nullable_to_non_nullable
as String?,features: null == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as List<FeatureModel>,janCode: freezed == janCode ? _self.janCode : janCode // ignore: cast_nullable_to_non_nullable
as String?,isbnCode: freezed == isbnCode ? _self.isbnCode : isbnCode // ignore: cast_nullable_to_non_nullable
as String?,labelCode: freezed == labelCode ? _self.labelCode : labelCode // ignore: cast_nullable_to_non_nullable
as String?,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as String,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
