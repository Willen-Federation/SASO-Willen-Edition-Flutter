import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/core/errors/problem_details.dart';
import 'package:saso_willen_edition/data/datasources/remote/v1/rest_api_client.dart';

import 'helpers/fake_http_client.dart';

void main() {
  test(
    'A 403 SASO-MOBILE-2008 surfaces as a scope-insufficient problem',
    () async {
      final backend = FakeBackend({
        'POST /api/v1/items':
            (_) => problem(
              status: 403,
              code: 'SASO-MOBILE-2008',
              detail: 'This endpoint requires the "items:write" scope.',
              extraHeaders: {
                'WWW-Authenticate':
                    'Bearer realm="api", error="insufficient_scope", scope="items:write"',
              },
            ),
      });

      final client = RestV1ApiClient(
        serverUrl: 'https://example.test',
        jwtToken: 'access',
        httpClient: backend.toClient(),
      );

      Object? captured;
      try {
        await client.createItem({'name': 'X', 'categoryId': 1});
      } catch (e) {
        captured = e;
      }

      expect(captured, isA<ProblemDetails>());
      final pd = captured! as ProblemDetails;
      expect(pd.status, 403);
      expect(pd.sasoCode, 'SASO-MOBILE-2008');
      expect(pd.isScopeInsufficient, isTrue);
      expect(pd.domain, SasoErrorDomain.mobile);
    },
  );
}
