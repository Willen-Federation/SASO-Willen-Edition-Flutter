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
