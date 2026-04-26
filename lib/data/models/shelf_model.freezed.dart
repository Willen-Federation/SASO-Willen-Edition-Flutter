// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'shelf_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ShelfModel {

 String get id; String? get label; String? get location; List<String> get itemIds;
/// Create a copy of ShelfModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ShelfModelCopyWith<ShelfModel> get copyWith => _$ShelfModelCopyWithImpl<ShelfModel>(this as ShelfModel, _$identity);

  /// Serializes this ShelfModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ShelfModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.itemIds, itemIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,location,const DeepCollectionEquality().hash(itemIds));

@override
String toString() {
  return 'ShelfModel(id: $id, label: $label, location: $location, itemIds: $itemIds)';
}


}

/// @nodoc
abstract mixin class $ShelfModelCopyWith<$Res>  {
  factory $ShelfModelCopyWith(ShelfModel value, $Res Function(ShelfModel) _then) = _$ShelfModelCopyWithImpl;
@useResult
$Res call({
 String id, String? label, String? location, List<String> itemIds
});




}
/// @nodoc
class _$ShelfModelCopyWithImpl<$Res>
    implements $ShelfModelCopyWith<$Res> {
  _$ShelfModelCopyWithImpl(this._self, this._then);

  final ShelfModel _self;
  final $Res Function(ShelfModel) _then;

/// Create a copy of ShelfModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? label = freezed,Object? location = freezed,Object? itemIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,itemIds: null == itemIds ? _self.itemIds : itemIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ShelfModel].
extension ShelfModelPatterns on ShelfModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ShelfModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ShelfModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ShelfModel value)  $default,){
final _that = this;
switch (_that) {
case _ShelfModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ShelfModel value)?  $default,){
final _that = this;
switch (_that) {
case _ShelfModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? label,  String? location,  List<String> itemIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ShelfModel() when $default != null:
return $default(_that.id,_that.label,_that.location,_that.itemIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? label,  String? location,  List<String> itemIds)  $default,) {final _that = this;
switch (_that) {
case _ShelfModel():
return $default(_that.id,_that.label,_that.location,_that.itemIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? label,  String? location,  List<String> itemIds)?  $default,) {final _that = this;
switch (_that) {
case _ShelfModel() when $default != null:
return $default(_that.id,_that.label,_that.location,_that.itemIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ShelfModel extends ShelfModel {
  const _ShelfModel({required this.id, this.label, this.location, final  List<String> itemIds = const []}): _itemIds = itemIds,super._();
  factory _ShelfModel.fromJson(Map<String, dynamic> json) => _$ShelfModelFromJson(json);

@override final  String id;
@override final  String? label;
@override final  String? location;
 final  List<String> _itemIds;
@override@JsonKey() List<String> get itemIds {
  if (_itemIds is EqualUnmodifiableListView) return _itemIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_itemIds);
}


/// Create a copy of ShelfModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ShelfModelCopyWith<_ShelfModel> get copyWith => __$ShelfModelCopyWithImpl<_ShelfModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ShelfModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ShelfModel&&(identical(other.id, id) || other.id == id)&&(identical(other.label, label) || other.label == label)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other._itemIds, _itemIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,label,location,const DeepCollectionEquality().hash(_itemIds));

@override
String toString() {
  return 'ShelfModel(id: $id, label: $label, location: $location, itemIds: $itemIds)';
}


}

/// @nodoc
abstract mixin class _$ShelfModelCopyWith<$Res> implements $ShelfModelCopyWith<$Res> {
  factory _$ShelfModelCopyWith(_ShelfModel value, $Res Function(_ShelfModel) _then) = __$ShelfModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String? label, String? location, List<String> itemIds
});




}
/// @nodoc
class __$ShelfModelCopyWithImpl<$Res>
    implements _$ShelfModelCopyWith<$Res> {
  __$ShelfModelCopyWithImpl(this._self, this._then);

  final _ShelfModel _self;
  final $Res Function(_ShelfModel) _then;

/// Create a copy of ShelfModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? label = freezed,Object? location = freezed,Object? itemIds = null,}) {
  return _then(_ShelfModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,label: freezed == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,itemIds: null == itemIds ? _self._itemIds : itemIds // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
