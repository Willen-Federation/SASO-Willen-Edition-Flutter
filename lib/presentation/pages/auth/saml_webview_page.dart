import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// In-app WebView for SAML SSO login flows.
///
/// Opens the IdP SSO [loginUrl] and monitors navigation events for the
/// callback URL scheme "jp.willen.saso://callback".  When detected, it
/// extracts the `token` query parameter and returns it to the caller via
/// [Navigator.pop].
///
/// Usage:
///   final token = await Navigator.push&lt;String&gt;(
///     context,
///     MaterialPageRoute(builder: (_) => SamlWebViewPage(loginUrl: url)),
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
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (_) => setState(() => _loading = true),
              onPageFinished: (_) => setState(() => _loading = false),
              onNavigationRequest: (request) {
                final uri = Uri.tryParse(request.url);
                if (uri != null &&
                    uri.scheme == SamlWebViewPage.callbackScheme) {
                  final token = uri.queryParameters['token'];
                  Navigator.of(context).pop(token);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              },
            ),
          )
          ..loadRequest(Uri.parse(widget.loginUrl));
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
