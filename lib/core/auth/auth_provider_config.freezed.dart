// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_provider_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AuthProviderSummary {

 int get id; String get name; AuthProviderType get type; bool get isDefault; bool get enabled;// Per-provider public config (e.g. Auth0 `domain` / `clientId`). Only
// non-secret identifiers belong here — secrets stay on the server.
 Map<String, String> get config;
/// Create a copy of AuthProviderSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthProviderSummaryCopyWith<AuthProviderSummary> get copyWith => _$AuthProviderSummaryCopyWithImpl<AuthProviderSummary>(this as AuthProviderSummary, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthProviderSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&const DeepCollectionEquality().equals(other.config, config));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,type,isDefault,enabled,const DeepCollectionEquality().hash(config));

@override
String toString() {
  return 'AuthProviderSummary(id: $id, name: $name, type: $type, isDefault: $isDefault, enabled: $enabled, config: $config)';
}


}

/// @nodoc
abstract mixin class $AuthProviderSummaryCopyWith<$Res>  {
  factory $AuthProviderSummaryCopyWith(AuthProviderSummary value, $Res Function(AuthProviderSummary) _then) = _$AuthProviderSummaryCopyWithImpl;
@useResult
$Res call({
 int id, String name, AuthProviderType type, bool isDefault, bool enabled, Map<String, String> config
});




}
/// @nodoc
class _$AuthProviderSummaryCopyWithImpl<$Res>
    implements $AuthProviderSummaryCopyWith<$Res> {
  _$AuthProviderSummaryCopyWithImpl(this._self, this._then);

  final AuthProviderSummary _self;
  final $Res Function(AuthProviderSummary) _then;

/// Create a copy of AuthProviderSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? isDefault = null,Object? enabled = null,Object? config = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AuthProviderType,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,config: null == config ? _self.config : config // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AuthProviderSummary].
extension AuthProviderSummaryPatterns on AuthProviderSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AuthProviderSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AuthProviderSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AuthProviderSummary value)  $default,){
final _that = this;
switch (_that) {
case _AuthProviderSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AuthProviderSummary value)?  $default,){
final _that = this;
switch (_that) {
case _AuthProviderSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  AuthProviderType type,  bool isDefault,  bool enabled,  Map<String, String> config)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AuthProviderSummary() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.isDefault,_that.enabled,_that.config);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  AuthProviderType type,  bool isDefault,  bool enabled,  Map<String, String> config)  $default,) {final _that = this;
switch (_that) {
case _AuthProviderSummary():
return $default(_that.id,_that.name,_that.type,_that.isDefault,_that.enabled,_that.config);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  AuthProviderType type,  bool isDefault,  bool enabled,  Map<String, String> config)?  $default,) {final _that = this;
switch (_that) {
case _AuthProviderSummary() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.isDefault,_that.enabled,_that.config);case _:
  return null;

}
}

}

/// @nodoc


class _AuthProviderSummary implements AuthProviderSummary {
  const _AuthProviderSummary({required this.id, required this.name, required this.type, required this.isDefault, required this.enabled, final  Map<String, String> config = const <String, String>{}}): _config = config;
  

@override final  int id;
@override final  String name;
@override final  AuthProviderType type;
@override final  bool isDefault;
@override final  bool enabled;
// Per-provider public config (e.g. Auth0 `domain` / `clientId`). Only
// non-secret identifiers belong here — secrets stay on the server.
 final  Map<String, String> _config;
// Per-provider public config (e.g. Auth0 `domain` / `clientId`). Only
// non-secret identifiers belong here — secrets stay on the server.
@override@JsonKey() Map<String, String> get config {
  if (_config is EqualUnmodifiableMapView) return _config;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_config);
}


/// Create a copy of AuthProviderSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AuthProviderSummaryCopyWith<_AuthProviderSummary> get copyWith => __$AuthProviderSummaryCopyWithImpl<_AuthProviderSummary>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AuthProviderSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.enabled, enabled) || other.enabled == enabled)&&const DeepCollectionEquality().equals(other._config, _config));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,type,isDefault,enabled,const DeepCollectionEquality().hash(_config));

@override
String toString() {
  return 'AuthProviderSummary(id: $id, name: $name, type: $type, isDefault: $isDefault, enabled: $enabled, config: $config)';
}


}

/// @nodoc
abstract mixin class _$AuthProviderSummaryCopyWith<$Res> implements $AuthProviderSummaryCopyWith<$Res> {
  factory _$AuthProviderSummaryCopyWith(_AuthProviderSummary value, $Res Function(_AuthProviderSummary) _then) = __$AuthProviderSummaryCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, AuthProviderType type, bool isDefault, bool enabled, Map<String, String> config
});




}
/// @nodoc
class __$AuthProviderSummaryCopyWithImpl<$Res>
    implements _$AuthProviderSummaryCopyWith<$Res> {
  __$AuthProviderSummaryCopyWithImpl(this._self, this._then);

  final _AuthProviderSummary _self;
  final $Res Function(_AuthProviderSummary) _then;

/// Create a copy of AuthProviderSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? isDefault = null,Object? enabled = null,Object? config = null,}) {
  return _then(_AuthProviderSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as AuthProviderType,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,config: null == config ? _self._config : config // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

/// @nodoc
mixin _$ServerAuthDiscovery {

 String get serverName; String get version; String get mobileSetupUrl; AuthStrategy get authStrategy; List<AuthProviderSummary> get providers;
/// Create a copy of ServerAuthDiscovery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServerAuthDiscoveryCopyWith<ServerAuthDiscovery> get copyWith => _$ServerAuthDiscoveryCopyWithImpl<ServerAuthDiscovery>(this as ServerAuthDiscovery, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerAuthDiscovery&&(identical(other.serverName, serverName) || other.serverName == serverName)&&(identical(other.version, version) || other.version == version)&&(identical(other.mobileSetupUrl, mobileSetupUrl) || other.mobileSetupUrl == mobileSetupUrl)&&(identical(other.authStrategy, authStrategy) || other.authStrategy == authStrategy)&&const DeepCollectionEquality().equals(other.providers, providers));
}


@override
int get hashCode => Object.hash(runtimeType,serverName,version,mobileSetupUrl,authStrategy,const DeepCollectionEquality().hash(providers));

@override
String toString() {
  return 'ServerAuthDiscovery(serverName: $serverName, version: $version, mobileSetupUrl: $mobileSetupUrl, authStrategy: $authStrategy, providers: $providers)';
}


}

/// @nodoc
abstract mixin class $ServerAuthDiscoveryCopyWith<$Res>  {
  factory $ServerAuthDiscoveryCopyWith(ServerAuthDiscovery value, $Res Function(ServerAuthDiscovery) _then) = _$ServerAuthDiscoveryCopyWithImpl;
@useResult
$Res call({
 String serverName, String version, String mobileSetupUrl, AuthStrategy authStrategy, List<AuthProviderSummary> providers
});




}
/// @nodoc
class _$ServerAuthDiscoveryCopyWithImpl<$Res>
    implements $ServerAuthDiscoveryCopyWith<$Res> {
  _$ServerAuthDiscoveryCopyWithImpl(this._self, this._then);

  final ServerAuthDiscovery _self;
  final $Res Function(ServerAuthDiscovery) _then;

/// Create a copy of ServerAuthDiscovery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serverName = null,Object? version = null,Object? mobileSetupUrl = null,Object? authStrategy = null,Object? providers = null,}) {
  return _then(_self.copyWith(
serverName: null == serverName ? _self.serverName : serverName // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,mobileSetupUrl: null == mobileSetupUrl ? _self.mobileSetupUrl : mobileSetupUrl // ignore: cast_nullable_to_non_nullable
as String,authStrategy: null == authStrategy ? _self.authStrategy : authStrategy // ignore: cast_nullable_to_non_nullable
as AuthStrategy,providers: null == providers ? _self.providers : providers // ignore: cast_nullable_to_non_nullable
as List<AuthProviderSummary>,
  ));
}

}


/// Adds pattern-matching-related methods to [ServerAuthDiscovery].
extension ServerAuthDiscoveryPatterns on ServerAuthDiscovery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServerAuthDiscovery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServerAuthDiscovery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServerAuthDiscovery value)  $default,){
final _that = this;
switch (_that) {
case _ServerAuthDiscovery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServerAuthDiscovery value)?  $default,){
final _that = this;
switch (_that) {
case _ServerAuthDiscovery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String serverName,  String version,  String mobileSetupUrl,  AuthStrategy authStrategy,  List<AuthProviderSummary> providers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServerAuthDiscovery() when $default != null:
return $default(_that.serverName,_that.version,_that.mobileSetupUrl,_that.authStrategy,_that.providers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String serverName,  String version,  String mobileSetupUrl,  AuthStrategy authStrategy,  List<AuthProviderSummary> providers)  $default,) {final _that = this;
switch (_that) {
case _ServerAuthDiscovery():
return $default(_that.serverName,_that.version,_that.mobileSetupUrl,_that.authStrategy,_that.providers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String serverName,  String version,  String mobileSetupUrl,  AuthStrategy authStrategy,  List<AuthProviderSummary> providers)?  $default,) {final _that = this;
switch (_that) {
case _ServerAuthDiscovery() when $default != null:
return $default(_that.serverName,_that.version,_that.mobileSetupUrl,_that.authStrategy,_that.providers);case _:
  return null;

}
}

}

/// @nodoc


class _ServerAuthDiscovery implements ServerAuthDiscovery {
  const _ServerAuthDiscovery({this.serverName = '', this.version = '', this.mobileSetupUrl = '', this.authStrategy = AuthStrategy.localOnly, final  List<AuthProviderSummary> providers = const <AuthProviderSummary>[]}): _providers = providers;
  

@override@JsonKey() final  String serverName;
@override@JsonKey() final  String version;
@override@JsonKey() final  String mobileSetupUrl;
@override@JsonKey() final  AuthStrategy authStrategy;
 final  List<AuthProviderSummary> _providers;
@override@JsonKey() List<AuthProviderSummary> get providers {
  if (_providers is EqualUnmodifiableListView) return _providers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providers);
}


/// Create a copy of ServerAuthDiscovery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServerAuthDiscoveryCopyWith<_ServerAuthDiscovery> get copyWith => __$ServerAuthDiscoveryCopyWithImpl<_ServerAuthDiscovery>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServerAuthDiscovery&&(identical(other.serverName, serverName) || other.serverName == serverName)&&(identical(other.version, version) || other.version == version)&&(identical(other.mobileSetupUrl, mobileSetupUrl) || other.mobileSetupUrl == mobileSetupUrl)&&(identical(other.authStrategy, authStrategy) || other.authStrategy == authStrategy)&&const DeepCollectionEquality().equals(other._providers, _providers));
}


@override
int get hashCode => Object.hash(runtimeType,serverName,version,mobileSetupUrl,authStrategy,const DeepCollectionEquality().hash(_providers));

@override
String toString() {
  return 'ServerAuthDiscovery(serverName: $serverName, version: $version, mobileSetupUrl: $mobileSetupUrl, authStrategy: $authStrategy, providers: $providers)';
}


}

/// @nodoc
abstract mixin class _$ServerAuthDiscoveryCopyWith<$Res> implements $ServerAuthDiscoveryCopyWith<$Res> {
  factory _$ServerAuthDiscoveryCopyWith(_ServerAuthDiscovery value, $Res Function(_ServerAuthDiscovery) _then) = __$ServerAuthDiscoveryCopyWithImpl;
@override @useResult
$Res call({
 String serverName, String version, String mobileSetupUrl, AuthStrategy authStrategy, List<AuthProviderSummary> providers
});




}
/// @nodoc
class __$ServerAuthDiscoveryCopyWithImpl<$Res>
    implements _$ServerAuthDiscoveryCopyWith<$Res> {
  __$ServerAuthDiscoveryCopyWithImpl(this._self, this._then);

  final _ServerAuthDiscovery _self;
  final $Res Function(_ServerAuthDiscovery) _then;

/// Create a copy of ServerAuthDiscovery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serverName = null,Object? version = null,Object? mobileSetupUrl = null,Object? authStrategy = null,Object? providers = null,}) {
  return _then(_ServerAuthDiscovery(
serverName: null == serverName ? _self.serverName : serverName // ignore: cast_nullable_to_non_nullable
as String,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,mobileSetupUrl: null == mobileSetupUrl ? _self.mobileSetupUrl : mobileSetupUrl // ignore: cast_nullable_to_non_nullable
as String,authStrategy: null == authStrategy ? _self.authStrategy : authStrategy // ignore: cast_nullable_to_non_nullable
as AuthStrategy,providers: null == providers ? _self._providers : providers // ignore: cast_nullable_to_non_nullable
as List<AuthProviderSummary>,
  ));
}


}

/// @nodoc
mixin _$AuthProviderConfig {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthProviderConfig);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthProviderConfig()';
}


}

/// @nodoc
class $AuthProviderConfigCopyWith<$Res>  {
$AuthProviderConfigCopyWith(AuthProviderConfig _, $Res Function(AuthProviderConfig) __);
}


/// Adds pattern-matching-related methods to [AuthProviderConfig].
extension AuthProviderConfigPatterns on AuthProviderConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LegacyAuthConfig value)?  legacy,TResult Function( OidcAuthConfig value)?  oidc,TResult Function( SamlAuthConfig value)?  saml,TResult Function( FirebaseAuthConfig value)?  firebase,TResult Function( Auth0AuthConfig value)?  auth0,TResult Function( CognitoAuthConfig value)?  cognito,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LegacyAuthConfig() when legacy != null:
return legacy(_that);case OidcAuthConfig() when oidc != null:
return oidc(_that);case SamlAuthConfig() when saml != null:
return saml(_that);case FirebaseAuthConfig() when firebase != null:
return firebase(_that);case Auth0AuthConfig() when auth0 != null:
return auth0(_that);case CognitoAuthConfig() when cognito != null:
return cognito(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LegacyAuthConfig value)  legacy,required TResult Function( OidcAuthConfig value)  oidc,required TResult Function( SamlAuthConfig value)  saml,required TResult Function( FirebaseAuthConfig value)  firebase,required TResult Function( Auth0AuthConfig value)  auth0,required TResult Function( CognitoAuthConfig value)  cognito,}){
final _that = this;
switch (_that) {
case LegacyAuthConfig():
return legacy(_that);case OidcAuthConfig():
return oidc(_that);case SamlAuthConfig():
return saml(_that);case FirebaseAuthConfig():
return firebase(_that);case Auth0AuthConfig():
return auth0(_that);case CognitoAuthConfig():
return cognito(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LegacyAuthConfig value)?  legacy,TResult? Function( OidcAuthConfig value)?  oidc,TResult? Function( SamlAuthConfig value)?  saml,TResult? Function( FirebaseAuthConfig value)?  firebase,TResult? Function( Auth0AuthConfig value)?  auth0,TResult? Function( CognitoAuthConfig value)?  cognito,}){
final _that = this;
switch (_that) {
case LegacyAuthConfig() when legacy != null:
return legacy(_that);case OidcAuthConfig() when oidc != null:
return oidc(_that);case SamlAuthConfig() when saml != null:
return saml(_that);case FirebaseAuthConfig() when firebase != null:
return firebase(_that);case Auth0AuthConfig() when auth0 != null:
return auth0(_that);case CognitoAuthConfig() when cognito != null:
return cognito(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  legacy,TResult Function( String issuer,  String clientId,  List<String> extraScopes)?  oidc,TResult Function( String loginUrl)?  saml,TResult Function( String projectId)?  firebase,TResult Function( String domain,  String clientId)?  auth0,TResult Function( String userPoolId,  String clientId,  String region,  String? hostedUiDomain)?  cognito,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LegacyAuthConfig() when legacy != null:
return legacy();case OidcAuthConfig() when oidc != null:
return oidc(_that.issuer,_that.clientId,_that.extraScopes);case SamlAuthConfig() when saml != null:
return saml(_that.loginUrl);case FirebaseAuthConfig() when firebase != null:
return firebase(_that.projectId);case Auth0AuthConfig() when auth0 != null:
return auth0(_that.domain,_that.clientId);case CognitoAuthConfig() when cognito != null:
return cognito(_that.userPoolId,_that.clientId,_that.region,_that.hostedUiDomain);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  legacy,required TResult Function( String issuer,  String clientId,  List<String> extraScopes)  oidc,required TResult Function( String loginUrl)  saml,required TResult Function( String projectId)  firebase,required TResult Function( String domain,  String clientId)  auth0,required TResult Function( String userPoolId,  String clientId,  String region,  String? hostedUiDomain)  cognito,}) {final _that = this;
switch (_that) {
case LegacyAuthConfig():
return legacy();case OidcAuthConfig():
return oidc(_that.issuer,_that.clientId,_that.extraScopes);case SamlAuthConfig():
return saml(_that.loginUrl);case FirebaseAuthConfig():
return firebase(_that.projectId);case Auth0AuthConfig():
return auth0(_that.domain,_that.clientId);case CognitoAuthConfig():
return cognito(_that.userPoolId,_that.clientId,_that.region,_that.hostedUiDomain);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  legacy,TResult? Function( String issuer,  String clientId,  List<String> extraScopes)?  oidc,TResult? Function( String loginUrl)?  saml,TResult? Function( String projectId)?  firebase,TResult? Function( String domain,  String clientId)?  auth0,TResult? Function( String userPoolId,  String clientId,  String region,  String? hostedUiDomain)?  cognito,}) {final _that = this;
switch (_that) {
case LegacyAuthConfig() when legacy != null:
return legacy();case OidcAuthConfig() when oidc != null:
return oidc(_that.issuer,_that.clientId,_that.extraScopes);case SamlAuthConfig() when saml != null:
return saml(_that.loginUrl);case FirebaseAuthConfig() when firebase != null:
return firebase(_that.projectId);case Auth0AuthConfig() when auth0 != null:
return auth0(_that.domain,_that.clientId);case CognitoAuthConfig() when cognito != null:
return cognito(_that.userPoolId,_that.clientId,_that.region,_that.hostedUiDomain);case _:
  return null;

}
}

}

/// @nodoc


class LegacyAuthConfig implements AuthProviderConfig {
  const LegacyAuthConfig();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LegacyAuthConfig);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AuthProviderConfig.legacy()';
}


}




/// @nodoc


class OidcAuthConfig implements AuthProviderConfig {
  const OidcAuthConfig({required this.issuer, this.clientId = 'saso-mobile', final  List<String> extraScopes = const <String>[]}): _extraScopes = extraScopes;
  

 final  String issuer;
@JsonKey() final  String clientId;
 final  List<String> _extraScopes;
@JsonKey() List<String> get extraScopes {
  if (_extraScopes is EqualUnmodifiableListView) return _extraScopes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_extraScopes);
}


/// Create a copy of AuthProviderConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OidcAuthConfigCopyWith<OidcAuthConfig> get copyWith => _$OidcAuthConfigCopyWithImpl<OidcAuthConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OidcAuthConfig&&(identical(other.issuer, issuer) || other.issuer == issuer)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&const DeepCollectionEquality().equals(other._extraScopes, _extraScopes));
}


@override
int get hashCode => Object.hash(runtimeType,issuer,clientId,const DeepCollectionEquality().hash(_extraScopes));

@override
String toString() {
  return 'AuthProviderConfig.oidc(issuer: $issuer, clientId: $clientId, extraScopes: $extraScopes)';
}


}

/// @nodoc
abstract mixin class $OidcAuthConfigCopyWith<$Res> implements $AuthProviderConfigCopyWith<$Res> {
  factory $OidcAuthConfigCopyWith(OidcAuthConfig value, $Res Function(OidcAuthConfig) _then) = _$OidcAuthConfigCopyWithImpl;
@useResult
$Res call({
 String issuer, String clientId, List<String> extraScopes
});




}
/// @nodoc
class _$OidcAuthConfigCopyWithImpl<$Res>
    implements $OidcAuthConfigCopyWith<$Res> {
  _$OidcAuthConfigCopyWithImpl(this._self, this._then);

  final OidcAuthConfig _self;
  final $Res Function(OidcAuthConfig) _then;

/// Create a copy of AuthProviderConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? issuer = null,Object? clientId = null,Object? extraScopes = null,}) {
  return _then(OidcAuthConfig(
issuer: null == issuer ? _self.issuer : issuer // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,extraScopes: null == extraScopes ? _self._extraScopes : extraScopes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class SamlAuthConfig implements AuthProviderConfig {
  const SamlAuthConfig({required this.loginUrl});
  

 final  String loginUrl;

/// Create a copy of AuthProviderConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SamlAuthConfigCopyWith<SamlAuthConfig> get copyWith => _$SamlAuthConfigCopyWithImpl<SamlAuthConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SamlAuthConfig&&(identical(other.loginUrl, loginUrl) || other.loginUrl == loginUrl));
}


@override
int get hashCode => Object.hash(runtimeType,loginUrl);

@override
String toString() {
  return 'AuthProviderConfig.saml(loginUrl: $loginUrl)';
}


}

/// @nodoc
abstract mixin class $SamlAuthConfigCopyWith<$Res> implements $AuthProviderConfigCopyWith<$Res> {
  factory $SamlAuthConfigCopyWith(SamlAuthConfig value, $Res Function(SamlAuthConfig) _then) = _$SamlAuthConfigCopyWithImpl;
@useResult
$Res call({
 String loginUrl
});




}
/// @nodoc
class _$SamlAuthConfigCopyWithImpl<$Res>
    implements $SamlAuthConfigCopyWith<$Res> {
  _$SamlAuthConfigCopyWithImpl(this._self, this._then);

  final SamlAuthConfig _self;
  final $Res Function(SamlAuthConfig) _then;

/// Create a copy of AuthProviderConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? loginUrl = null,}) {
  return _then(SamlAuthConfig(
loginUrl: null == loginUrl ? _self.loginUrl : loginUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FirebaseAuthConfig implements AuthProviderConfig {
  const FirebaseAuthConfig({required this.projectId});
  

 final  String projectId;

/// Create a copy of AuthProviderConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FirebaseAuthConfigCopyWith<FirebaseAuthConfig> get copyWith => _$FirebaseAuthConfigCopyWithImpl<FirebaseAuthConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FirebaseAuthConfig&&(identical(other.projectId, projectId) || other.projectId == projectId));
}


@override
int get hashCode => Object.hash(runtimeType,projectId);

@override
String toString() {
  return 'AuthProviderConfig.firebase(projectId: $projectId)';
}


}

/// @nodoc
abstract mixin class $FirebaseAuthConfigCopyWith<$Res> implements $AuthProviderConfigCopyWith<$Res> {
  factory $FirebaseAuthConfigCopyWith(FirebaseAuthConfig value, $Res Function(FirebaseAuthConfig) _then) = _$FirebaseAuthConfigCopyWithImpl;
@useResult
$Res call({
 String projectId
});




}
/// @nodoc
class _$FirebaseAuthConfigCopyWithImpl<$Res>
    implements $FirebaseAuthConfigCopyWith<$Res> {
  _$FirebaseAuthConfigCopyWithImpl(this._self, this._then);

  final FirebaseAuthConfig _self;
  final $Res Function(FirebaseAuthConfig) _then;

/// Create a copy of AuthProviderConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? projectId = null,}) {
  return _then(FirebaseAuthConfig(
projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class Auth0AuthConfig implements AuthProviderConfig {
  const Auth0AuthConfig({required this.domain, required this.clientId});
  

 final  String domain;
 final  String clientId;

/// Create a copy of AuthProviderConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$Auth0AuthConfigCopyWith<Auth0AuthConfig> get copyWith => _$Auth0AuthConfigCopyWithImpl<Auth0AuthConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Auth0AuthConfig&&(identical(other.domain, domain) || other.domain == domain)&&(identical(other.clientId, clientId) || other.clientId == clientId));
}


@override
int get hashCode => Object.hash(runtimeType,domain,clientId);

@override
String toString() {
  return 'AuthProviderConfig.auth0(domain: $domain, clientId: $clientId)';
}


}

/// @nodoc
abstract mixin class $Auth0AuthConfigCopyWith<$Res> implements $AuthProviderConfigCopyWith<$Res> {
  factory $Auth0AuthConfigCopyWith(Auth0AuthConfig value, $Res Function(Auth0AuthConfig) _then) = _$Auth0AuthConfigCopyWithImpl;
@useResult
$Res call({
 String domain, String clientId
});




}
/// @nodoc
class _$Auth0AuthConfigCopyWithImpl<$Res>
    implements $Auth0AuthConfigCopyWith<$Res> {
  _$Auth0AuthConfigCopyWithImpl(this._self, this._then);

  final Auth0AuthConfig _self;
  final $Res Function(Auth0AuthConfig) _then;

/// Create a copy of AuthProviderConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? domain = null,Object? clientId = null,}) {
  return _then(Auth0AuthConfig(
domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CognitoAuthConfig implements AuthProviderConfig {
  const CognitoAuthConfig({required this.userPoolId, required this.clientId, required this.region, this.hostedUiDomain});
  

 final  String userPoolId;
 final  String clientId;
 final  String region;
 final  String? hostedUiDomain;

/// Create a copy of AuthProviderConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CognitoAuthConfigCopyWith<CognitoAuthConfig> get copyWith => _$CognitoAuthConfigCopyWithImpl<CognitoAuthConfig>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CognitoAuthConfig&&(identical(other.userPoolId, userPoolId) || other.userPoolId == userPoolId)&&(identical(other.clientId, clientId) || other.clientId == clientId)&&(identical(other.region, region) || other.region == region)&&(identical(other.hostedUiDomain, hostedUiDomain) || other.hostedUiDomain == hostedUiDomain));
}


@override
int get hashCode => Object.hash(runtimeType,userPoolId,clientId,region,hostedUiDomain);

@override
String toString() {
  return 'AuthProviderConfig.cognito(userPoolId: $userPoolId, clientId: $clientId, region: $region, hostedUiDomain: $hostedUiDomain)';
}


}

/// @nodoc
abstract mixin class $CognitoAuthConfigCopyWith<$Res> implements $AuthProviderConfigCopyWith<$Res> {
  factory $CognitoAuthConfigCopyWith(CognitoAuthConfig value, $Res Function(CognitoAuthConfig) _then) = _$CognitoAuthConfigCopyWithImpl;
@useResult
$Res call({
 String userPoolId, String clientId, String region, String? hostedUiDomain
});




}
/// @nodoc
class _$CognitoAuthConfigCopyWithImpl<$Res>
    implements $CognitoAuthConfigCopyWith<$Res> {
  _$CognitoAuthConfigCopyWithImpl(this._self, this._then);

  final CognitoAuthConfig _self;
  final $Res Function(CognitoAuthConfig) _then;

/// Create a copy of AuthProviderConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? userPoolId = null,Object? clientId = null,Object? region = null,Object? hostedUiDomain = freezed,}) {
  return _then(CognitoAuthConfig(
userPoolId: null == userPoolId ? _self.userPoolId : userPoolId // ignore: cast_nullable_to_non_nullable
as String,clientId: null == clientId ? _self.clientId : clientId // ignore: cast_nullable_to_non_nullable
as String,region: null == region ? _self.region : region // ignore: cast_nullable_to_non_nullable
as String,hostedUiDomain: freezed == hostedUiDomain ? _self.hostedUiDomain : hostedUiDomain // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
