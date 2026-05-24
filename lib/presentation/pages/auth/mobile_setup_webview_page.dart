import 'dart:math' show Random;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/network/url_validator.dart';
import '../../../core/theme/app_spacing.dart';

/// In-app WebView wrapping the server's `/m/setup` flow used to log in via
/// any server-configured provider (OIDC / SAML / Auth0 / Cognito / Firebase
/// — or the local username/password form when reached through the chooser).
///
/// The Flutter app does not embed per-provider OAuth / SAML config (those
/// secrets are deliberately not exposed by the public discovery endpoint).
/// Instead, the user is sent to `{serverUrl}/m/setup?provider_id={id}&
/// redirect_uri=jp.willen.saso://callback&state={csrf}`, the server runs
/// the IdP dance, and `/m/issue-pairing` finally 303-redirects to
/// `jp.willen.saso://callback#token=…&state=…&server=…`.
///
/// This page intercepts that custom-scheme navigation and returns the raw
/// pairing token to the caller via `Navigator.pop(token)`. The caller then
/// exchanges the token for a JWT via `POST /api/v1/mobile/connect`.
class MobileSetupWebViewPage extends StatefulWidget {
  const MobileSetupWebViewPage({
    super.key,
    required this.serverUrl,
    this.providerId,
    this.providerName,
  });

  /// Base server URL (e.g. `https://saso.example.com`). The page composes
  /// `{serverUrl}/m/setup?...` from this.
  final String serverUrl;

  /// Optional `provider_id` query parameter. When non-null the server skips
  /// its chooser and routes straight to that provider; when null the user
  /// picks on the server-rendered chooser page.
  final int? providerId;

  /// Human-readable provider name, shown in the app bar.
  final String? providerName;

  /// URL scheme registered as the deep-link callback on iOS / Android.
  static const callbackScheme = 'jp.willen.saso';

  /// Allowlisted path component on the callback; the server's
  /// RedirectUriAllowlist (see config/mobile.php) accepts exactly
  /// `jp.willen.saso://callback`.
  static const callbackHost = 'callback';

  @override
  State<MobileSetupWebViewPage> createState() => _MobileSetupWebViewPageState();
}

class _MobileSetupWebViewPageState extends State<MobileSetupWebViewPage> {
  WebViewController? _controller;
  String? _initError;
  bool _loading = true;

  late final Uri _trustedOrigin;
  late final String _state;

  @override
  void initState() {
    super.initState();

    final Uri base;
    try {
      base = UrlValidator.ensureHttpsOrLoopback(widget.serverUrl);
    } on ArgumentError catch (e) {
      _initError = e.message?.toString() ?? 'Invalid server URL';
      _loading = false;
      return;
    }
    _trustedOrigin = Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
    );
    _state = _randomState();

    final setupUrl = base.replace(
      path: '${base.path.replaceAll(RegExp(r'/$'), '')}/m/setup',
      queryParameters: <String, String>{
        'redirect_uri':
            '${MobileSetupWebViewPage.callbackScheme}://${MobileSetupWebViewPage.callbackHost}',
        'state': _state,
        if (widget.providerId != null) 'provider_id': '${widget.providerId}',
      },
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (_) => setState(() => _loading = false),
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;

            if (uri.scheme == MobileSetupWebViewPage.callbackScheme) {
              final token = _extractToken(uri);
              Navigator.of(context).pop(token);
              return NavigationDecision.prevent;
            }

            // Same-origin gate. The `/m/setup` flow may redirect to an
            // external IdP — we relax the origin check to "either trusted
            // origin OR HTTPS" so OIDC providers (login.microsoftonline.com,
            // accounts.google.com, etc.) load while still rejecting plain
            // http:// redirects.
            if (_isSameOrigin(uri)) return NavigationDecision.navigate;
            if (uri.scheme == 'https') return NavigationDecision.navigate;

            AppLogger.warn(
              'MobileSetupWebView',
              'blocked navigation to ${uri.scheme}://${uri.host}',
            );
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(setupUrl);
  }

  /// Pulls the raw pairing token out of a callback URI.
  ///
  /// The server returns `…#token=<raw>&state=<state>&server=<base>` — Dart's
  /// [Uri] surfaces the fragment as a query-style string, so we feed it
  /// through [Uri.splitQueryString].
  String? _extractToken(Uri callback) {
    final fragment = callback.fragment;
    if (fragment.isNotEmpty) {
      final params = Uri.splitQueryString(fragment);
      final token = params['token'];
      final returnedState = params['state'];
      if (returnedState != _state) {
        AppLogger.warn(
          'MobileSetupWebView',
          'state mismatch (expected $_state, got $returnedState)',
        );
        return null;
      }
      if (token != null && token.isNotEmpty) return token;
    }
    // Server *should* use the fragment; some edge cases (manual testing,
    // proxies that strip fragments) may forward via query params instead.
    final qpToken = callback.queryParameters['token'];
    if (qpToken != null && qpToken.isNotEmpty) {
      final returnedState = callback.queryParameters['state'];
      if (returnedState != null && returnedState != _state) return null;
      return qpToken;
    }
    return null;
  }

  bool _isSameOrigin(Uri candidate) {
    if (candidate.scheme != _trustedOrigin.scheme) return false;
    if (candidate.host.toLowerCase() != _trustedOrigin.host.toLowerCase()) {
      return false;
    }
    final cPort = candidate.hasPort
        ? candidate.port
        : _defaultPort(candidate.scheme);
    final tPort = _trustedOrigin.hasPort
        ? _trustedOrigin.port
        : _defaultPort(_trustedOrigin.scheme);
    return cPort == tPort;
  }

  static int _defaultPort(String scheme) => switch (scheme.toLowerCase()) {
    'https' => 443,
    'http' => 80,
    _ => 0,
  };

  /// 32-char URL-safe nonce that the server echoes back in the callback
  /// fragment. Must satisfy the server-side regex `[A-Za-z0-9_\-]{16,128}`.
  static String _randomState() {
    const alphabet =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_';
    final rnd = Random.secure();
    return List.generate(
      32,
      (_) => alphabet[rnd.nextInt(alphabet.length)],
    ).join();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.providerName == null
        ? 'サーバーログイン'
        : '${widget.providerName} でログイン';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: '閉じる',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _initError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'サーバーURLが無効です: $_initError',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller!),
                if (_loading) const LinearProgressIndicator(),
              ],
            ),
    );
  }
}
