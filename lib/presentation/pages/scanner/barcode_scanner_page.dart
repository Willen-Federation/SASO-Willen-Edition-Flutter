import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../data/datasources/remote/isbn/isbn_lookup_service.dart';
import '../../../domain/value_objects/feature_code.dart';
import '../../../domain/value_objects/item_id.dart';
import '../../../domain/value_objects/shelf_id.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key, this.returnJanCode = false});

  /// When true, the first detected barcode is returned to the caller via
  /// [Navigator.pop] instead of navigating to item/shelf pages.
  final bool returnJanCode;

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
    final barcode = capture.barcodes.firstOrNull;
    final raw = barcode?.rawValue;
    if (raw == null || raw.isEmpty) return;

    setState(() => _processing = true);
    _route(raw);
  }

  void _route(String raw) {
    // JAN capture mode: return the raw barcode value to the caller.
    if (widget.returnJanCode) {
      context.pop(raw);
      return;
    }

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

    // ISBN detected — route directly to registration with auto-fill.
    if (IsbnLookupService.isIsbn(raw)) {
      context.pushReplacement(
        '/items/register?janCode=${Uri.encodeComponent(raw)}',
      );
      return;
    }

    // Unrecognized code — offer to register as new item.
    setState(() => _processing = false);
    _offerItemRegistration(raw);
  }

  void _offerItemRegistration(String janCode) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('コードを認識できません'),
        content: Text(
          '$janCode\n\nこのコードで新しいアイテムを登録しますか？',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('キャンセル'),
          ),
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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('バーコードスキャン'),
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
    body: Stack(
      children: [
        MobileScanner(controller: _controller, onDetect: _onDetect),
        // Scan overlay
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
        const Positioned(
          bottom: 48,
          left: 0,
          right: 0,
          child: Text(
            'バーコードをフレーム内に合わせてください',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    ),
  );
}
