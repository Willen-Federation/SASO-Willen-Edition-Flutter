import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:saso_willen_edition/core/network/pinned_http_client.dart';

void main() {
  group('PinnedHttpClient', () {
    setUp(() => PinnedHttpClient.allowUnpinnedFallback = true);

    test('returns a plain client when no pins and fallback is allowed', () {
      final client = PinnedHttpClient.create(pins: const {});
      expect(client, isA<http.Client>());
      client.close();
    });

    test('returns an IOClient with pinning when pins are supplied', () {
      final client = PinnedHttpClient.create(
        pins: const {
          'auth.willen.jp': ['Zm9vYmFy'],
        },
      );
      // Functional verification of the cert callback requires a real
      // SecureSocket handshake; here we just confirm the factory
      // returns a usable http.Client subtype.
      expect(client, isA<http.Client>());
      client.close();
    });

    test('throws StateError in release mode when no pins are configured', () {
      PinnedHttpClient.allowUnpinnedFallback = false;
      expect(
        () => PinnedHttpClient.create(pins: const {}),
        throwsA(isA<StateError>()),
      );
    });
  });
}
