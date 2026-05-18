import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/network/url_validator.dart';
import '../../core/storage/secure_storage.dart';

part 'server_config_provider.freezed.dart';
part 'server_config_provider.g.dart';

enum ApiMode { mock, legacy, rest }

@freezed
abstract class ServerConfig with _$ServerConfig {
  const factory ServerConfig({
    @Default('') String baseUrl,
    @Default(ApiMode.rest) ApiMode apiMode,
    String? sessionCookie,
    String? jwtToken,
    String? refreshToken,
    int? deviceId,
    @Default(false) bool offlineMode,
    @Default(false) bool aiAutofillEnabled,
  }) = _ServerConfig;
}

@riverpod
class ServerConfigNotifier extends _$ServerConfigNotifier {
  @override
  ServerConfig build() => const ServerConfig();

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final secureStorage = ref.read(secureStorageProvider);

    final legacyRefreshToken = prefs.getString(AppConstants.refreshTokenKey);
    if (legacyRefreshToken != null) {
      await secureStorage.write(
        AppConstants.refreshTokenKey,
        legacyRefreshToken,
      );
      await prefs.remove(AppConstants.refreshTokenKey);
    }

    final url = prefs.getString(AppConstants.serverUrlKey) ?? '';
    final modeIndex =
        prefs.getInt(AppConstants.apiModeKey) ?? ApiMode.rest.index;
    final refreshToken = await secureStorage.read(AppConstants.refreshTokenKey);
    final deviceId = prefs.getInt(AppConstants.deviceIdKey);
    final offlineMode = prefs.getBool(AppConstants.offlineModeKey) ?? false;
    final aiAutofill = prefs.getBool(AppConstants.aiAutofillKey) ?? false;
    state = ServerConfig(
      baseUrl: url,
      apiMode: ApiMode.values[modeIndex],
      refreshToken: refreshToken,
      deviceId: deviceId,
      offlineMode: offlineMode,
      aiAutofillEnabled: aiAutofill,
    );
  }

  Future<void> save({required String url, required ApiMode mode}) async {
    final normalized = UrlValidator.ensureHttpsOrLoopback(url).toString();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.serverUrlKey, normalized);
    await prefs.setInt(AppConstants.apiModeKey, mode.index);
    state = state.copyWith(baseUrl: normalized, apiMode: mode);
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
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.write(AppConstants.refreshTokenKey, refreshToken);
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

  Future<void> setAiAutofill({required bool enabled}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.aiAutofillKey, enabled);
    state = state.copyWith(aiAutofillEnabled: enabled);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final secureStorage = ref.read(secureStorageProvider);
    await secureStorage.delete(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.deviceIdKey);
    state = state.copyWith(jwtToken: null, refreshToken: null, deviceId: null);
  }
}
