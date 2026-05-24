import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:saso_willen_edition/l10n/app_localizations.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/network/url_validator.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/server_config_provider.dart';
import '../../widgets/common/adaptive_dialog.dart';

/// Foreground / background colours used for the QR-scan overlay that sits on
/// top of the live camera preview. The camera feed is effectively a fixed
/// dark surface so these intentionally do not follow `ColorScheme`; using a
/// theme token here would make the overlay disappear in dark mode. Declared
/// as `const` constants so the choice is explicit (per #128 ACs) rather than
/// scattered `Colors.white` / `Colors.black54` literals.
const Color _kPairingOverlayForeground = Color(0xFFFFFFFF);
const Color _kPairingOverlayMutedForeground = Color(0xB3FFFFFF); // white70
const Color _kPairingOverlayScrim = Color(0x8A000000); // black54
const Color _kPairingOverlayError = Color(0xFFEF5350); // red 400

/// QR code pairing page for SASO token exchange.
///
/// Scans QR codes in the format:
///   SASO1:{base64url_token}|{server_url}
///
/// After a successful scan the pairing token is exchanged for a JWT via
/// POST /api/v1/mobile/connect. On success the user sees a brief
/// confirmation dialog before being routed to /home.
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

    final l10n = AppLocalizations.of(context)!;

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
        _errorMessage = l10n.qrPairingNoServerUrl;
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
        _errorMessage = l10n.qrPairingServerInvalid(e.message.toString());
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
          _errorMessage = l10n.qrPairingQrUrlInvalid;
        });
        await _controller.start();
        return;
      }
      if (claimed.host != configured.host ||
          claimed.scheme != configured.scheme ||
          claimed.port != configured.port) {
        setState(() {
          _processing = false;
          _errorMessage = l10n.qrPairingUrlMismatchExplain;
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
      success: (_, __, ___, ____) => _showPairingSuccess(configured.host),
      failure: (msg, __) {
        setState(() {
          _processing = false;
          _errorMessage = msg;
        });
        _controller.start();
      },
    );
  }

  /// Shows a brief success confirmation before navigating, using the
  /// platform-native dialog style. iPhone 17 (iOS 26.5) gets a Cupertino
  /// alert, Pixel 7a stays on Material — both with the same pictogram.
  Future<void> _showPairingSuccess(String serverHost) async {
    final l10n = AppLocalizations.of(context)!;
    final navigator = GoRouter.of(context);

    await showSasoAdaptiveDialog<void>(
      context: context,
      barrierDismissible: false,
      icon: Icon(
        Icons.check_circle_outline,
        color: context.semanticColors.success,
        size: 48,
      ),
      title: l10n.qrPairingSuccessTitle,
      message: l10n.qrPairingSuccessBody(serverHost),
      actions: [AdaptiveDialogAction.primary(label: l10n.qrPairingContinue)],
    );
    if (!mounted) return;
    navigator.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Camera preview fills the screen — force light status-bar icons so
    // they stay readable against the (typically dark) live feed.
    //
    // Issue #146 — Android 15 edge-to-edge. The camera fills the whole
    // window. The bottom status overlay is wrapped in SafeArea so its
    // text isn't covered by the gesture-bar inset.
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.qrPairingTitle),
          actions: [
            IconButton(
              icon: ValueListenableBuilder(
                valueListenable: _controller,
                builder: (_, state, __) => Icon(
                  state.torchState == TorchState.on
                      ? Icons.flash_off
                      : Icons.flash_on,
                ),
              ),
              tooltip: 'フラッシュ切替',
              onPressed: _controller.toggleTorch,
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(controller: _controller, onDetect: _onDetect),

            // Scanning overlay — group the visual frame with its purpose so
            // VoiceOver announces a single QR scanning region instead of an
            // unlabeled rectangle.
            Center(
              child: Semantics(
                container: true,
                label: 'QRコードスキャン領域',
                hint: 'QRコードをこの枠に合わせてください',
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _kPairingOverlayForeground,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // Status overlay at the bottom — wrap in SafeArea so the
            // translucent panel does not collide with the iPhone home
            // indicator.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  color: _kPairingOverlayScrim,
                  padding: const EdgeInsets.all(16),
                  child: _processing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _kPairingOverlayForeground,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              l10n.qrPairingInProgress,
                              style: const TextStyle(
                                color: _kPairingOverlayForeground,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_errorMessage != null) ...[
                              Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: _kPairingOverlayError,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                            ],
                            Text(
                              l10n.qrPairingInstruction,
                              style: const TextStyle(
                                color: _kPairingOverlayMutedForeground,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
