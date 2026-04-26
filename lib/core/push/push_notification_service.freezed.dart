// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'push_notification_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PushMessage {

 String get title; String get body; Map<String, String>? get data; String? get imageUrl;
/// Create a copy of PushMessage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PushMessageCopyWith<PushMessage> get copyWith => _$PushMessageCopyWithImpl<PushMessage>(this as PushMessage, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PushMessage&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other.data, data)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}


@override
int get hashCode => Object.hash(runtimeType,title,body,const DeepCollectionEquality().hash(data),imageUrl);

@override
String toString() {
  return 'PushMessage(title: $title, body: $body, data: $data, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class $PushMessageCopyWith<$Res>  {
  factory $PushMessageCopyWith(PushMessage value, $Res Function(PushMessage) _then) = _$PushMessageCopyWithImpl;
@useResult
$Res call({
 String title, String body, Map<String, String>? data, String? imageUrl
});




}
/// @nodoc
class _$PushMessageCopyWithImpl<$Res>
    implements $PushMessageCopyWith<$Res> {
  _$PushMessageCopyWithImpl(this._self, this._then);

  final PushMessage _self;
  final $Res Function(PushMessage) _then;

/// Create a copy of PushMessage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? body = null,Object? data = freezed,Object? imageUrl = freezed,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self.data : data // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PushMessage].
extension PushMessagePatterns on PushMessage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PushMessage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PushMessage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PushMessage value)  $default,){
final _that = this;
switch (_that) {
case _PushMessage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PushMessage value)?  $default,){
final _that = this;
switch (_that) {
case _PushMessage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String body,  Map<String, String>? data,  String? imageUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PushMessage() when $default != null:
return $default(_that.title,_that.body,_that.data,_that.imageUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String body,  Map<String, String>? data,  String? imageUrl)  $default,) {final _that = this;
switch (_that) {
case _PushMessage():
return $default(_that.title,_that.body,_that.data,_that.imageUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String body,  Map<String, String>? data,  String? imageUrl)?  $default,) {final _that = this;
switch (_that) {
case _PushMessage() when $default != null:
return $default(_that.title,_that.body,_that.data,_that.imageUrl);case _:
  return null;

}
}

}

/// @nodoc


class _PushMessage implements PushMessage {
  const _PushMessage({required this.title, required this.body, final  Map<String, String>? data, this.imageUrl}): _data = data;
  

@override final  String title;
@override final  String body;
 final  Map<String, String>? _data;
@override Map<String, String>? get data {
  final value = _data;
  if (value == null) return null;
  if (_data is EqualUnmodifiableMapView) return _data;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? imageUrl;

/// Create a copy of PushMessage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PushMessageCopyWith<_PushMessage> get copyWith => __$PushMessageCopyWithImpl<_PushMessage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PushMessage&&(identical(other.title, title) || other.title == title)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other._data, _data)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl));
}


@override
int get hashCode => Object.hash(runtimeType,title,body,const DeepCollectionEquality().hash(_data),imageUrl);

@override
String toString() {
  return 'PushMessage(title: $title, body: $body, data: $data, imageUrl: $imageUrl)';
}


}

/// @nodoc
abstract mixin class _$PushMessageCopyWith<$Res> implements $PushMessageCopyWith<$Res> {
  factory _$PushMessageCopyWith(_PushMessage value, $Res Function(_PushMessage) _then) = __$PushMessageCopyWithImpl;
@override @useResult
$Res call({
 String title, String body, Map<String, String>? data, String? imageUrl
});




}
/// @nodoc
class __$PushMessageCopyWithImpl<$Res>
    implements _$PushMessageCopyWith<$Res> {
  __$PushMessageCopyWithImpl(this._self, this._then);

  final _PushMessage _self;
  final $Res Function(_PushMessage) _then;

/// Create a copy of PushMessage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? body = null,Object? data = freezed,Object? imageUrl = freezed,}) {
  return _then(_PushMessage(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,data: freezed == data ? _self._data : data // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
