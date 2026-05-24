import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/logging/app_logger.dart';
import '../../../core/network/url_validator.dart';

/// In-app WebView for SAML SSO login flows.
///
/// Opens the IdP SSO [loginUrl] and monitors navigation events for the
/// callback URL scheme "jp.willen.saso://callback".  When detected, it
/// extracts the `token` query parameter and returns it to the caller via
/// [Navigator.pop].
///
/// Issue #26-MED-001 — host validation:
/// Two safeguards against a hostile `loginUrl`:
///   1. The initial URL is validated through `UrlValidator.ensureHttpsOrLoopback`.
///      Non-HTTPS schemes (or HTTPS with no authority) are rejected
///      before the WebView is constructed.
///   2. Every cross-origin navigation is rejected — once the WebView
///      lands on the IdP origin, only same-origin redirects (or the
///      app's custom-scheme callback) are allowed. This prevents an
///      attacker who controls a *redirect* on the IdP from
///      exfiltrating cookies / query params to an arbitrary host.
///
/// Usage:
///   final token = await Navigator.push&lt;String&gt;(
///     context,
///     adaptivePageRoute(builder: (_) => SamlWebViewPage(loginUrl: url)),
///   );
class SamlWebViewPage extends StatefulWidget {
  const SamlWebViewPage({super.key, required this.loginUrl});

  final String loginUrl;

  /// URL scheme used as the SAML callback / redirect target.
  static const callbackScheme = 'jp.willen.saso';

  @override
  State<SamlWebViewPage> createState() => _SamlWebViewPageState();
}

class _SamlWebViewPageState extends State<SamlWebViewPage> {
  WebViewController? _controller;
  String? _initError;
  bool _loading = true;

  /// The origin (scheme://host:port) of the validated [SamlWebViewPage.loginUrl].
  /// Set once in [initState]; navigation requests outside this origin
  /// are denied.
  late final Uri _trustedOrigin;

  @override
  void initState() {
    super.initState();
    final Uri validated;
    try {
      validated = UrlValidator.ensureHttpsOrLoopback(widget.loginUrl);
    } on ArgumentError catch (e) {
      _initError = e.message?.toString() ?? 'Invalid SAML login URL';
      _loading = false;
      return;
    }
    _trustedOrigin = Uri(
      scheme: validated.scheme,
      host: validated.host,
      port: validated.hasPort ? validated.port : null,
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

            // App's custom callback scheme — always allowed; pops
            // the token back to the caller.
            if (uri.scheme == SamlWebViewPage.callbackScheme) {
              final token = uri.queryParameters['token'];
              Navigator.of(context).pop(token);
              return NavigationDecision.prevent;
            }

            // Host validation: only allow same-origin navigation
            // (HTTPS scheme + identical host + identical port).
            // This prevents an attacker controlling a redirect at
            // the IdP from sending the cookie-bearing request to
            // an arbitrary host.
            if (!_isSameOrigin(uri)) {
              AppLogger.warn(
                'SamlWebView',
                'blocked cross-origin navigation to ${uri.origin}',
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(validated);
  }

  bool _isSameOrigin(Uri candidate) {
    if (candidate.scheme != _trustedOrigin.scheme) return false;
    if (candidate.host.toLowerCase() != _trustedOrigin.host.toLowerCase()) {
      return false;
    }
    // Default port comparison: 0 / no-port means the scheme's default.
    final cPort = candidate.hasPort
        ? candidate.port
        : _defaultPort(candidate.scheme);
    final tPort = _trustedOrigin.hasPort
        ? _trustedOrigin.port
        : _defaultPort(_trustedOrigin.scheme);
    return cPort == tPort;
  }

  static int _defaultPort(String scheme) {
    switch (scheme.toLowerCase()) {
      case 'https':
        return 443;
      case 'http':
        return 80;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SSOログイン'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _initError != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'SSOログインURLが無効です: $_initError',
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
