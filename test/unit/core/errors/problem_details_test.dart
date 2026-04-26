import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/core/errors/problem_details.dart';

void main() {
  group('ProblemDetails', () {
    test('fromJson parses RFC 7807 fields', () {
      final json = {
        'type': 'https://example.com/errors/not-found',
        'title': 'Item not found',
        'status': 404,
        'detail': 'Item 24010001 does not exist',
        'instance': '/items/24010001',
      };

      final pd = ProblemDetails.fromJson(json);

      expect(pd.type, 'https://example.com/errors/not-found');
      expect(pd.title, 'Item not found');
      expect(pd.status, 404);
      expect(pd.detail, 'Item 24010001 does not exist');
      expect(pd.instance, '/items/24010001');
    });

    test('fromJson parses SASO code extension', () {
      final json = {
        'type': 'https://api.saso.example/errors/item-not-found',
        'title': 'Item Not Found',
        'status': 404,
        'code': 'SASO-ITEM-2001',
        'traceId': 'abc-123',
      };

      final pd = ProblemDetails.fromJson(json);
      expect(pd.sasoCode, 'SASO-ITEM-2001');
      expect(pd.traceId, 'abc-123');
    });

    test('domain extracts AUTH from SASO-AUTH-1003', () {
      const pd = ProblemDetails(
        type: 'about:blank',
        title: 'Unauthorized',
        status: 401,
        sasoCode: 'SASO-AUTH-1003',
      );
      expect(pd.domain, SasoErrorDomain.auth);
    });

    test('domain extracts ITEM from SASO-ITEM-2001', () {
      const pd = ProblemDetails(
        type: 'about:blank',
        title: 'Not Found',
        status: 404,
        sasoCode: 'SASO-ITEM-2001',
      );
      expect(pd.domain, SasoErrorDomain.item);
    });

    test('domain extracts SHELF from SASO-SHELF-4001', () {
      const pd = ProblemDetails(
        type: 'about:blank',
        title: 'Shelf Error',
        status: 400,
        sasoCode: 'SASO-SHELF-4001',
      );
      expect(pd.domain, SasoErrorDomain.shelf);
    });

    test('domain returns unknown when sasoCode is null', () {
      const pd = ProblemDetails(
        type: 'about:blank',
        title: 'Error',
        status: 500,
      );
      expect(pd.domain, SasoErrorDomain.unknown);
    });

    test('domain returns unknown for malformed code', () {
      const pd = ProblemDetails(
        type: 'about:blank',
        title: 'Error',
        status: 500,
        sasoCode: 'MALFORMED',
      );
      expect(pd.domain, SasoErrorDomain.unknown);
    });

    test('implements Exception', () {
      const pd = ProblemDetails(
        type: 'about:blank',
        title: 'Error',
        status: 500,
      );
      expect(pd, isA<Exception>());
    });

    test('toString includes status and title', () {
      const pd = ProblemDetails(
        type: 'about:blank',
        title: 'Not Found',
        status: 404,
        detail: 'Resource missing',
        sasoCode: 'SASO-ITEM-2001',
      );
      final str = pd.toString();
      expect(str, contains('404'));
      expect(str, contains('Not Found'));
    });
  });

  group('SasoErrorDomain', () {
    test('fromString is case-insensitive', () {
      expect(SasoErrorDomain.fromString('auth'), SasoErrorDomain.auth);
      expect(SasoErrorDomain.fromString('AUTH'), SasoErrorDomain.auth);
      expect(SasoErrorDomain.fromString('Auth'), SasoErrorDomain.auth);
    });

    test('fromString handles all known domains', () {
      expect(SasoErrorDomain.fromString('ITEM'), SasoErrorDomain.item);
      expect(SasoErrorDomain.fromString('LABEL'), SasoErrorDomain.label);
      expect(SasoErrorDomain.fromString('SHELF'), SasoErrorDomain.shelf);
      expect(SasoErrorDomain.fromString('INSTALL'), SasoErrorDomain.install);
      expect(SasoErrorDomain.fromString('INFRA'), SasoErrorDomain.infra);
    });

    test('fromString returns unknown for unrecognized domain', () {
      expect(
        SasoErrorDomain.fromString('UNKNOWN_DOMAIN'),
        SasoErrorDomain.unknown,
      );
      expect(SasoErrorDomain.fromString(''), SasoErrorDomain.unknown);
    });
  });
}
