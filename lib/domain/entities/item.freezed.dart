// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Item {

 ItemId get id; String get name; String? get description; Category get category; List<Feature> get features; String? get janCode; String? get isbnCode; String? get labelCode; String? get note; DateTime get registeredAt; DateTime? get updatedAt; ItemStatus get status;
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ItemCopyWith<Item> get copyWith => _$ItemCopyWithImpl<Item>(this as Item, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Item&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.features, features)&&(identical(other.janCode, janCode) || other.janCode == janCode)&&(identical(other.isbnCode, isbnCode) || other.isbnCode == isbnCode)&&(identical(other.labelCode, labelCode) || other.labelCode == labelCode)&&(identical(other.note, note) || other.note == note)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,category,const DeepCollectionEquality().hash(features),janCode,isbnCode,labelCode,note,registeredAt,updatedAt,status);

@override
String toString() {
  return 'Item(id: $id, name: $name, description: $description, category: $category, features: $features, janCode: $janCode, isbnCode: $isbnCode, labelCode: $labelCode, note: $note, registeredAt: $registeredAt, updatedAt: $updatedAt, status: $status)';
}


}

/// @nodoc
abstract mixin class $ItemCopyWith<$Res>  {
  factory $ItemCopyWith(Item value, $Res Function(Item) _then) = _$ItemCopyWithImpl;
@useResult
$Res call({
 ItemId id, String name, String? description, Category category, List<Feature> features, String? janCode, String? isbnCode, String? labelCode, String? note, DateTime registeredAt, DateTime? updatedAt, ItemStatus status
});


$CategoryCopyWith<$Res> get category;

}
/// @nodoc
class _$ItemCopyWithImpl<$Res>
    implements $ItemCopyWith<$Res> {
  _$ItemCopyWithImpl(this._self, this._then);

  final Item _self;
  final $Res Function(Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? category = null,Object? features = null,Object? janCode = freezed,Object? isbnCode = freezed,Object? labelCode = freezed,Object? note = freezed,Object? registeredAt = null,Object? updatedAt = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ItemId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,features: null == features ? _self.features : features // ignore: cast_nullable_to_non_nullable
as List<Feature>,janCode: freezed == janCode ? _self.janCode : janCode // ignore: cast_nullable_to_non_nullable
as String?,isbnCode: freezed == isbnCode ? _self.isbnCode : isbnCode // ignore: cast_nullable_to_non_nullable
as String?,labelCode: freezed == labelCode ? _self.labelCode : labelCode // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItemStatus,
  ));
}
/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}


/// Adds pattern-matching-related methods to [Item].
extension ItemPatterns on Item {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Item value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Item value)  $default,){
final _that = this;
switch (_that) {
case _Item():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Item value)?  $default,){
final _that = this;
switch (_that) {
case _Item() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ItemId id,  String name,  String? description,  Category category,  List<Feature> features,  String? janCode,  String? isbnCode,  String? labelCode,  String? note,  DateTime registeredAt,  DateTime? updatedAt,  ItemStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.category,_that.features,_that.janCode,_that.isbnCode,_that.labelCode,_that.note,_that.registeredAt,_that.updatedAt,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ItemId id,  String name,  String? description,  Category category,  List<Feature> features,  String? janCode,  String? isbnCode,  String? labelCode,  String? note,  DateTime registeredAt,  DateTime? updatedAt,  ItemStatus status)  $default,) {final _that = this;
switch (_that) {
case _Item():
return $default(_that.id,_that.name,_that.description,_that.category,_that.features,_that.janCode,_that.isbnCode,_that.labelCode,_that.note,_that.registeredAt,_that.updatedAt,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ItemId id,  String name,  String? description,  Category category,  List<Feature> features,  String? janCode,  String? isbnCode,  String? labelCode,  String? note,  DateTime registeredAt,  DateTime? updatedAt,  ItemStatus status)?  $default,) {final _that = this;
switch (_that) {
case _Item() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.category,_that.features,_that.janCode,_that.isbnCode,_that.labelCode,_that.note,_that.registeredAt,_that.updatedAt,_that.status);case _:
  return null;

}
}

}

/// @nodoc


class _Item extends Item {
  const _Item({required this.id, required this.name, this.description, required this.category, final  List<Feature> features = const [], this.janCode, this.isbnCode, this.labelCode, this.note, required this.registeredAt, this.updatedAt, this.status = ItemStatus.active}): _features = features,super._();
  

@override final  ItemId id;
@override final  String name;
@override final  String? description;
@override final  Category category;
 final  List<Feature> _features;
@override@JsonKey() List<Feature> get features {
  if (_features is EqualUnmodifiableListView) return _features;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_features);
}

@override final  String? janCode;
@override final  String? isbnCode;
@override final  String? labelCode;
@override final  String? note;
@override final  DateTime registeredAt;
@override final  DateTime? updatedAt;
@override@JsonKey() final  ItemStatus status;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ItemCopyWith<_Item> get copyWith => __$ItemCopyWithImpl<_Item>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Item&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._features, _features)&&(identical(other.janCode, janCode) || other.janCode == janCode)&&(identical(other.isbnCode, isbnCode) || other.isbnCode == isbnCode)&&(identical(other.labelCode, labelCode) || other.labelCode == labelCode)&&(identical(other.note, note) || other.note == note)&&(identical(other.registeredAt, registeredAt) || other.registeredAt == registeredAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.status, status) || other.status == status));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,description,category,const DeepCollectionEquality().hash(_features),janCode,isbnCode,labelCode,note,registeredAt,updatedAt,status);

@override
String toString() {
  return 'Item(id: $id, name: $name, description: $description, category: $category, features: $features, janCode: $janCode, isbnCode: $isbnCode, labelCode: $labelCode, note: $note, registeredAt: $registeredAt, updatedAt: $updatedAt, status: $status)';
}


}

/// @nodoc
abstract mixin class _$ItemCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$ItemCopyWith(_Item value, $Res Function(_Item) _then) = __$ItemCopyWithImpl;
@override @useResult
$Res call({
 ItemId id, String name, String? description, Category category, List<Feature> features, String? janCode, String? isbnCode, String? labelCode, String? note, DateTime registeredAt, DateTime? updatedAt, ItemStatus status
});


@override $CategoryCopyWith<$Res> get category;

}
/// @nodoc
class __$ItemCopyWithImpl<$Res>
    implements _$ItemCopyWith<$Res> {
  __$ItemCopyWithImpl(this._self, this._then);

  final _Item _self;
  final $Res Function(_Item) _then;

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? category = null,Object? features = null,Object? janCode = freezed,Object? isbnCode = freezed,Object? labelCode = freezed,Object? note = freezed,Object? registeredAt = null,Object? updatedAt = freezed,Object? status = null,}) {
  return _then(_Item(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as ItemId,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,features: null == features ? _self._features : features // ignore: cast_nullable_to_non_nullable
as List<Feature>,janCode: freezed == janCode ? _self.janCode : janCode // ignore: cast_nullable_to_non_nullable
as String?,isbnCode: freezed == isbnCode ? _self.isbnCode : isbnCode // ignore: cast_nullable_to_non_nullable
as String?,labelCode: freezed == labelCode ? _self.labelCode : labelCode // ignore: cast_nullable_to_non_nullable
as String?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,registeredAt: null == registeredAt ? _self.registeredAt : registeredAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItemStatus,
  ));
}

/// Create a copy of Item
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CategoryCopyWith<$Res> get category {
  
  return $CategoryCopyWith<$Res>(_self.category, (value) {
    return _then(_self.copyWith(category: value));
  });
}
}

// dart format on
