import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// In-app WebView for SAML SSO login flows.
///
/// Opens the IdP SSO [loginUrl] and monitors navigation events for the
/// callback URL scheme "jp.willen.saso://callback".  When detected, it
/// extracts the `token` query parameter and returns it to the caller via
/// [Navigator.pop].
///
/// Security (see MED-001): callbacks are only accepted when the previous
/// successful navigation was to the configured IdP host. This blocks
/// open-redirect / XSS scenarios where the IdP page could be tricked into
/// driving the WebView to `jp.willen.saso://callback?token=ATTACKER_JWT`.
class SamlWebViewPage extends StatefulWidget {
  const SamlWebViewPage({super.key, required this.loginUrl});

  final String loginUrl;

  /// URL scheme used as the SAML callback / redirect target.
  static const callbackScheme = 'jp.willen.saso';

  /// Single accepted callback path — anything else is rejected.
  static const callbackPath = '/callback';

  @override
  State<SamlWebViewPage> createState() => _SamlWebViewPageState();
}

class _SamlWebViewPageState extends State<SamlWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;
  String? _lastNavigatedHost;
  late final String _idpHost;

  @override
  void initState() {
    super.initState();
    _idpHost = Uri.tryParse(widget.loginUrl)?.host ?? '';

    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                final host = Uri.tryParse(url)?.host;
                if (host != null && host.isNotEmpty) {
                  _lastNavigatedHost = host;
                }
                setState(() => _loading = true);
              },
              onPageFinished: (_) => setState(() => _loading = false),
              onNavigationRequest: (request) {
                final uri = Uri.tryParse(request.url);
                if (uri == null) return NavigationDecision.navigate;

                if (uri.scheme == SamlWebViewPage.callbackScheme) {
                  final isAllowed = _isCallbackAllowed(uri);
                  if (!isAllowed) return NavigationDecision.prevent;

                  final token = uri.queryParameters['token'];
                  if (token == null || token.isEmpty) {
                    return NavigationDecision.prevent;
                  }
                  Navigator.of(context).pop(token);
                  return NavigationDecision.prevent;
                }

                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.loginUrl));
  }

  /// Accepts the SAML callback only when:
  /// * The preceding page came from the IdP host configured at construction.
  /// * The callback URI uses the single allowed path (`/callback`).
  bool _isCallbackAllowed(Uri uri) {
    if (_idpHost.isEmpty) return false;
    if (_lastNavigatedHost != _idpHost) return false;
    final path = uri.path.isEmpty ? '/' : uri.path;
    return path == SamlWebViewPage.callbackPath;
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
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
