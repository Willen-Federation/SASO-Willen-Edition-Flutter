import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/storage/database_helper.dart';
import '../../../data/datasources/local/pending_registration_dao.dart';
import '../../../data/datasources/local/price_history_dao.dart';
import '../../../data/datasources/remote/isbn/isbn_lookup_service.dart';
import '../../../data/datasources/remote/v1/rest_api_client.dart';
import '../../../data/models/book_info_model.dart';
import '../../../data/models/mcp_item_model.dart';
import '../../../data/models/pending_registration.dart';
import '../../../data/models/price_history_entry.dart';
import '../../../domain/entities/category.dart';
import '../../providers/category_provider.dart';
import '../../providers/isbn_provider.dart';
import '../../providers/mcp_provider.dart';
import '../../providers/server_config_provider.dart';
import '../../widgets/price_history_chart.dart';

class ItemRegisterPage extends ConsumerStatefulWidget {
  const ItemRegisterPage({super.key, this.prefillJanCode});

  /// Pre-fill the JAN code field (e.g., after a barcode scan).
  final String? prefillJanCode;

  @override
  ConsumerState<ItemRegisterPage> createState() => _ItemRegisterPageState();
}

class _ItemRegisterPageState extends ConsumerState<ItemRegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _janController = TextEditingController();
  final _priceController = TextEditingController(text: '0');
  final _stockController = TextEditingController(text: '0');

  Category? _selectedCategory;
  XFile? _capturedImage;
  bool _saving = false;
  String? _errorMessage;
  McpItemModel? _savedItem;
  String? _draftId;

  BookInfoModel? _bookInfo;
  bool _fetchingIsbn = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefillJanCode != null) {
      _janController.text = widget.prefillJanCode!;
    }
    _janController.addListener(_onJanChanged);

    // Auto-fetch when a JAN/ISBN code is pre-filled (e.g., from scanner).
    if (widget.prefillJanCode != null &&
        IsbnLookupService.isIsbn(widget.prefillJanCode!)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetchIsbnInfo());
    }
  }

  @override
  void dispose() {
    _janController.removeListener(_onJanChanged);
    _nameController.dispose();
    _janController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  void _onJanChanged() => setState(() {});

  bool get _janIsIsbn => IsbnLookupService.isIsbn(_janController.text.trim());

  Future<void> _fetchIsbnInfo() async {
    final isbn = _janController.text.trim();
    if (!IsbnLookupService.isIsbn(isbn)) return;
    setState(() {
      _fetchingIsbn = true;
      _bookInfo = null;
    });
    try {
      final service = ref.read(isbnLookupServiceProvider);
      final info = await service.lookup(isbn);
      if (!mounted) return;
      if (info == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('書籍情報が見つかりませんでした')));
        return;
      }
      setState(() {
        _bookInfo = info;
        // Auto-fill name only when still blank.
        if (_nameController.text.isEmpty) {
          _nameController.text = info.title;
        }
        // Auto-fill price only when still zero.
        if (info.price != null &&
            (int.tryParse(_priceController.text) ?? 0) == 0) {
          _priceController.text = info.price.toString();
        }
      });
      await _storePriceHistory(info);
    } finally {
      if (mounted) setState(() => _fetchingIsbn = false);
    }
  }

  Future<void> _storePriceHistory(BookInfoModel info) async {
    if (info.price == null) return;
    final db = await ref.read(databaseHelperProvider.future);
    final dao = PriceHistoryDao(db.db);
    await dao.insertIfChanged(
      PriceHistoryEntry(
        isbn: info.isbn,
        price: info.price!,
        source: info.source,
        fetchedAt: DateTime.now(),
      ),
    );
  }

  void _showPriceHistory(String isbn) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (_) => DraggableScrollableSheet(
            initialChildSize: 0.55,
            minChildSize: 0.3,
            maxChildSize: 0.9,
            expand: false,
            builder:
                (_, scrollController) => _PriceHistorySheet(
                  isbn: isbn,
                  scrollController: scrollController,
                ),
          ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 85,
    );
    if (file != null) setState(() => _capturedImage = file);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      setState(() => _errorMessage = 'カテゴリを選択してください');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final janCode =
        _janController.text.trim().isEmpty ? null : _janController.text.trim();
    final price = int.tryParse(_priceController.text) ?? 0;
    final stock = int.tryParse(_stockController.text) ?? 0;

    // 1. Save to local outbox first (guarantees data survives network failures).
    final db = await ref.read(databaseHelperProvider.future);
    final dao = PendingRegistrationDao(db.db);
    final localId = await dao.insert(
      PendingRegistration(
        name: name,
        categoryId: int.tryParse(_selectedCategory!.id) ?? 0,
        janCode: janCode,
        price: price,
        stock: stock,
        imagePath: _capturedImage?.path,
        draftId: _draftId,
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    );

    // 2. Offline mode: queue only, no server call.
    final config = ref.read(serverConfigNotifierProvider);
    if (config.offlineMode) {
      if (mounted) {
        setState(() {
          _saving = false;
          _savedItem = _localPreviewItem(name, price, stock);
        });
      }
      return;
    }

    // 3. Attempt server submission.
    try {
      await dao.updateStatus(localId, 'syncing');

      McpItemModel item;
      if (config.apiMode == ApiMode.rest && config.jwtToken != null) {
        final restClient = RestV1ApiClient(
          serverUrl: config.baseUrl,
          jwtToken: config.jwtToken!,
        );
        item = await restClient.registerItemWithAi(
          name: name,
          janCode: janCode,
          categoryId: int.tryParse(_selectedCategory!.id),
          price: price,
          stock: stock,
          image: _capturedImage,
          draftId: _draftId,
        );
      } else {
        final client = await ref.read(mcpClientProvider.future);
        if (client == null) throw Exception('サーバーに接続されていません');
        item = await registerItem(
          client,
          RegisterItemParams(
            name: name,
            categoryId: int.tryParse(_selectedCategory!.id) ?? 0,
            janCode: janCode,
            price: price,
            stock: stock,
            draftId: _draftId,
          ),
        );
      }

      await dao.updateStatus(localId, 'completed', syncedAt: DateTime.now());
      if (mounted) setState(() => _savedItem = item);
    } catch (e) {
      await dao.updateStatus(localId, 'failed', errorMessage: '$e');
      if (mounted) {
        setState(() => _errorMessage = '送信失敗 (ローカル保存済み): $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  McpItemModel _localPreviewItem(String name, int price, int stock) =>
      McpItemModel(
        id: 0,
        name: name,
        categoryId: int.tryParse(_selectedCategory?.id ?? ''),
        price: price,
        stock: stock,
      );

  @override
  Widget build(BuildContext context) {
    if (_savedItem != null) return _SuccessView(item: _savedItem!);

    return Scaffold(
      appBar: AppBar(title: const Text('アイテム登録')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Image capture
            _ImageCaptureTile(
              image: _capturedImage,
              onCamera: () => _pickImage(ImageSource.camera),
              onGallery: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 16),

            // Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'アイテム名 *',
                hintText: '例: メンズジャケット ネイビー',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator:
                  (v) => (v == null || v.trim().isEmpty) ? '名前を入力してください' : null,
            ),
            const SizedBox(height: 12),

            // JAN / ISBN code
            TextFormField(
              controller: _janController,
              decoration: InputDecoration(
                labelText: 'JAN / バーコード / ISBN',
                hintText: '例: 9784101092058',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'スキャンして入力',
                  onPressed:
                      () => context.push('/scanner/jan').then((code) {
                        if (code is String) _janController.text = code;
                      }),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 8),

            // ── ISBN auto-fill banner ──────────────────────────────────────
            if (_janIsIsbn && _bookInfo == null)
              _IsbnFetchBanner(
                fetching: _fetchingIsbn,
                onFetch: _fetchIsbnInfo,
              ),

            // ── Book info card ──────────────────────────────────────────────
            if (_bookInfo != null) ...[
              _BookInfoCard(
                book: _bookInfo!,
                onViewHistory: () => _showPriceHistory(_bookInfo!.isbn),
              ),
              const SizedBox(height: 4),
            ],

            const SizedBox(height: 4),

            // Category picker
            _CategoryPickerTile(
              selected: _selectedCategory,
              onSelected: (cat) => setState(() => _selectedCategory = cat),
            ),
            const SizedBox(height: 12),

            // Price / Stock row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(
                      labelText: '価格 (円)',
                      border: OutlineInputBorder(),
                      prefixText: '¥ ',
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: '初期在庫数',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),

            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon:
                  _saving
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.save_outlined),
              label: Text(_saving ? '登録中…' : '登録する'),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// ISBN fetch banner
// ---------------------------------------------------------------------------

class _IsbnFetchBanner extends StatelessWidget {
  const _IsbnFetchBanner({required this.fetching, required this.onFetch});

  final bool fetching;
  final VoidCallback onFetch;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.menu_book_outlined),
        title: const Text('ISBNを検出しました'),
        subtitle: const Text('書籍情報を自動取得できます'),
        trailing:
            fetching
                ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : FilledButton.tonal(
                  onPressed: onFetch,
                  child: const Text('取得'),
                ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Book info card
// ---------------------------------------------------------------------------

class _BookInfoCard extends StatelessWidget {
  const _BookInfoCard({required this.book, required this.onViewHistory});

  final BookInfoModel book;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image
            if (book.coverUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: CachedNetworkImage(
                  imageUrl: book.coverUrl!,
                  width: 60,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder:
                      (_, __) => Container(
                        width: 60,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.book_outlined, size: 28),
                      ),
                  errorWidget: (_, __, ___) => const Icon(Icons.book_outlined),
                ),
              )
            else
              Container(
                width: 60,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Icon(Icons.book_outlined, size: 28),
              ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (book.author != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      book.author!,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (book.publisher != null)
                    Text(
                      book.publisher!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (book.price != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '定価: ¥${book.price}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: onViewHistory,
                    icon: const Icon(Icons.show_chart, size: 16),
                    label: const Text('価格履歴'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Price history bottom sheet
// ---------------------------------------------------------------------------

class _PriceHistorySheet extends ConsumerWidget {
  const _PriceHistorySheet({
    required this.isbn,
    required this.scrollController,
  });

  final String isbn;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(priceHistoryProvider(isbn));

    return Column(
      children: [
        // Drag handle
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '価格履歴  ISBN: $isbn',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: historyAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('取得失敗: $e')),
            data:
                (entries) => ListView(
                  controller: scrollController,
                  children: [PriceHistoryChart(entries: entries)],
                ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Image capture tile
// ---------------------------------------------------------------------------

class _ImageCaptureTile extends StatelessWidget {
  const _ImageCaptureTile({
    required this.image,
    required this.onCamera,
    required this.onGallery,
  });

  final XFile? image;
  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('商品画像', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(image!.path),
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.image_outlined, size: 48),
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: onCamera,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('撮影'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: onGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('ライブラリ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category picker (REST categoriesProvider)
// ---------------------------------------------------------------------------

class _CategoryPickerTile extends ConsumerWidget {
  const _CategoryPickerTile({required this.selected, required this.onSelected});

  final Category? selected;
  final ValueChanged<Category> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return categoriesAsync.when(
      loading: () => const LinearProgressIndicator(),
      error:
          (e, _) => Text(
            'カテゴリ取得失敗: $e',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
      data:
          (categories) => DropdownButtonFormField<Category>(
            decoration: const InputDecoration(
              labelText: 'カテゴリ *',
              border: OutlineInputBorder(),
            ),
            // ignore: deprecated_member_use
            value: selected,
            hint: const Text('カテゴリを選択'),
            items:
                categories
                    .map(
                      (cat) => DropdownMenuItem(
                        value: cat,
                        child: Text('${'　' * cat.depth}${cat.name}'),
                      ),
                    )
                    .toList(),
            onChanged: (v) {
              if (v != null) onSelected(v);
            },
          ),
    );
  }
}

// ---------------------------------------------------------------------------
// Success screen after registration
// ---------------------------------------------------------------------------

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.item});
  final McpItemModel item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('登録完了')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 72,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
              Text(
                item.name,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                item.id == 0
                    ? '保留中 (ローカル保存済み)  在庫: ${item.stock}'
                    : 'ID: ${item.id}  在庫: ${item.stock}',
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => context.replace('/items/register'),
                    icon: const Icon(Icons.add),
                    label: const Text('続けて登録'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home_outlined),
                    label: const Text('ホームへ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
