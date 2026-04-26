import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_service.freezed.dart';

@freezed
abstract class AuthResult with _$AuthResult {
  const factory AuthResult.success({
    required String userId,
    String? token,
    String? sessionCookie,
    DateTime? expiresAt,
  }) = AuthSuccess;

  const factory AuthResult.failure({required String message, String? code}) =
      AuthFailure;
}

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = Unauthenticated;
  const factory AuthState.authenticated({
    required String userId,
    String? token,
    DateTime? expiresAt,
  }) = Authenticated;
  const factory AuthState.loading() = AuthLoading;
}

/// Abstract auth service — implementation selected via feature flags.
abstract interface class AuthService {
  Future<AuthResult> login({
    required String serverUrl,
    required String username,
    required String password,
  });

  Future<void> logout();

  Future<bool> refreshToken();

  String? get currentToken;
  String? get currentUserId;
  bool get isAuthenticated;
}
