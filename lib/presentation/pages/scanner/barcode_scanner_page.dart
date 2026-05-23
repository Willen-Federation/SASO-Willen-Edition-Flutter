import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../data/datasources/remote/isbn/isbn_lookup_service.dart';
import '../../../domain/value_objects/feature_code.dart';
import '../../../domain/value_objects/item_id.dart';
import '../../../domain/value_objects/shelf_id.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/common/adaptive_dialog.dart';

/// Foreground color used for the scan-frame border, hint text and processing
/// spinner that sit on top of the camera preview.
///
/// The camera feed is always dark, so a near-white token gives the same legible
/// contrast in both light and dark app themes — using a `colorScheme` token
/// here would make the overlay disappear when the user's theme matches the
/// camera image. Declared as a `const` so the choice is explicit (per #135 ACs)
/// rather than a stray `Colors.white` literal.
const Color _kScannerOverlayForeground = Color(0xFFFFFFFF);

/// Determines what happens when a barcode is successfully detected.
enum ScannerMode {
  /// Navigate to the matching item / shelf / feature page.
  search,

  /// Return the raw barcode string to the caller via [Navigator.pop].
  /// Backward-compatible replacement for the former [returnJanCode] parameter.
  register,

  /// Navigate to the inventory adjustment page with the scanned code.
  inventory,
}

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key, this.mode = ScannerMode.search});

  final ScannerMode mode;

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _processing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _processing = true);
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
    _route(raw);
  }

  void _route(String raw) {
    switch (widget.mode) {
      case ScannerMode.register:
        context.pop(raw);
        return;
      case ScannerMode.inventory:
        context.push('/inventory/adjust?janCode=${Uri.encodeComponent(raw)}');
        return;
      case ScannerMode.search:
        _routeSearch(raw);
    }
  }

  void _routeSearch(String raw) {
    // 12-digit → feature code → item detail
    final featureCode = FeatureCode.tryParse(raw);
    if (featureCode != null) {
      context.pushReplacement('/items/${featureCode.itemIdPart}');
      return;
    }

    // 8-digit → item ID
    final itemId = ItemId.tryParse(raw);
    if (itemId != null) {
      context.pushReplacement('/items/${itemId.value}');
      return;
    }

    // Alphanumeric 1–15 → shelf
    final shelfId = ShelfId.tryParse(raw);
    if (shelfId != null) {
      context.pushReplacement('/shelves/${shelfId.value}');
      return;
    }

    // ISBN → registration with auto-fill
    if (IsbnLookupService.isIsbn(raw)) {
      context.pushReplacement(
        '/items/register?janCode=${Uri.encodeComponent(raw)}',
      );
      return;
    }

    // Unrecognized — offer to register
    setState(() => _processing = false);
    _offerItemRegistration(raw);
  }

  void _offerItemRegistration(String janCode) {
    final l10n = AppLocalizations.of(context)!;
    showSasoAdaptiveDialog<bool>(
      context: context,
      title: l10n.barcodeScannerUnrecognizedTitle,
      message: l10n.barcodeScannerUnrecognizedMessage(janCode),
      actions: [
        AdaptiveDialogAction<bool>(label: l10n.cancel, value: false),
        AdaptiveDialogAction<bool>.primary(
          label: l10n.barcodeScannerRegisterItem,
          value: true,
          icon: Icons.add_box_outlined,
        ),
      ],
    ).then((confirmed) {
      if (!mounted || confirmed != true) return;
      context.pushReplacement(
        '/items/register?janCode=${Uri.encodeComponent(janCode)}',
      );
    });
  }

  String _title(AppLocalizations l10n) => switch (widget.mode) {
    ScannerMode.search => l10n.barcodeScannerTitleSearch,
    ScannerMode.register => l10n.barcodeScannerTitleRegister,
    ScannerMode.inventory => l10n.barcodeScannerTitleInventory,
  };

  String _hint(AppLocalizations l10n) => switch (widget.mode) {
    ScannerMode.search => l10n.barcodeScannerHintSearch,
    ScannerMode.register => l10n.barcodeScannerHintRegister,
    ScannerMode.inventory => l10n.barcodeScannerHintInventory,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
<<<<<<< HEAD
    return PopScope(
      // Issue #145: stop the mobile_scanner camera session as soon as the
      // Predictive Back gesture (Android 14+) commits to a pop. Without this
      // the preview keeps running underneath the back animation and OEM
      // devices (OnePlus / Xiaomi) can deliver an unhealthy camera handle
      // to the next route. `dispose()` still handles the final teardown.
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          _controller.stop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_title(l10n)),
          actions: [
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: _controller.toggleTorch,
              tooltip: l10n.barcodeScannerTorchTooltip,
            ),
            IconButton(
              icon: const Icon(Icons.flip_camera_ios),
              onPressed: _controller.switchCamera,
              tooltip: l10n.barcodeScannerSwitchCameraTooltip,
            ),
          ],
        ),
        body: Stack(
          children: [
            MobileScanner(controller: _controller, onDetect: _onDetect),
            // Scan overlay — group the visual frame with its purpose so
            // VoiceOver announces it as a single scanning region instead of
            // an unlabeled rectangle. The camera preview underneath is always
            // dark, so we use a fixed near-white token in both light and dark
            // themes; a ColorScheme token would disappear against the camera.
            Center(
              child: Semantics(
                container: true,
                label: 'バーコードスキャン領域',
                hint: 'バーコードをこの枠に合わせてください',
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _kScannerOverlayForeground,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
=======
    return Scaffold(
      appBar: AppBar(
        title: Text(_title(l10n)),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: _controller.toggleTorch,
            tooltip: l10n.barcodeScannerTorchTooltip,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: _controller.switchCamera,
            tooltip: l10n.barcodeScannerSwitchCameraTooltip,
          ),
        ],
      ),
      // Issue #146 — Android 15 edge-to-edge. The camera preview itself
      // fills behind the gesture inset, but the hint label must sit
      // above it, so its bottom offset incorporates the gesture-bar
      // padding from MediaQuery.viewPaddingOf.
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Scan overlay — group the visual frame with its purpose so
          // VoiceOver announces it as a single scanning region instead of
          // an unlabeled rectangle. The camera preview underneath is always
          // dark, so we use a fixed near-white token in both light and dark
          // themes; a ColorScheme token would disappear against the camera.
          Center(
            child: Semantics(
              container: true,
              label: 'バーコードスキャン領域',
              hint: 'バーコードをこの枠に合わせてください',
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _kScannerOverlayForeground,
                    width: 2,
>>>>>>> d064458 (feat(android): enable edge-to-edge layout for Android 15 (B7))
                  ),
                ),
              ),
            ),
<<<<<<< HEAD
            if (_processing)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Text(
                _hint(l10n),
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.white),
              ),
=======
          ),
          if (_processing)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          Positioned(
            bottom: 48 + MediaQuery.viewPaddingOf(context).bottom,
            left: 0,
            right: 0,
            child: Text(
              _hint(l10n),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white),
>>>>>>> d064458 (feat(android): enable edge-to-edge layout for Android 15 (B7))
            ),
          ],
        ),
      ),
    );
  }
}
