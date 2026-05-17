import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

/// HTTP client decorator that retries idempotent requests on transient
/// network errors and 5xx responses with exponential backoff (1s/2s/4s,
/// total up to four attempts).
///
/// Retry policy:
/// - **GET / DELETE / HEAD / OPTIONS** — always retried.
/// - **POST / PATCH** — retried **only** when the request carries an
///   `Idempotency-Key` header (already supplied by
///   `RestV1ApiClient.createItem` / `updateItem`).
/// - **Multipart bodies** — never retried (the stream is consumed on
///   first send).
/// - **4xx responses** — never retried (client errors won't recover).
class RetryClient extends http.BaseClient {
  RetryClient(
    this._inner, {
    this.delays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
  });

  final http.Client _inner;
  final List<Duration> delays;

  static const _idempotentMethods = {'GET', 'DELETE', 'HEAD', 'OPTIONS'};

  bool _isRetryable(http.BaseRequest request) {
    if (request is http.MultipartRequest) return false;
    if (_idempotentMethods.contains(request.method.toUpperCase())) return true;
    return request.headers.containsKey('Idempotency-Key');
  }

  http.Request _cloneRequest(http.Request source) {
    final clone =
        http.Request(source.method, source.url)
          ..headers.addAll(source.headers)
          ..bodyBytes = source.bodyBytes
          ..encoding = source.encoding
          ..followRedirects = source.followRedirects
          ..maxRedirects = source.maxRedirects
          ..persistentConnection = source.persistentConnection;
    return clone;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (!_isRetryable(request) || request is! http.Request) {
      return _inner.send(request);
    }

    final maxAttempts = delays.length + 1;
    var attempt = 0;
    while (true) {
      final tryRequest = attempt == 0 ? request : _cloneRequest(request);
      try {
        final response = await _inner.send(tryRequest);
        if (response.statusCode < 500 || attempt >= delays.length) {
          return response;
        }
        // Drain the body so the underlying connection can be reused.
        await response.stream.drain<void>();
      } on TimeoutException {
        if (attempt >= delays.length) rethrow;
      } on SocketException {
        if (attempt >= delays.length) rethrow;
      } on http.ClientException {
        if (attempt >= delays.length) rethrow;
      }
      await Future<void>.delayed(delays[attempt]);
      attempt++;
      if (attempt >= maxAttempts) {
        throw StateError('RetryClient: exceeded $maxAttempts attempts');
      }
    }
  }

  @override
  void close() {
    _inner.close();
  }
}
