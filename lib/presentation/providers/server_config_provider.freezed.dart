// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'server_config_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ServerConfig {

 String get baseUrl; ApiMode get apiMode; String? get sessionCookie; String? get jwtToken; String? get refreshToken; int? get deviceId; bool get offlineMode; bool get aiAutofillEnabled;
/// Create a copy of ServerConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerConfigCopyWith<ServerConfig> get copyWith => _$ServerConfigCopyWithImpl<ServerConfig>(this as ServerConfig, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerConfig&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.apiMode, apiMode) || other.apiMode == apiMode)&&(identical(other.sessionCookie, sessionCookie) || other.sessionCookie == sessionCookie)&&(identical(other.jwtToken, jwtToken) || other.jwtToken == jwtToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.offlineMode, offlineMode) || other.offlineMode == offlineMode)&&(identical(other.aiAutofillEnabled, aiAutofillEnabled) || other.aiAutofillEnabled == aiAutofillEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,baseUrl,apiMode,sessionCookie,jwtToken,refreshToken,deviceId,offlineMode,aiAutofillEnabled);

@override
String toString() {
  return 'ServerConfig(baseUrl: $baseUrl, apiMode: $apiMode, sessionCookie: $sessionCookie, jwtToken: $jwtToken, refreshToken: $refreshToken, deviceId: $deviceId, offlineMode: $offlineMode, aiAutofillEnabled: $aiAutofillEnabled)';
}


}

/// @nodoc
abstract mixin class $ServerConfigCopyWith<$Res>  {
  factory $ServerConfigCopyWith(ServerConfig value, $Res Function(ServerConfig) _then) = _$ServerConfigCopyWithImpl;
@useResult
$Res call({
 String baseUrl, ApiMode apiMode, String? sessionCookie, String? jwtToken, String? refreshToken, int? deviceId, bool offlineMode, bool aiAutofillEnabled
});




}
/// @nodoc
class _$ServerConfigCopyWithImpl<$Res>
    implements $ServerConfigCopyWith<$Res> {
  _$ServerConfigCopyWithImpl(this._self, this._then);

  final ServerConfig _self;
  final $Res Function(ServerConfig) _then;

/// Create a copy of ServerConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? baseUrl = null,Object? apiMode = null,Object? sessionCookie = freezed,Object? jwtToken = freezed,Object? refreshToken = freezed,Object? deviceId = freezed,Object? offlineMode = null,Object? aiAutofillEnabled = null,}) {
  return _then(_self.copyWith(
baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,apiMode: null == apiMode ? _self.apiMode : apiMode // ignore: cast_nullable_to_non_nullable
as ApiMode,sessionCookie: freezed == sessionCookie ? _self.sessionCookie : sessionCookie // ignore: cast_nullable_to_non_nullable
as String?,jwtToken: freezed == jwtToken ? _self.jwtToken : jwtToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as int?,offlineMode: null == offlineMode ? _self.offlineMode : offlineMode // ignore: cast_nullable_to_non_nullable
as bool,aiAutofillEnabled: null == aiAutofillEnabled ? _self.aiAutofillEnabled : aiAutofillEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerConfig].
extension ServerConfigPatterns on ServerConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerConfig value)  $default,){
final _that = this;
switch (_that) {
case _ServerConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerConfig value)?  $default,){
final _that = this;
switch (_that) {
case _ServerConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String baseUrl,  ApiMode apiMode,  String? sessionCookie,  String? jwtToken,  String? refreshToken,  int? deviceId,  bool offlineMode,  bool aiAutofillEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerConfig() when $default != null:
return $default(_that.baseUrl,_that.apiMode,_that.sessionCookie,_that.jwtToken,_that.refreshToken,_that.deviceId,_that.offlineMode,_that.aiAutofillEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String baseUrl,  ApiMode apiMode,  String? sessionCookie,  String? jwtToken,  String? refreshToken,  int? deviceId,  bool offlineMode,  bool aiAutofillEnabled)  $default,) {final _that = this;
switch (_that) {
case _ServerConfig():
return $default(_that.baseUrl,_that.apiMode,_that.sessionCookie,_that.jwtToken,_that.refreshToken,_that.deviceId,_that.offlineMode,_that.aiAutofillEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String baseUrl,  ApiMode apiMode,  String? sessionCookie,  String? jwtToken,  String? refreshToken,  int? deviceId,  bool offlineMode,  bool aiAutofillEnabled)?  $default,) {final _that = this;
switch (_that) {
case _ServerConfig() when $default != null:
return $default(_that.baseUrl,_that.apiMode,_that.sessionCookie,_that.jwtToken,_that.refreshToken,_that.deviceId,_that.offlineMode,_that.aiAutofillEnabled);case _:
  return null;

}
}

}

/// @nodoc


class _ServerConfig implements ServerConfig {
  const _ServerConfig({this.baseUrl = '', this.apiMode = ApiMode.mock, this.sessionCookie, this.jwtToken, this.refreshToken, this.deviceId, this.offlineMode = false, this.aiAutofillEnabled = false});
  

@override@JsonKey() final  String baseUrl;
@override@JsonKey() final  ApiMode apiMode;
@override final  String? sessionCookie;
@override final  String? jwtToken;
@override final  String? refreshToken;
@override final  int? deviceId;
@override@JsonKey() final  bool offlineMode;
@override@JsonKey() final  bool aiAutofillEnabled;

/// Create a copy of ServerConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerConfigCopyWith<_ServerConfig> get copyWith => __$ServerConfigCopyWithImpl<_ServerConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerConfig&&(identical(other.baseUrl, baseUrl) || other.baseUrl == baseUrl)&&(identical(other.apiMode, apiMode) || other.apiMode == apiMode)&&(identical(other.sessionCookie, sessionCookie) || other.sessionCookie == sessionCookie)&&(identical(other.jwtToken, jwtToken) || other.jwtToken == jwtToken)&&(identical(other.refreshToken, refreshToken) || other.refreshToken == refreshToken)&&(identical(other.deviceId, deviceId) || other.deviceId == deviceId)&&(identical(other.offlineMode, offlineMode) || other.offlineMode == offlineMode)&&(identical(other.aiAutofillEnabled, aiAutofillEnabled) || other.aiAutofillEnabled == aiAutofillEnabled));
}


@override
int get hashCode => Object.hash(runtimeType,baseUrl,apiMode,sessionCookie,jwtToken,refreshToken,deviceId,offlineMode,aiAutofillEnabled);

@override
String toString() {
  return 'ServerConfig(baseUrl: $baseUrl, apiMode: $apiMode, sessionCookie: $sessionCookie, jwtToken: $jwtToken, refreshToken: $refreshToken, deviceId: $deviceId, offlineMode: $offlineMode, aiAutofillEnabled: $aiAutofillEnabled)';
}


}

/// @nodoc
abstract mixin class _$ServerConfigCopyWith<$Res> implements $ServerConfigCopyWith<$Res> {
  factory _$ServerConfigCopyWith(_ServerConfig value, $Res Function(_ServerConfig) _then) = __$ServerConfigCopyWithImpl;
@override @useResult
$Res call({
 String baseUrl, ApiMode apiMode, String? sessionCookie, String? jwtToken, String? refreshToken, int? deviceId, bool offlineMode, bool aiAutofillEnabled
});




}
/// @nodoc
class __$ServerConfigCopyWithImpl<$Res>
    implements _$ServerConfigCopyWith<$Res> {
  __$ServerConfigCopyWithImpl(this._self, this._then);

  final _ServerConfig _self;
  final $Res Function(_ServerConfig) _then;

/// Create a copy of ServerConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? baseUrl = null,Object? apiMode = null,Object? sessionCookie = freezed,Object? jwtToken = freezed,Object? refreshToken = freezed,Object? deviceId = freezed,Object? offlineMode = null,Object? aiAutofillEnabled = null,}) {
  return _then(_ServerConfig(
baseUrl: null == baseUrl ? _self.baseUrl : baseUrl // ignore: cast_nullable_to_non_nullable
as String,apiMode: null == apiMode ? _self.apiMode : apiMode // ignore: cast_nullable_to_non_nullable
as ApiMode,sessionCookie: freezed == sessionCookie ? _self.sessionCookie : sessionCookie // ignore: cast_nullable_to_non_nullable
as String?,jwtToken: freezed == jwtToken ? _self.jwtToken : jwtToken // ignore: cast_nullable_to_non_nullable
as String?,refreshToken: freezed == refreshToken ? _self.refreshToken : refreshToken // ignore: cast_nullable_to_non_nullable
as String?,deviceId: freezed == deviceId ? _self.deviceId : deviceId // ignore: cast_nullable_to_non_nullable
as int?,offlineMode: null == offlineMode ? _self.offlineMode : offlineMode // ignore: cast_nullable_to_non_nullable
as bool,aiAutofillEnabled: null == aiAutofillEnabled ? _self.aiAutofillEnabled : aiAutofillEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
