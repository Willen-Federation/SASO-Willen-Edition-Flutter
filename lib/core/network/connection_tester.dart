import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;

import '../../presentation/providers/server_config_provider.dart';

part 'connection_tester.freezed.dart';

/// Outcome of a connection probe — what we'll show in the UI under the
/// "接続テスト" button on the server-settings page.
@freezed
sealed class ConnectionTestResult with _$ConnectionTestResult {
  const factory ConnectionTestResult.success({
    required Duration latency,
    required int statusCode,
  }) = ConnectionTestSuccess;

  const factory ConnectionTestResult.failure({
    required String message,
    int? statusCode,
  }) = ConnectionTestFailure;

  const factory ConnectionTestResult.timeout({required Duration timeout}) =
      ConnectionTestTimeout;
}

/// Pings the configured backend to verify the user's settings work before
/// saving them. We pick a cheap GET that every API mode supports — for mock
/// we short-circuit, for legacy we hit `/category/list.json`, for REST v1
/// we hit `/api/v1/categories` with the bearer token.
class ConnectionTester {
  ConnectionTester({http.Client? httpClient, Duration? timeout})
    : _http = httpClient ?? http.Client(),
      _timeout = timeout ?? const Duration(seconds: 10);

  final http.Client _http;
  final Duration _timeout;

  Future<ConnectionTestResult> test(ServerConfig config) async {
    if (config.apiMode == ApiMode.mock) {
      return const ConnectionTestResult.success(
        latency: Duration.zero,
        statusCode: 200,
      );
    }

    if (config.baseUrl.isEmpty) {
      return const ConnectionTestResult.failure(message: 'サーバーURLが未入力です');
    }

    final uri = _probeUri(config);
    if (uri == null) {
      return const ConnectionTestResult.failure(message: 'サーバーURLの形式が不正です');
    }

    final headers = _headers(config);
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _http.get(uri, headers: headers).timeout(_timeout);
      stopwatch.stop();
      if (response.statusCode >= 200 && response.statusCode < 400) {
        return ConnectionTestResult.success(
          latency: stopwatch.elapsed,
          statusCode: response.statusCode,
        );
      }
      return ConnectionTestResult.failure(
        message: 'サーバーが HTTP ${response.statusCode} を返しました',
        statusCode: response.statusCode,
      );
    } on TimeoutException {
      return ConnectionTestResult.timeout(timeout: _timeout);
    } catch (e) {
      return ConnectionTestResult.failure(message: '接続失敗: $e');
    }
  }

  Uri? _probeUri(ServerConfig config) {
    final base = Uri.tryParse(config.baseUrl);
    if (base == null || !base.hasScheme) return null;
    return switch (config.apiMode) {
      ApiMode.mock => base,
      ApiMode.legacy => base.replace(path: '/category/list.json'),
      ApiMode.rest => base.replace(path: '/api/v1/health'),
    };
  }

  Map<String, String> _headers(ServerConfig config) => switch (config.apiMode) {
    ApiMode.mock => const {},
    ApiMode.legacy => {
      'Accept': 'application/json, text/html',
      if (config.sessionCookie != null) 'Cookie': config.sessionCookie!,
    },
    ApiMode.rest => {
      'Accept': 'application/json',
      if (config.jwtToken != null) 'Authorization': 'Bearer ${config.jwtToken!}',
    },
  };
}
