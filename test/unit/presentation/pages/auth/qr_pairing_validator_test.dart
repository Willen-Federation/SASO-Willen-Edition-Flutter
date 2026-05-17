import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/presentation/pages/auth/qr_pairing_validator.dart';

void main() {
  group('QrPairingValidator.resolveServerUrl', () {
    const configured = 'https://saso.example.com';

    test('accepts QR with no server URL, falls back to configured', () {
      expect(
        QrPairingValidator.resolveServerUrl(
          qrServerUrl: null,
          configuredUrl: configured,
        ),
        configured,
      );
    });

    test('accepts QR with empty server URL', () {
      expect(
        QrPairingValidator.resolveServerUrl(
          qrServerUrl: '',
          configuredUrl: configured,
        ),
        configured,
      );
    });

    test('accepts QR whose URL matches configured exactly', () {
      expect(
        QrPairingValidator.resolveServerUrl(
          qrServerUrl: configured,
          configuredUrl: configured,
        ),
        configured,
      );
    });

    test('accepts QR with trailing slash difference', () {
      expect(
        QrPairingValidator.resolveServerUrl(
          qrServerUrl: '$configured/',
          configuredUrl: configured,
        ),
        configured,
      );
    });

    test('accepts case-insensitive host match', () {
      expect(
        QrPairingValidator.resolveServerUrl(
          qrServerUrl: 'HTTPS://SASO.EXAMPLE.COM',
          configuredUrl: configured,
        ),
        configured,
      );
    });

    test('rejects QR with attacker-controlled URL', () {
      expect(
        QrPairingValidator.resolveServerUrl(
          qrServerUrl: 'https://evil.example.com',
          configuredUrl: configured,
        ),
        isNull,
      );
    });

    test('rejects http scheme even when matching host', () {
      expect(
        QrPairingValidator.resolveServerUrl(
          qrServerUrl: 'http://saso.example.com',
          configuredUrl: 'http://saso.example.com',
        ),
        isNull,
      );
    });

    test('rejects when no server URL is configured yet', () {
      expect(
        QrPairingValidator.resolveServerUrl(
          qrServerUrl: configured,
          configuredUrl: '',
        ),
        isNull,
      );
    });

    test('rejects when configured URL is malformed', () {
      expect(
        QrPairingValidator.resolveServerUrl(
          qrServerUrl: null,
          configuredUrl: 'not a url',
        ),
        isNull,
      );
    });

    test('rejects when configured URL uses http even if QR has no override', () {
      expect(
        QrPairingValidator.resolveServerUrl(
          qrServerUrl: null,
          configuredUrl: 'http://saso.example.com',
        ),
        isNull,
      );
    });
  });
}
