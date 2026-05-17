import 'dart:async';
import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:saso_willen_edition/core/errors/problem_details.dart';
import 'package:saso_willen_edition/data/datasources/remote/v1/rest_api_client.dart';

Map<String, dynamic> _tokenPair({
  String access = 'new-jwt',
  String refresh = 'new-refresh',
  int deviceId = 7,
}) => {
  'access_token': access,
  'token_type': 'Bearer',
  'expires_in': 3600,
  'refresh_token': refresh,
  'device_id': deviceId,
  'device_name': 'SASO Mobile',
  'expires_at':
      DateTime.now().add(const Duration(hours: 1)).toUtc().toIso8601String(),
};

/// Drives [body] to completion under a virtual clock, fast-forwarding through
/// the retry backoff sleeps so the test wall-clock stays sub-second.
T _runWithVirtualTime<T>(Future<T> Function() body) {
  late T result;
  Object? error;
  StackTrace? stack;
  var done = false;
  fakeAsync((async) {
    body().then((value) {
      result = value;
      done = true;
    }).catchError((Object e, StackTrace s) {
      error = e;
      stack = s;
      done = true;
    });
    // Each retry sleeps 1/2/4s; elapse(...) covers all backoff windows.
    async.elapse(const Duration(seconds: 30));
  });
  if (!done) {
    fail('Future did not complete within the virtual elapse window');
  }
  if (error != null) {
    Error.throwWithStackTrace(error!, stack ?? StackTrace.current);
  }
  return result;
}

void main() {
  group('RestV1ApiClient._retry — exponential backoff', () {
    test('returns on first success', () {
      var calls = 0;
      final client = RestV1ApiClient(
        serverUrl: 'https://example.com',
        jwtToken: 'jwt',
        httpClient: MockClient((_) async {
          calls++;
          return http.Response(
            jsonEncode({'data': []}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      _runWithVirtualTime(() => client.searchItems(query: 'foo'));
      expect(calls, 1);
    });

    test('retries on 500 then succeeds on second call', () {
      var calls = 0;
      final client = RestV1ApiClient(
        serverUrl: 'https://example.com',
        jwtToken: 'jwt',
        httpClient: MockClient((_) async {
          calls++;
          if (calls == 1) return http.Response('boom', 500);
          return http.Response(
            jsonEncode({'data': []}),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );
      _runWithVirtualTime(() => client.searchItems(query: 'foo'));
      expect(calls, 2);
    });

    test('gives up after 4 attempts on persistent 500', () {
      var calls = 0;
      final client = RestV1ApiClient(
        serverUrl: 'https://example.com',
        jwtToken: 'jwt',
        httpClient: MockClient((_) async {
          calls++;
          return http.Response('boom', 500);
        }),
      );
      expect(
        () => _runWithVirtualTime(() => client.searchItems(query: 'foo')),
        throwsA(isA<Exception>()),
      );
      expect(calls, 4);
    });

    test('non-idempotent POST without idempotency key is NOT retried', () {
      var calls = 0;
      final client = RestV1ApiClient(
        serverUrl: 'https://example.com',
        jwtToken: 'jwt',
        httpClient: MockClient((_) async {
          calls++;
          return http.Response('boom', 500);
        }),
      );
      expect(
        () => _runWithVirtualTime(
          () => client.createItem(<String, dynamic>{'name': 'x'}),
        ),
        throwsA(isA<Exception>()),
      );
      expect(calls, 1);
    });

    test('POST WITH idempotency key IS retried on 500', () {
      var calls = 0;
      final client = RestV1ApiClient(
        serverUrl: 'https://example.com',
        jwtToken: 'jwt',
        httpClient: MockClient((_) async {
          calls++;
          return http.Response('boom', 500);
        }),
      );
      expect(
        () => _runWithVirtualTime(
          () => client.createItem(
            <String, dynamic>{'name': 'x'},
            idempotencyKey: 'abc',
          ),
        ),
        throwsA(isA<Exception>()),
      );
      expect(calls, 4);
    });

    test('4xx is never retried', () {
      var calls = 0;
      final client = RestV1ApiClient(
        serverUrl: 'https://example.com',
        jwtToken: 'jwt',
        httpClient: MockClient((_) async {
          calls++;
          return http.Response(
            jsonEncode({
              'type': 'about:blank',
              'title': 'Bad Request',
              'status': 400,
            }),
            400,
            headers: {'content-type': 'application/problem+json'},
          );
        }),
      );
      expect(
        () => _runWithVirtualTime(() => client.searchItems(query: 'foo')),
        throwsA(isA<ProblemDetails>()),
      );
      expect(calls, 1);
    });
  });

  group('RestV1ApiClient._authenticatedRequest — 401 refresh', () {
    test('refreshes once on 401 and retries the original call', () {
      var search = 0;
      var refresh = 0;
      String currentToken = 'old-jwt';

      final client = RestV1ApiClient(
        serverUrl: 'https://example.com',
        jwtToken: 'old-jwt',
        refreshTokenLoader: () async => 'stored-refresh',
        onTokenRefreshed: ({
          required String accessToken,
          required String refreshToken,
          required int deviceId,
        }) async {
          currentToken = accessToken;
        },
        httpClient: MockClient((req) async {
          if (req.url.path.contains('/mobile/token/refresh')) {
            refresh++;
            return http.Response(
              jsonEncode(_tokenPair(access: 'new-jwt')),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          if (req.url.path.contains('/api/v1/items')) {
            search++;
            if (search == 1) return http.Response('unauthorized', 401);
            expect(req.headers['Authorization'], 'Bearer new-jwt');
            return http.Response(
              jsonEncode({'data': []}),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          fail('unexpected ${req.url}');
        }),
      );

      _runWithVirtualTime(() => client.searchItems(query: 'foo'));
      expect(search, 2);
      expect(refresh, 1);
      expect(currentToken, 'new-jwt');
      expect(client.jwtToken, 'new-jwt');
    });

    test('invokes onRefreshFailed when refresh itself returns 401', () {
      var refreshFailed = 0;
      final client = RestV1ApiClient(
        serverUrl: 'https://example.com',
        jwtToken: 'old-jwt',
        refreshTokenLoader: () async => 'stored-refresh',
        onTokenRefreshed: ({
          required String accessToken,
          required String refreshToken,
          required int deviceId,
        }) async {},
        onRefreshFailed: () async {
          refreshFailed++;
        },
        httpClient: MockClient((req) async {
          if (req.url.path.contains('/mobile/token/refresh')) {
            return http.Response(
              jsonEncode({
                'type': 'about:blank',
                'title': 'Token revoked',
                'status': 401,
              }),
              401,
              headers: {'content-type': 'application/problem+json'},
            );
          }
          if (req.url.path.contains('/api/v1/items')) {
            return http.Response('unauthorized', 401);
          }
          fail('unexpected ${req.url}');
        }),
      );

      expect(
        () => _runWithVirtualTime(() => client.searchItems(query: 'foo')),
        throwsA(isA<Exception>()),
      );
      expect(refreshFailed, 1);
    });
  });
}
