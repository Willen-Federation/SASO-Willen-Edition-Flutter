import 'package:firebase_auth/firebase_auth.dart';

import '../../constants/app_constants.dart';
import '../../storage/secure_storage.dart';
import '../auth_service.dart';

/// Firebase Authentication service.
/// Active when ff_auth_firebase = true.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService(this._secureStorage);

  final SecureStorageService _secureStorage;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  @override
  String? get currentToken => _firebaseAuth.currentUser?.uid;

  @override
  String? get currentUserId => _firebaseAuth.currentUser?.uid;

  @override
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  @override
  Future<AuthResult> login({
    required String serverUrl,
    required String username,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: username,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return const AuthResult.failure(
          message: 'Firebase login returned no user',
        );
      }

      final token = await user.getIdToken();
      if (token != null) {
        await _secureStorage.write(AppConstants.jwtTokenKey, token);
      }

      return AuthResult.success(userId: user.uid, token: token);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(
        message: e.message ?? 'Firebase auth error',
        code: e.code,
      );
    } catch (e) {
      return AuthResult.failure(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await _firebaseAuth.signOut();
    await _secureStorage.delete(AppConstants.jwtTokenKey);
  }

  @override
  Future<bool> refreshToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;
    try {
      final token = await user.getIdToken(true);
      if (token != null) {
        await _secureStorage.write(AppConstants.jwtTokenKey, token);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
