import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/core/network/url_validator.dart';

void main() {
  group('UrlValidator.ensureHttpsOrLoopback', () {
    test('accepts a valid https URL and preserves it', () {
      final uri = UrlValidator.ensureHttpsOrLoopback(
        'https://auth.willen.jp',
        allowLoopback: false,
      );
      expect(uri.scheme, 'https');
      expect(uri.host, 'auth.willen.jp');
      expect(uri.toString(), 'https://auth.willen.jp');
    });

    test('lowercases an uppercase host', () {
      final uri = UrlValidator.ensureHttpsOrLoopback(
        'https://Auth.Willen.JP/api',
        allowLoopback: false,
      );
      expect(uri.host, 'auth.willen.jp');
      expect(uri.path, '/api');
    });

    test('strips a single trailing slash from the path', () {
      final uri = UrlValidator.ensureHttpsOrLoopback(
        'https://auth.willen.jp/api/',
        allowLoopback: false,
      );
      expect(uri.path, '/api');
    });

    test('trims surrounding whitespace before parsing', () {
      final uri = UrlValidator.ensureHttpsOrLoopback(
        '  https://auth.willen.jp  ',
        allowLoopback: false,
      );
      expect(uri.toString(), 'https://auth.willen.jp');
    });

    test('rejects an http URL when loopback is disallowed', () {
      expect(
        () => UrlValidator.ensureHttpsOrLoopback(
          'http://example.com',
          allowLoopback: false,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects an http URL on a non-loopback host even when allowed', () {
      expect(
        () => UrlValidator.ensureHttpsOrLoopback(
          'http://example.com',
          allowLoopback: true,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('accepts http on loopback when allowed', () {
      final uri = UrlValidator.ensureHttpsOrLoopback(
        'http://localhost:8080',
        allowLoopback: true,
      );
      expect(uri.scheme, 'http');
      expect(uri.host, 'localhost');
      expect(uri.port, 8080);
    });

    test('accepts http on 127.0.0.1 when allowed', () {
      final uri = UrlValidator.ensureHttpsOrLoopback(
        'http://127.0.0.1:3000',
        allowLoopback: true,
      );
      expect(uri.host, '127.0.0.1');
    });

    test('rejects a URL that embeds userinfo', () {
      expect(
        () => UrlValidator.ensureHttpsOrLoopback(
          'https://user:pass@example.com',
          allowLoopback: false,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects an unsupported scheme (file)', () {
      expect(
        () => UrlValidator.ensureHttpsOrLoopback(
          'file:///etc/passwd',
          allowLoopback: false,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects a javascript: URL', () {
      expect(
        () => UrlValidator.ensureHttpsOrLoopback(
          'javascript:alert(1)',
          allowLoopback: false,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects an empty string', () {
      expect(
        () => UrlValidator.ensureHttpsOrLoopback('', allowLoopback: false),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects a relative URL', () {
      expect(
        () =>
            UrlValidator.ensureHttpsOrLoopback('/api/v1', allowLoopback: false),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
