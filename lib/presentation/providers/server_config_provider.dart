import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/storage/secure_storage.dart';

part 'server_config_provider.freezed.dart';
part 'server_config_provider.g.dart';

enum ApiMode { mock, legacy, rest }

@freezed
abstract class ServerConfig with _$ServerConfig {
  const factory ServerConfig({
    @Default('') String baseUrl,
    @Default(ApiMode.mock) ApiMode apiMode,
    String? sessionCookie,
    String? jwtToken,
    String? refreshToken,
    int? deviceId,
    @Default(false) bool offlineMode,
  }) = _ServerConfig;
}

@riverpod
class ServerConfigNotifier extends _$ServerConfigNotifier {
  @override
  ServerConfig build() => const ServerConfig();

  SecureStorageService get _secureStorage => ref.read(secureStorageProvider);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(AppConstants.serverUrlKey) ?? '';
    final modeIndex = prefs.getInt(AppConstants.apiModeKey) ?? 0;
    final deviceId = prefs.getInt(AppConstants.deviceIdKey);
    final offlineMode = prefs.getBool(AppConstants.offlineModeKey) ?? false;

    // Migrate any refresh token that was previously written to SharedPreferences
    // in plaintext (pre-fix for HIGH-002) into secure storage exactly once.
    final legacy = prefs.getString(AppConstants.refreshTokenKey);
    if (legacy != null && legacy.isNotEmpty) {
      await _secureStorage.write(AppConstants.refreshTokenKey, legacy);
      await prefs.remove(AppConstants.refreshTokenKey);
    }

    final refreshToken = await _secureStorage.read(
      AppConstants.refreshTokenKey,
    );

    state = ServerConfig(
      baseUrl: url,
      apiMode: ApiMode.values[modeIndex],
      refreshToken: refreshToken,
      deviceId: deviceId,
      offlineMode: offlineMode,
    );
  }

  Future<void> save({required String url, required ApiMode mode}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.serverUrlKey, url);
    await prefs.setInt(AppConstants.apiModeKey, mode.index);
    state = state.copyWith(baseUrl: url, apiMode: mode);
  }

  void updateToken(String token) {
    state = state.copyWith(jwtToken: token);
  }

  void updateSessionCookie(String cookie) {
    state = state.copyWith(sessionCookie: cookie);
  }

  Future<void> updateTokenPair({
    required String accessToken,
    required String refreshToken,
    required int deviceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.write(AppConstants.refreshTokenKey, refreshToken);
    await prefs.setInt(AppConstants.deviceIdKey, deviceId);
    state = state.copyWith(
      jwtToken: accessToken,
      refreshToken: refreshToken,
      deviceId: deviceId,
    );
  }

  Future<void> setOfflineMode({required bool enabled}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.offlineModeKey, enabled);
    state = state.copyWith(offlineMode: enabled);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await _secureStorage.delete(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.deviceIdKey);
    state = state.copyWith(jwtToken: null, refreshToken: null, deviceId: null);
  }
}
