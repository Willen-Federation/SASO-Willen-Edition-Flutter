import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../data/datasources/remote/isbn/isbn_lookup_service.dart';
import '../../../domain/value_objects/feature_code.dart';
import '../../../domain/value_objects/item_id.dart';
import '../../../domain/value_objects/shelf_id.dart';

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
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('コードを認識できません'),
        content: Text('$janCode\n\nこのコードで新しいアイテムを登録しますか？'),
        actions: [
          TextButton(onPressed: () => ctx.pop(), child: const Text('キャンセル')),
          FilledButton.icon(
            onPressed: () {
              ctx.pop();
              context.pushReplacement(
                '/items/register?janCode=${Uri.encodeComponent(janCode)}',
              );
            },
            icon: const Icon(Icons.add_box_outlined),
            label: const Text('アイテム登録'),
          ),
        ],
      ),
    );
  }

  String get _title => switch (widget.mode) {
    ScannerMode.search => 'バーコードスキャン',
    ScannerMode.register => 'バーコード読み取り',
    ScannerMode.inventory => '入出庫スキャン',
  };

  String get _hint => switch (widget.mode) {
    ScannerMode.search => 'バーコードをフレーム内に合わせてください',
    ScannerMode.register => '読み取るバーコードをフレーム内に合わせてください',
    ScannerMode.inventory => '棚または商品のバーコードをスキャンしてください',
  };

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
    // Camera feed fills the background — force light status-bar icons so
    // the time / battery indicators stay readable over the (typically
    // dark) live preview regardless of platform theme.
    value: SystemUiOverlayStyle.light,
    child: Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: _controller.toggleTorch,
            tooltip: 'フラッシュ',
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: _controller.switchCamera,
            tooltip: 'カメラ切替',
          ),
        ],
      ),
      // The camera preview should fill the whole body (notch included)
      // for the best framing experience, but the hint text overlay must
      // not collide with the home indicator on iPhone X+ devices. Wrap
      // the overlays in a SafeArea (preview stays outside it).
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Scan overlay (centered — naturally inside safe bounds).
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          if (_processing)
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          // Bottom hint — keep clear of the home indicator.
          SafeArea(
            top: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32, left: 16, right: 16),
                child: Text(
                  _hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
