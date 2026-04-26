import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../domain/value_objects/feature_code.dart';
import '../../../domain/value_objects/item_id.dart';
import '../../../domain/value_objects/shelf_id.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

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

    setState(() => _processing = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('認識できないコード: $raw')));
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
        Positioned(
          bottom: 48,
          left: 0,
          right: 0,
          child: const Text(
            'バーコードをフレーム内に合わせてください',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      ],
    ),
  );
}
