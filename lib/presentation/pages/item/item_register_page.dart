import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/models/mcp_item_model.dart';
import '../../../data/models/storage_location_model.dart';
import '../../providers/mcp_provider.dart';

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

  StorageLocationModel? _selectedCategory;
  XFile? _capturedImage;
  bool _saving = false;
  String? _errorMessage;
  McpItemModel? _savedItem;

  @override
  void initState() {
    super.initState();
    if (widget.prefillJanCode != null) {
      _janController.text = widget.prefillJanCode!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _janController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
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

    final client = ref.read(mcpClientProvider);
    if (client == null) {
      setState(() => _errorMessage = 'サーバーに接続されていません (REST モード + JWT 必要)');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final item = await registerItem(
        client,
        RegisterItemParams(
          name: _nameController.text.trim(),
          categoryId: _selectedCategory!.id,
          janCode: _janController.text.trim().isEmpty
              ? null
              : _janController.text.trim(),
          price: int.tryParse(_priceController.text) ?? 0,
          stock: int.tryParse(_stockController.text) ?? 0,
        ),
      );
      if (mounted) setState(() => _savedItem = item);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = '登録失敗: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

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
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? '名前を入力してください' : null,
            ),
            const SizedBox(height: 12),

            // JAN code
            TextFormField(
              controller: _janController,
              decoration: InputDecoration(
                labelText: 'JAN / バーコード',
                hintText: '例: 4901234567890',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'スキャンして入力',
                  onPressed: () => context
                      .push('/scanner/jan')
                      .then((code) {
                        if (code is String) _janController.text = code;
                      }),
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 12),

            // Category picker
            _CategoryPickerTile(
              selected: _selectedCategory,
              onSelected: (loc) => setState(() => _selectedCategory = loc),
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),

            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
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
            const SizedBox(height: 4),
            Text(
              '※ 画像アップロードはサーバー対応後に有効になります',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Category picker (flat list from MCP locations)
// ---------------------------------------------------------------------------

class _CategoryPickerTile extends ConsumerWidget {
  const _CategoryPickerTile({
    required this.selected,
    required this.onSelected,
  });

  final StorageLocationModel? selected;
  final ValueChanged<StorageLocationModel> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(storageLocationsProvider(null));

    return locationsAsync.when(
      loading: () => const LinearProgressIndicator(),
      error: (e, _) => Text('カテゴリ取得失敗: $e',
          style: TextStyle(color: Theme.of(context).colorScheme.error)),
      data: (locations) => DropdownButtonFormField<StorageLocationModel>(
        decoration: const InputDecoration(
          labelText: 'カテゴリ *',
          border: OutlineInputBorder(),
        ),
        value: selected,
        hint: const Text('カテゴリを選択'),
        items: locations
            .map(
              (loc) => DropdownMenuItem(
                value: loc,
                child: Text('${'　' * loc.depth}${loc.name} (${loc.code})'),
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
              const Icon(Icons.check_circle_outline,
                  size: 72, color: Colors.green),
              const SizedBox(height: 16),
              Text(
                item.name,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text('ID: ${item.id}  在庫: ${item.stock}'),
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
