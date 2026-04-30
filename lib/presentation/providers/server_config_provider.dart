import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

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

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(AppConstants.serverUrlKey) ?? '';
    final modeIndex = prefs.getInt(AppConstants.apiModeKey) ?? 0;
    final refreshToken = prefs.getString(AppConstants.refreshTokenKey);
    final deviceId = prefs.getInt(AppConstants.deviceIdKey);
    final offlineMode = prefs.getBool(AppConstants.offlineModeKey) ?? false;
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
    await prefs.setString(AppConstants.refreshTokenKey, refreshToken);
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
    await prefs.remove(AppConstants.refreshTokenKey);
    await prefs.remove(AppConstants.deviceIdKey);
    state = state.copyWith(jwtToken: null, refreshToken: null, deviceId: null);
  }
}
