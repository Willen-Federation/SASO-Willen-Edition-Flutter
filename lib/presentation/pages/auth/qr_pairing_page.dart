import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/network/url_validator.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/server_config_provider.dart';

/// QR code pairing page for SASO token exchange.
///
/// Scans QR codes in the format:
///   SASO1:{base64url_token}|{server_url}
///
/// After a successful scan the pairing token is exchanged for a JWT via
/// POST /api/v1/mobile/connect.  On success the app navigates to /home.
class QrPairingPage extends ConsumerStatefulWidget {
  const QrPairingPage({super.key});

  @override
  ConsumerState<QrPairingPage> createState() => _QrPairingPageState();
}

class _QrPairingPageState extends ConsumerState<QrPairingPage> {
  final _controller = MobileScannerController();
  bool _processing = false;
  String? _errorMessage;

  static const _prefix = 'SASO1:';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || !raw.startsWith(_prefix)) return;

    setState(() {
      _processing = true;
      _errorMessage = null;
    });
    await _controller.stop();

    // Parse SASO1:{token}|{serverUrl}
    final payload = raw.substring(_prefix.length);
    final parts = payload.split('|');
    final pairingToken = parts.first;

    // Security: the configured server URL is the source of truth. If the
    // QR claims a different host, we reject — see #24. An attacker-printed
    // QR that points the device at evil.example.com could otherwise phish
    // the pairing token.
    final qrServerUrl = parts.length > 1 ? parts[1] : null;
    final configuredUrl = ref.read(serverConfigNotifierProvider).baseUrl;

    if (configuredUrl.isEmpty) {
      setState(() {
        _processing = false;
        _errorMessage = 'サーバーURLが設定されていません。設定画面から入力してください。';
      });
      await _controller.start();
      return;
    }

    final Uri configured;
    try {
      configured = UrlValidator.ensureHttpsOrLoopback(configuredUrl);
    } on ArgumentError catch (e) {
      setState(() {
        _processing = false;
        _errorMessage = '設定済みのサーバーURLが不正です: ${e.message}';
      });
      await _controller.start();
      return;
    }

    if (qrServerUrl != null && qrServerUrl.isNotEmpty) {
      final Uri claimed;
      try {
        claimed = UrlValidator.ensureHttpsOrLoopback(qrServerUrl);
      } on ArgumentError {
        setState(() {
          _processing = false;
          _errorMessage = 'QRコードに含まれるサーバーURLが不正です。';
        });
        await _controller.start();
        return;
      }
      if (claimed.host != configured.host ||
          claimed.scheme != configured.scheme ||
          claimed.port != configured.port) {
        setState(() {
          _processing = false;
          _errorMessage = 'QRコードのサーバーURLが設定と一致しません。安全のため取り消されました。';
        });
        await _controller.start();
        return;
      }
    }

    final serverUrl = configured.toString();

    final result = await ref
        .read(authStateNotifierProvider.notifier)
        .loginWithQrToken(pairingToken: pairingToken, serverUrl: serverUrl);

    if (!mounted) return;

    result.when(
      success: (_, __, ___, ____) => context.go('/home'),
      failure: (msg, __) {
        setState(() {
          _processing = false;
          _errorMessage = msg;
        });
        _controller.start();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Issue #21 — i18n adoption. The title is the first proof-of-wire
    // call site; the rest of this page's hardcoded strings are TODO
    // for a follow-up sweep once the i18n PR has merged and the
    // generated AppLocalizations is in `flutter pub get` output.
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.qrPairingTitle),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller,
              builder:
                  (_, state, __) => Icon(
                    state.torchState == TorchState.on
                        ? Icons.flash_off
                        : Icons.flash_on,
                  ),
            ),
            onPressed: _controller.toggleTorch,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),

          // Scanning overlay
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Status overlay at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(16),
              child:
                  _processing
                      ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'ペアリング中...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                      : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_errorMessage != null) ...[
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                          ],
                          const Text(
                            'SASO管理画面に表示されたQRコードをスキャンしてください',
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
