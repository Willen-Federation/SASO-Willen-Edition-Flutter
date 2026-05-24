import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/datasources/remote/isbn/isbn_lookup_service.dart';
import '../../../domain/value_objects/item_id.dart';
import '../../../presentation/providers/item_provider.dart';
import '../../layout/responsive.dart';
import '../../widgets/common/error_display_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/item/item_list_tile.dart';

class ItemSearchPage extends ConsumerStatefulWidget {
  const ItemSearchPage({super.key});

  @override
  ConsumerState<ItemSearchPage> createState() => _ItemSearchPageState();
}

class _ItemSearchPageState extends ConsumerState<ItemSearchPage> {
  final _controller = TextEditingController();

  /// Raw text the user typed / scanned.
  String _query = '';

  /// When the input looks like a barcode/label, these hold the routed values.
  String? _barcode;
  String? _isbn;
  String? _labelCode;

  /// Photo picked for image-based barcode search.
  XFile? _searchPhoto;
  bool _analyzingPhoto = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _query = '';
        _barcode = null;
        _isbn = null;
        _labelCode = null;
        _searchPhoto = null;
      });
      return;
    }

    // Exact 8-digit item ID → jump directly to detail page.
    final id = ItemId.tryParse(trimmed);
    if (id != null) {
      context.push('/items/${id.value}');
      return;
    }

    // ISBN → dedicated isbn param (exact match).
    // All-digit 8-14 chars → JAN/EAN barcode exact match.
    // Alphanumeric 2-32 chars with at least one letter → label code.
    // Everything else → keyword query.
    String? barcode;
    String? isbn;
    String? labelCode;

    if (IsbnLookupService.isIsbn(trimmed)) {
      isbn = IsbnLookupService.normalize(trimmed);
    } else if (RegExp(r'^\d{8,14}$').hasMatch(trimmed)) {
      barcode = trimmed;
    } else if (RegExp(r'^[A-Za-z0-9\-_]{2,32}$').hasMatch(trimmed) &&
        RegExp(r'[A-Za-z]').hasMatch(trimmed)) {
      labelCode = trimmed;
    }

    setState(() {
      _query = trimmed;
      _barcode = barcode;
      _isbn = isbn;
      _labelCode = labelCode;
    });
  }

  /// Opens the live barcode scanner and searches with the scanned code.
  Future<void> _scanBarcode() async {
    final code = await context.push<String?>('/scanner/jan');
    if (code == null || code.isEmpty) return;
    _controller.text = code;
    _onSearch(code);
  }

  /// Picks an image (camera or gallery), runs barcode detection on the still
  /// image using [MobileScannerController.analyzeImage], then searches with
  /// whatever barcode is found.  When no barcode is detected the photo
  /// thumbnail stays visible so the user knows their pick was registered, and
  /// a snack-bar explains that no code was found.
  Future<void> _pickPhotoAndSearch(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 90,
    );
    if (file == null) return;

    setState(() {
      _searchPhoto = file;
      _analyzingPhoto = true;
      // Clear previous search state while we analyse.
      _query = '';
      _barcode = null;
      _isbn = null;
      _labelCode = null;
    });

    try {
      final scanController = MobileScannerController();
      BarcodeCapture? capture;
      try {
        capture = await scanController.analyzeImage(file.path);
      } finally {
        await scanController.dispose();
      }

      if (!mounted) return;

      final raw = capture?.barcodes.firstOrNull?.rawValue;
      if (raw != null && raw.isNotEmpty) {
        _controller.text = raw;
        _onSearch(raw);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('バーコードが検出できませんでした。キーワードで検索してください。')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('画像解析エラー: $e')));
    } finally {
      if (mounted) setState(() => _analyzingPhoto = false);
    }
  }

  /// Bottom sheet asking the user to choose camera or gallery.
  Future<void> _showPhotoSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('カメラで撮影'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('ライブラリから選択'),
              onTap: () => Navigator.of(ctx).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    await _pickPhotoAndSearch(source);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: TextField(
        key: const Key('search_field'),
        controller: _controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'アイテム名 / JAN / ISBN / ラベル',
          border: InputBorder.none,
        ),
        onSubmitted: _onSearch,
        textInputAction: TextInputAction.search,
      ),
      actions: [
        // Photo search button
        IconButton(
          icon: const Icon(Icons.add_a_photo_outlined),
          tooltip: '写真で検索',
          onPressed: _analyzingPhoto ? null : _showPhotoSourceSheet,
        ),
        // Live barcode scan button
        IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          tooltip: 'バーコードスキャン',
          onPressed: _scanBarcode,
        ),
        IconButton(
          icon: const Icon(Icons.search),
          tooltip: '検索',
          onPressed: () => _onSearch(_controller.text),
        ),
      ],
    ),
    body: Column(
      children: [
        // ── Photo preview + analysing indicator ──────────────────────────
        if (_searchPhoto != null)
          _PhotoSearchBanner(
            photo: _searchPhoto!,
            analysing: _analyzingPhoto,
            onClear: () => setState(() {
              _searchPhoto = null;
              _query = '';
              _barcode = null;
              _isbn = null;
              _labelCode = null;
              _controller.clear();
            }),
          ),

        // ── Results ──────────────────────────────────────────────────────
        Expanded(
          child: _analyzingPhoto
              ? const Center(child: LoadingWidget())
              : _query.isEmpty
              ? const Center(
                  child: Text(
                    'キーワードを入力・バーコードをスキャン\nまたは写真で検索',
                    textAlign: TextAlign.center,
                  ),
                )
              : _SearchResults(
                  query:
                      (_barcode == null && _isbn == null && _labelCode == null)
                      ? _query
                      : null,
                  barcode: _barcode,
                  isbn: _isbn,
                  labelCode: _labelCode,
                ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Photo search banner
// ---------------------------------------------------------------------------

class _PhotoSearchBanner extends StatelessWidget {
  const _PhotoSearchBanner({
    required this.photo,
    required this.analysing,
    required this.onClear,
  });

  final XFile photo;
  final bool analysing;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadii.smAll,
            child: Image.file(
              File(photo.path),
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              semanticLabel: '検索に使用する写真',
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              analysing ? 'バーコードを解析中…' : '写真から検索',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (analysing)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: onClear,
              tooltip: '写真をクリア',
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Search results
// ---------------------------------------------------------------------------

class _SearchResults extends ConsumerWidget {
  const _SearchResults({this.query, this.barcode, this.isbn, this.labelCode});

  final String? query;
  final String? barcode;
  final String? isbn;
  final String? labelCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(
      itemSearchProvider(
        query: query,
        barcode: barcode,
        isbn: isbn,
        labelCode: labelCode,
      ),
    );

    return results.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => ErrorDisplayWidget(error: e),
      data: (items) {
        if (items.isEmpty) {
          return const Center(child: Text('結果が見つかりません'));
        }
        final responsive = Responsive.of(context);
        final crossAxisCount = responsive.adaptiveColumns(
          mobile: 1,
          tablet: 2,
          desktop: 3,
        );
        if (crossAxisCount == 1) {
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, i) => ItemListTile(
              item: items[i],
              onTap: () => context.push('/items/${items[i].id.value}'),
            ),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 96,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => ItemListTile(
            item: items[i],
            onTap: () => context.push('/items/${items[i].id.value}'),
          ),
        );
      },
    );
  }
}
