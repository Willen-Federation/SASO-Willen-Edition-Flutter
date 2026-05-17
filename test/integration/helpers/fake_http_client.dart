import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// In-memory HTTP backend used by the API-alignment integration tests.
///
/// Each entry in [routes] is matched against the request method + path. If
/// no entry matches the test fails with a 599 + a body explaining which
/// `Method Path` was unhandled.
///
/// The handler is responsible for verifying request headers (e.g.
/// `Idempotency-Key`) and recording them on the public [requests] list so
/// the test can assert on it later.
class FakeBackend {
  FakeBackend(this.routes);

  final Map<String, FutureOr<http.Response> Function(http.Request)> routes;
  final List<http.Request> requests = [];

  http.Client toClient() => MockClient((req) async {
    requests.add(req);
    final key = '${req.method} ${req.url.path}';
    final handler = routes[key];
    if (handler == null) {
      return http.Response(
        jsonEncode({
          'code': 'TEST-UNROUTED',
          'detail': 'No handler for $key',
          'received': req.url.toString(),
        }),
        599,
        headers: {'content-type': 'application/json'},
      );
    }
    return handler(req);
  });
}

http.Response problem({
  required int status,
  required String code,
  String? detail,
  Map<String, String> extraHeaders = const {},
}) => http.Response(
  jsonEncode({
    'type': 'about:blank',
    'title': code,
    'status': status,
    'detail': detail ?? code,
    'code': code,
    'traceId': '00000000-0000-4000-8000-000000000000',
  }),
  status,
  headers: {
    'content-type': 'application/problem+json',
    ...extraHeaders,
  },
);
