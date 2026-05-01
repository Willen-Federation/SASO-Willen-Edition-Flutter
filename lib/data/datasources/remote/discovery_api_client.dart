import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/mobile_discovery_model.dart';

/// Failure reasons from [DiscoveryApiClient.discover].
enum DiscoveryFailureKind {
  invalidUrl,
  unreachable,
  wrongServer,
  invalidResponse,
}

class DiscoveryFailure implements Exception {
  const DiscoveryFailure(this.kind, this.message);
  final DiscoveryFailureKind kind;
  final String message;

  @override
  String toString() => 'DiscoveryFailure($kind): $message';
}

/// Calls `GET <base>/api/v1/mobile/discovery` to learn what setup URL the
/// app should open and which IdPs are available. Public endpoint — no auth
/// required, so this is safe to call before the user has any credentials.
class DiscoveryApiClient {
  DiscoveryApiClient({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;
  static const _timeout = Duration(seconds: 10);

  /// [baseUrl] may be a bare host (`saso.example.com`), with or without a
  /// scheme. The result always uses `https://` unless the host is a private
  /// dev address (localhost / 127.0.0.1 / *.local / 10.x.x.x / 192.168.x.x),
  /// in which case `http://` is permitted.
  Future<MobileDiscoveryModel> discover(String baseUrl) async {
    final normalized = _normalize(baseUrl);
    if (normalized == null) {
      throw const DiscoveryFailure(
        DiscoveryFailureKind.invalidUrl,
        'URL を正しく入力してください',
      );
    }

    final uri = normalized.replace(path: '/api/v1/mobile/discovery');

    final http.Response response;
    try {
      response = await _http
          .get(uri, headers: const {'Accept': 'application/json'})
          .timeout(_timeout);
    } catch (e) {
      throw DiscoveryFailure(
        DiscoveryFailureKind.unreachable,
        'サーバーに接続できません: $e',
      );
    }

    if (response.statusCode != 200) {
      throw DiscoveryFailure(
        DiscoveryFailureKind.wrongServer,
        'サーバーが SASO ではないようです (HTTP ${response.statusCode})',
      );
    }

    try {
      final body = jsonDecode(response.body);
      if (body is! Map<String, dynamic>) {
        throw const DiscoveryFailure(
          DiscoveryFailureKind.invalidResponse,
          '応答 JSON の形式が不正です',
        );
      }
      return MobileDiscoveryModel.fromJson(body);
    } catch (e) {
      throw DiscoveryFailure(
        DiscoveryFailureKind.invalidResponse,
        '応答を解析できませんでした: $e',
      );
    }
  }

  /// Normalises [input] into an `https://`-prefixed [Uri] (or `http://` for
  /// private dev addresses). Returns null when the input is not a usable
  /// host.
  static Uri? _normalize(String input) {
    var trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    if (!trimmed.contains('://')) {
      trimmed = 'https://$trimmed';
    }
    final parsed = Uri.tryParse(trimmed);
    if (parsed == null || parsed.host.isEmpty) return null;
    if (parsed.scheme != 'http' && parsed.scheme != 'https') return null;

    if (parsed.scheme == 'http' && !_isPrivateHost(parsed.host)) {
      return null;
    }

    return Uri(
      scheme: parsed.scheme,
      userInfo: parsed.userInfo.isEmpty ? null : parsed.userInfo,
      host: parsed.host,
      port: parsed.hasPort ? parsed.port : null,
      path: '',
    );
  }

  static bool _isPrivateHost(String host) {
    if (host == 'localhost' || host == '127.0.0.1') return true;
    if (host.endsWith('.local')) return true;
    if (RegExp(r'^10\.').hasMatch(host)) return true;
    if (RegExp(r'^192\.168\.').hasMatch(host)) return true;
    if (RegExp(r'^172\.(1[6-9]|2[0-9]|3[0-1])\.').hasMatch(host)) return true;
    return false;
  }
}
