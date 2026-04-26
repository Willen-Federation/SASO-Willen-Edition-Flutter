// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_exception.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppException {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppException);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppException()';
}


}

/// @nodoc
class $AppExceptionCopyWith<$Res>  {
$AppExceptionCopyWith(AppException _, $Res Function(AppException) __);
}


/// Adds pattern-matching-related methods to [AppException].
extension AppExceptionPatterns on AppException {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NetworkException value)?  network,TResult Function( AuthException value)?  auth,TResult Function( NotFoundException value)?  notFound,TResult Function( ValidationException value)?  validation,TResult Function( UnknownException value)?  unknown,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NetworkException() when network != null:
return network(_that);case AuthException() when auth != null:
return auth(_that);case NotFoundException() when notFound != null:
return notFound(_that);case ValidationException() when validation != null:
return validation(_that);case UnknownException() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NetworkException value)  network,required TResult Function( AuthException value)  auth,required TResult Function( NotFoundException value)  notFound,required TResult Function( ValidationException value)  validation,required TResult Function( UnknownException value)  unknown,}){
final _that = this;
switch (_that) {
case NetworkException():
return network(_that);case AuthException():
return auth(_that);case NotFoundException():
return notFound(_that);case ValidationException():
return validation(_that);case UnknownException():
return unknown(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NetworkException value)?  network,TResult? Function( AuthException value)?  auth,TResult? Function( NotFoundException value)?  notFound,TResult? Function( ValidationException value)?  validation,TResult? Function( UnknownException value)?  unknown,}){
final _that = this;
switch (_that) {
case NetworkException() when network != null:
return network(_that);case AuthException() when auth != null:
return auth(_that);case NotFoundException() when notFound != null:
return notFound(_that);case ValidationException() when validation != null:
return validation(_that);case UnknownException() when unknown != null:
return unknown(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String message,  int? statusCode)?  network,TResult Function( String message,  String? sasoCode)?  auth,TResult Function( String resource)?  notFound,TResult Function( String field,  String message)?  validation,TResult Function( String message,  Object? cause)?  unknown,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NetworkException() when network != null:
return network(_that.message,_that.statusCode);case AuthException() when auth != null:
return auth(_that.message,_that.sasoCode);case NotFoundException() when notFound != null:
return notFound(_that.resource);case ValidationException() when validation != null:
return validation(_that.field,_that.message);case UnknownException() when unknown != null:
return unknown(_that.message,_that.cause);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String message,  int? statusCode)  network,required TResult Function( String message,  String? sasoCode)  auth,required TResult Function( String resource)  notFound,required TResult Function( String field,  String message)  validation,required TResult Function( String message,  Object? cause)  unknown,}) {final _that = this;
switch (_that) {
case NetworkException():
return network(_that.message,_that.statusCode);case AuthException():
return auth(_that.message,_that.sasoCode);case NotFoundException():
return notFound(_that.resource);case ValidationException():
return validation(_that.field,_that.message);case UnknownException():
return unknown(_that.message,_that.cause);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String message,  int? statusCode)?  network,TResult? Function( String message,  String? sasoCode)?  auth,TResult? Function( String resource)?  notFound,TResult? Function( String field,  String message)?  validation,TResult? Function( String message,  Object? cause)?  unknown,}) {final _that = this;
switch (_that) {
case NetworkException() when network != null:
return network(_that.message,_that.statusCode);case AuthException() when auth != null:
return auth(_that.message,_that.sasoCode);case NotFoundException() when notFound != null:
return notFound(_that.resource);case ValidationException() when validation != null:
return validation(_that.field,_that.message);case UnknownException() when unknown != null:
return unknown(_that.message,_that.cause);case _:
  return null;

}
}

}

/// @nodoc


class NetworkException implements AppException {
  const NetworkException({required this.message, this.statusCode});
  

 final  String message;
 final  int? statusCode;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkExceptionCopyWith<NetworkException> get copyWith => _$NetworkExceptionCopyWithImpl<NetworkException>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkException&&(identical(other.message, message) || other.message == message)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode));
}


@override
int get hashCode => Object.hash(runtimeType,message,statusCode);

@override
String toString() {
  return 'AppException.network(message: $message, statusCode: $statusCode)';
}


}

/// @nodoc
abstract mixin class $NetworkExceptionCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory $NetworkExceptionCopyWith(NetworkException value, $Res Function(NetworkException) _then) = _$NetworkExceptionCopyWithImpl;
@useResult
$Res call({
 String message, int? statusCode
});




}
/// @nodoc
class _$NetworkExceptionCopyWithImpl<$Res>
    implements $NetworkExceptionCopyWith<$Res> {
  _$NetworkExceptionCopyWithImpl(this._self, this._then);

  final NetworkException _self;
  final $Res Function(NetworkException) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? statusCode = freezed,}) {
  return _then(NetworkException(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class AuthException implements AppException {
  const AuthException({required this.message, this.sasoCode});
  

 final  String message;
 final  String? sasoCode;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthExceptionCopyWith<AuthException> get copyWith => _$AuthExceptionCopyWithImpl<AuthException>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthException&&(identical(other.message, message) || other.message == message)&&(identical(other.sasoCode, sasoCode) || other.sasoCode == sasoCode));
}


@override
int get hashCode => Object.hash(runtimeType,message,sasoCode);

@override
String toString() {
  return 'AppException.auth(message: $message, sasoCode: $sasoCode)';
}


}

/// @nodoc
abstract mixin class $AuthExceptionCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory $AuthExceptionCopyWith(AuthException value, $Res Function(AuthException) _then) = _$AuthExceptionCopyWithImpl;
@useResult
$Res call({
 String message, String? sasoCode
});




}
/// @nodoc
class _$AuthExceptionCopyWithImpl<$Res>
    implements $AuthExceptionCopyWith<$Res> {
  _$AuthExceptionCopyWithImpl(this._self, this._then);

  final AuthException _self;
  final $Res Function(AuthException) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? sasoCode = freezed,}) {
  return _then(AuthException(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,sasoCode: freezed == sasoCode ? _self.sasoCode : sasoCode // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class NotFoundException implements AppException {
  const NotFoundException({required this.resource});
  

 final  String resource;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotFoundExceptionCopyWith<NotFoundException> get copyWith => _$NotFoundExceptionCopyWithImpl<NotFoundException>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFoundException&&(identical(other.resource, resource) || other.resource == resource));
}


@override
int get hashCode => Object.hash(runtimeType,resource);

@override
String toString() {
  return 'AppException.notFound(resource: $resource)';
}


}

/// @nodoc
abstract mixin class $NotFoundExceptionCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory $NotFoundExceptionCopyWith(NotFoundException value, $Res Function(NotFoundException) _then) = _$NotFoundExceptionCopyWithImpl;
@useResult
$Res call({
 String resource
});




}
/// @nodoc
class _$NotFoundExceptionCopyWithImpl<$Res>
    implements $NotFoundExceptionCopyWith<$Res> {
  _$NotFoundExceptionCopyWithImpl(this._self, this._then);

  final NotFoundException _self;
  final $Res Function(NotFoundException) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? resource = null,}) {
  return _then(NotFoundException(
resource: null == resource ? _self.resource : resource // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ValidationException implements AppException {
  const ValidationException({required this.field, required this.message});
  

 final  String field;
 final  String message;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationExceptionCopyWith<ValidationException> get copyWith => _$ValidationExceptionCopyWithImpl<ValidationException>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationException&&(identical(other.field, field) || other.field == field)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,field,message);

@override
String toString() {
  return 'AppException.validation(field: $field, message: $message)';
}


}

/// @nodoc
abstract mixin class $ValidationExceptionCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory $ValidationExceptionCopyWith(ValidationException value, $Res Function(ValidationException) _then) = _$ValidationExceptionCopyWithImpl;
@useResult
$Res call({
 String field, String message
});




}
/// @nodoc
class _$ValidationExceptionCopyWithImpl<$Res>
    implements $ValidationExceptionCopyWith<$Res> {
  _$ValidationExceptionCopyWithImpl(this._self, this._then);

  final ValidationException _self;
  final $Res Function(ValidationException) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? field = null,Object? message = null,}) {
  return _then(ValidationException(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class UnknownException implements AppException {
  const UnknownException({required this.message, this.cause});
  

 final  String message;
 final  Object? cause;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnknownExceptionCopyWith<UnknownException> get copyWith => _$UnknownExceptionCopyWithImpl<UnknownException>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnknownException&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.cause, cause));
}


@override
int get hashCode => Object.hash(runtimeType,message,const DeepCollectionEquality().hash(cause));

@override
String toString() {
  return 'AppException.unknown(message: $message, cause: $cause)';
}


}

/// @nodoc
abstract mixin class $UnknownExceptionCopyWith<$Res> implements $AppExceptionCopyWith<$Res> {
  factory $UnknownExceptionCopyWith(UnknownException value, $Res Function(UnknownException) _then) = _$UnknownExceptionCopyWithImpl;
@useResult
$Res call({
 String message, Object? cause
});




}
/// @nodoc
class _$UnknownExceptionCopyWithImpl<$Res>
    implements $UnknownExceptionCopyWith<$Res> {
  _$UnknownExceptionCopyWithImpl(this._self, this._then);

  final UnknownException _self;
  final $Res Function(UnknownException) _then;

/// Create a copy of AppException
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? cause = freezed,}) {
  return _then(UnknownException(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,cause: freezed == cause ? _self.cause : cause ,
  ));
}


}

// dart format on
