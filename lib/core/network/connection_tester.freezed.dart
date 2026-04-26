// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'connection_tester.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ConnectionTestResult {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionTestResult);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ConnectionTestResult()';
}


}

/// @nodoc
class $ConnectionTestResultCopyWith<$Res>  {
$ConnectionTestResultCopyWith(ConnectionTestResult _, $Res Function(ConnectionTestResult) __);
}


/// Adds pattern-matching-related methods to [ConnectionTestResult].
extension ConnectionTestResultPatterns on ConnectionTestResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ConnectionTestSuccess value)?  success,TResult Function( ConnectionTestFailure value)?  failure,TResult Function( ConnectionTestTimeout value)?  timeout,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ConnectionTestSuccess() when success != null:
return success(_that);case ConnectionTestFailure() when failure != null:
return failure(_that);case ConnectionTestTimeout() when timeout != null:
return timeout(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ConnectionTestSuccess value)  success,required TResult Function( ConnectionTestFailure value)  failure,required TResult Function( ConnectionTestTimeout value)  timeout,}){
final _that = this;
switch (_that) {
case ConnectionTestSuccess():
return success(_that);case ConnectionTestFailure():
return failure(_that);case ConnectionTestTimeout():
return timeout(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ConnectionTestSuccess value)?  success,TResult? Function( ConnectionTestFailure value)?  failure,TResult? Function( ConnectionTestTimeout value)?  timeout,}){
final _that = this;
switch (_that) {
case ConnectionTestSuccess() when success != null:
return success(_that);case ConnectionTestFailure() when failure != null:
return failure(_that);case ConnectionTestTimeout() when timeout != null:
return timeout(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( Duration latency,  int statusCode)?  success,TResult Function( String message,  int? statusCode)?  failure,TResult Function( Duration timeout)?  timeout,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ConnectionTestSuccess() when success != null:
return success(_that.latency,_that.statusCode);case ConnectionTestFailure() when failure != null:
return failure(_that.message,_that.statusCode);case ConnectionTestTimeout() when timeout != null:
return timeout(_that.timeout);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( Duration latency,  int statusCode)  success,required TResult Function( String message,  int? statusCode)  failure,required TResult Function( Duration timeout)  timeout,}) {final _that = this;
switch (_that) {
case ConnectionTestSuccess():
return success(_that.latency,_that.statusCode);case ConnectionTestFailure():
return failure(_that.message,_that.statusCode);case ConnectionTestTimeout():
return timeout(_that.timeout);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( Duration latency,  int statusCode)?  success,TResult? Function( String message,  int? statusCode)?  failure,TResult? Function( Duration timeout)?  timeout,}) {final _that = this;
switch (_that) {
case ConnectionTestSuccess() when success != null:
return success(_that.latency,_that.statusCode);case ConnectionTestFailure() when failure != null:
return failure(_that.message,_that.statusCode);case ConnectionTestTimeout() when timeout != null:
return timeout(_that.timeout);case _:
  return null;

}
}

}

/// @nodoc


class ConnectionTestSuccess implements ConnectionTestResult {
  const ConnectionTestSuccess({required this.latency, required this.statusCode});
  

 final  Duration latency;
 final  int statusCode;

/// Create a copy of ConnectionTestResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionTestSuccessCopyWith<ConnectionTestSuccess> get copyWith => _$ConnectionTestSuccessCopyWithImpl<ConnectionTestSuccess>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionTestSuccess&&(identical(other.latency, latency) || other.latency == latency)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode));
}


@override
int get hashCode => Object.hash(runtimeType,latency,statusCode);

@override
String toString() {
  return 'ConnectionTestResult.success(latency: $latency, statusCode: $statusCode)';
}


}

/// @nodoc
abstract mixin class $ConnectionTestSuccessCopyWith<$Res> implements $ConnectionTestResultCopyWith<$Res> {
  factory $ConnectionTestSuccessCopyWith(ConnectionTestSuccess value, $Res Function(ConnectionTestSuccess) _then) = _$ConnectionTestSuccessCopyWithImpl;
@useResult
$Res call({
 Duration latency, int statusCode
});




}
/// @nodoc
class _$ConnectionTestSuccessCopyWithImpl<$Res>
    implements $ConnectionTestSuccessCopyWith<$Res> {
  _$ConnectionTestSuccessCopyWithImpl(this._self, this._then);

  final ConnectionTestSuccess _self;
  final $Res Function(ConnectionTestSuccess) _then;

/// Create a copy of ConnectionTestResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? latency = null,Object? statusCode = null,}) {
  return _then(ConnectionTestSuccess(
latency: null == latency ? _self.latency : latency // ignore: cast_nullable_to_non_nullable
as Duration,statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class ConnectionTestFailure implements ConnectionTestResult {
  const ConnectionTestFailure({required this.message, this.statusCode});
  

 final  String message;
 final  int? statusCode;

/// Create a copy of ConnectionTestResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionTestFailureCopyWith<ConnectionTestFailure> get copyWith => _$ConnectionTestFailureCopyWithImpl<ConnectionTestFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionTestFailure&&(identical(other.message, message) || other.message == message)&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode));
}


@override
int get hashCode => Object.hash(runtimeType,message,statusCode);

@override
String toString() {
  return 'ConnectionTestResult.failure(message: $message, statusCode: $statusCode)';
}


}

/// @nodoc
abstract mixin class $ConnectionTestFailureCopyWith<$Res> implements $ConnectionTestResultCopyWith<$Res> {
  factory $ConnectionTestFailureCopyWith(ConnectionTestFailure value, $Res Function(ConnectionTestFailure) _then) = _$ConnectionTestFailureCopyWithImpl;
@useResult
$Res call({
 String message, int? statusCode
});




}
/// @nodoc
class _$ConnectionTestFailureCopyWithImpl<$Res>
    implements $ConnectionTestFailureCopyWith<$Res> {
  _$ConnectionTestFailureCopyWithImpl(this._self, this._then);

  final ConnectionTestFailure _self;
  final $Res Function(ConnectionTestFailure) _then;

/// Create a copy of ConnectionTestResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? message = null,Object? statusCode = freezed,}) {
  return _then(ConnectionTestFailure(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,statusCode: freezed == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc


class ConnectionTestTimeout implements ConnectionTestResult {
  const ConnectionTestTimeout({required this.timeout});
  

 final  Duration timeout;

/// Create a copy of ConnectionTestResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConnectionTestTimeoutCopyWith<ConnectionTestTimeout> get copyWith => _$ConnectionTestTimeoutCopyWithImpl<ConnectionTestTimeout>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConnectionTestTimeout&&(identical(other.timeout, timeout) || other.timeout == timeout));
}


@override
int get hashCode => Object.hash(runtimeType,timeout);

@override
String toString() {
  return 'ConnectionTestResult.timeout(timeout: $timeout)';
}


}

/// @nodoc
abstract mixin class $ConnectionTestTimeoutCopyWith<$Res> implements $ConnectionTestResultCopyWith<$Res> {
  factory $ConnectionTestTimeoutCopyWith(ConnectionTestTimeout value, $Res Function(ConnectionTestTimeout) _then) = _$ConnectionTestTimeoutCopyWithImpl;
@useResult
$Res call({
 Duration timeout
});




}
/// @nodoc
class _$ConnectionTestTimeoutCopyWithImpl<$Res>
    implements $ConnectionTestTimeoutCopyWith<$Res> {
  _$ConnectionTestTimeoutCopyWithImpl(this._self, this._then);

  final ConnectionTestTimeout _self;
  final $Res Function(ConnectionTestTimeout) _then;

/// Create a copy of ConnectionTestResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? timeout = null,}) {
  return _then(ConnectionTestTimeout(
timeout: null == timeout ? _self.timeout : timeout // ignore: cast_nullable_to_non_nullable
as Duration,
  ));
}


}

// dart format on
