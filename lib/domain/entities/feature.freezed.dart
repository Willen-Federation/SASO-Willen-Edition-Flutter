// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'feature.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Feature {

 FeatureCode get code; String get colorCode; String get sizeCode; String? get colorLabel; String? get sizeLabel; int get stockCount; ShelfId? get shelfId;
/// Create a copy of Feature
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeatureCopyWith<Feature> get copyWith => _$FeatureCopyWithImpl<Feature>(this as Feature, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Feature&&(identical(other.code, code) || other.code == code)&&(identical(other.colorCode, colorCode) || other.colorCode == colorCode)&&(identical(other.sizeCode, sizeCode) || other.sizeCode == sizeCode)&&(identical(other.colorLabel, colorLabel) || other.colorLabel == colorLabel)&&(identical(other.sizeLabel, sizeLabel) || other.sizeLabel == sizeLabel)&&(identical(other.stockCount, stockCount) || other.stockCount == stockCount)&&(identical(other.shelfId, shelfId) || other.shelfId == shelfId));
}


@override
int get hashCode => Object.hash(runtimeType,code,colorCode,sizeCode,colorLabel,sizeLabel,stockCount,shelfId);

@override
String toString() {
  return 'Feature(code: $code, colorCode: $colorCode, sizeCode: $sizeCode, colorLabel: $colorLabel, sizeLabel: $sizeLabel, stockCount: $stockCount, shelfId: $shelfId)';
}


}

/// @nodoc
abstract mixin class $FeatureCopyWith<$Res>  {
  factory $FeatureCopyWith(Feature value, $Res Function(Feature) _then) = _$FeatureCopyWithImpl;
@useResult
$Res call({
 FeatureCode code, String colorCode, String sizeCode, String? colorLabel, String? sizeLabel, int stockCount, ShelfId? shelfId
});




}
/// @nodoc
class _$FeatureCopyWithImpl<$Res>
    implements $FeatureCopyWith<$Res> {
  _$FeatureCopyWithImpl(this._self, this._then);

  final Feature _self;
  final $Res Function(Feature) _then;

/// Create a copy of Feature
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? colorCode = null,Object? sizeCode = null,Object? colorLabel = freezed,Object? sizeLabel = freezed,Object? stockCount = null,Object? shelfId = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as FeatureCode,colorCode: null == colorCode ? _self.colorCode : colorCode // ignore: cast_nullable_to_non_nullable
as String,sizeCode: null == sizeCode ? _self.sizeCode : sizeCode // ignore: cast_nullable_to_non_nullable
as String,colorLabel: freezed == colorLabel ? _self.colorLabel : colorLabel // ignore: cast_nullable_to_non_nullable
as String?,sizeLabel: freezed == sizeLabel ? _self.sizeLabel : sizeLabel // ignore: cast_nullable_to_non_nullable
as String?,stockCount: null == stockCount ? _self.stockCount : stockCount // ignore: cast_nullable_to_non_nullable
as int,shelfId: freezed == shelfId ? _self.shelfId : shelfId // ignore: cast_nullable_to_non_nullable
as ShelfId?,
  ));
}

}


/// Adds pattern-matching-related methods to [Feature].
extension FeaturePatterns on Feature {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Feature value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Feature() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Feature value)  $default,){
final _that = this;
switch (_that) {
case _Feature():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Feature value)?  $default,){
final _that = this;
switch (_that) {
case _Feature() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FeatureCode code,  String colorCode,  String sizeCode,  String? colorLabel,  String? sizeLabel,  int stockCount,  ShelfId? shelfId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Feature() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FeatureCode code,  String colorCode,  String sizeCode,  String? colorLabel,  String? sizeLabel,  int stockCount,  ShelfId? shelfId)  $default,) {final _that = this;
switch (_that) {
case _Feature():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FeatureCode code,  String colorCode,  String sizeCode,  String? colorLabel,  String? sizeLabel,  int stockCount,  ShelfId? shelfId)?  $default,) {final _that = this;
switch (_that) {
case _Feature() when $default != null:
return $default(_that.code,_that.colorCode,_that.sizeCode,_that.colorLabel,_that.sizeLabel,_that.stockCount,_that.shelfId);case _:
  return null;

}
}

}

/// @nodoc


class _Feature extends Feature {
  const _Feature({required this.code, required this.colorCode, required this.sizeCode, this.colorLabel, this.sizeLabel, this.stockCount = 0, this.shelfId}): super._();
  

@override final  FeatureCode code;
@override final  String colorCode;
@override final  String sizeCode;
@override final  String? colorLabel;
@override final  String? sizeLabel;
@override@JsonKey() final  int stockCount;
@override final  ShelfId? shelfId;

/// Create a copy of Feature
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeatureCopyWith<_Feature> get copyWith => __$FeatureCopyWithImpl<_Feature>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Feature&&(identical(other.code, code) || other.code == code)&&(identical(other.colorCode, colorCode) || other.colorCode == colorCode)&&(identical(other.sizeCode, sizeCode) || other.sizeCode == sizeCode)&&(identical(other.colorLabel, colorLabel) || other.colorLabel == colorLabel)&&(identical(other.sizeLabel, sizeLabel) || other.sizeLabel == sizeLabel)&&(identical(other.stockCount, stockCount) || other.stockCount == stockCount)&&(identical(other.shelfId, shelfId) || other.shelfId == shelfId));
}


@override
int get hashCode => Object.hash(runtimeType,code,colorCode,sizeCode,colorLabel,sizeLabel,stockCount,shelfId);

@override
String toString() {
  return 'Feature(code: $code, colorCode: $colorCode, sizeCode: $sizeCode, colorLabel: $colorLabel, sizeLabel: $sizeLabel, stockCount: $stockCount, shelfId: $shelfId)';
}


}

/// @nodoc
abstract mixin class _$FeatureCopyWith<$Res> implements $FeatureCopyWith<$Res> {
  factory _$FeatureCopyWith(_Feature value, $Res Function(_Feature) _then) = __$FeatureCopyWithImpl;
@override @useResult
$Res call({
 FeatureCode code, String colorCode, String sizeCode, String? colorLabel, String? sizeLabel, int stockCount, ShelfId? shelfId
});




}
/// @nodoc
class __$FeatureCopyWithImpl<$Res>
    implements _$FeatureCopyWith<$Res> {
  __$FeatureCopyWithImpl(this._self, this._then);

  final _Feature _self;
  final $Res Function(_Feature) _then;

/// Create a copy of Feature
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? colorCode = null,Object? sizeCode = null,Object? colorLabel = freezed,Object? sizeLabel = freezed,Object? stockCount = null,Object? shelfId = freezed,}) {
  return _then(_Feature(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as FeatureCode,colorCode: null == colorCode ? _self.colorCode : colorCode // ignore: cast_nullable_to_non_nullable
as String,sizeCode: null == sizeCode ? _self.sizeCode : sizeCode // ignore: cast_nullable_to_non_nullable
as String,colorLabel: freezed == colorLabel ? _self.colorLabel : colorLabel // ignore: cast_nullable_to_non_nullable
as String?,sizeLabel: freezed == sizeLabel ? _self.sizeLabel : sizeLabel // ignore: cast_nullable_to_non_nullable
as String?,stockCount: null == stockCount ? _self.stockCount : stockCount // ignore: cast_nullable_to_non_nullable
as int,shelfId: freezed == shelfId ? _self.shelfId : shelfId // ignore: cast_nullable_to_non_nullable
as ShelfId?,
  ));
}


}

// dart format on
