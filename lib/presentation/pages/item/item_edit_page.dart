import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/item.dart';
import '../../providers/item_provider.dart';
import '../../widgets/common/error_display_widget.dart';
import '../../widgets/common/loading_widget.dart';

/// Edit page for an existing item. Fetches the current values via
/// [itemByIdProvider] and PATCHes diffs through [itemFieldUpdaterProvider]
/// (which maps to `PATCH /api/v1/items/{id}` on the REST backend).
class ItemEditPage extends ConsumerWidget {
  const ItemEditPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemByIdProvider(itemId));
    return Scaffold(
      appBar: AppBar(title: const Text('アイテムを編集')),
      body: itemAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorDisplayWidget(
          error: e,
          onRetry: () => ref.invalidate(itemByIdProvider(itemId)),
        ),
        data: (item) => _ItemEditForm(item: item),
      ),
    );
  }
}

class _ItemEditForm extends ConsumerStatefulWidget {
  const _ItemEditForm({required this.item});

  final Item item;

  @override
  ConsumerState<_ItemEditForm> createState() => _ItemEditFormState();
}

class _ItemEditFormState extends ConsumerState<_ItemEditForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;
  late final TextEditingController _janController;
  late final TextEditingController _isbnController;
  late final TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _noteController = TextEditingController(text: widget.item.note ?? '');
    _janController = TextEditingController(text: widget.item.janCode ?? '');
    _isbnController = TextEditingController(text: widget.item.isbnCode ?? '');
    _labelController = TextEditingController(text: widget.item.labelCode ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    _janController.dispose();
    _isbnController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newName = _nameController.text.trim();
    final newNote = _noteController.text.trim();
    final newJan = _janController.text.trim();
    final newIsbn = _isbnController.text.trim();
    final newLabel = _labelController.text.trim();

    final patch = <String, String?>{};
    if (newName != widget.item.name) {
      patch['name'] = newName;
    }
    if (newNote != (widget.item.note ?? '')) {
      patch['note'] = newNote;
    }
    if (newJan != (widget.item.janCode ?? '')) {
      patch['janCode'] = newJan;
    }
    if (newIsbn != (widget.item.isbnCode ?? '')) {
      patch['isbnCode'] = newIsbn;
    }
    if (newLabel != (widget.item.labelCode ?? '')) {
      patch['labelCode'] = newLabel;
    }

    if (patch.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('変更がありません')));
      return;
    }

    await ref
        .read(itemFieldUpdaterProvider.notifier)
        .updateFields(
          widget.item.id.value,
          name: patch['name'],
          note: patch['note'],
          janCode: patch['janCode'],
          isbnCode: patch['isbnCode'],
          labelCode: patch['labelCode'],
        );

    if (!mounted) return;
    final updater = ref.read(itemFieldUpdaterProvider);
    if (updater.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('更新失敗: ${updater.error}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('保存しました')));
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final updaterState = ref.watch(itemFieldUpdaterProvider);
    final saving = updaterState.isLoading;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextFormField(
            key: const Key('edit_name'),
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'アイテム名 *',
              border: OutlineInputBorder(),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? '名前を入力してください' : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            key: const Key('edit_note'),
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: '備考',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            key: const Key('edit_jan'),
            controller: _janController,
            decoration: const InputDecoration(
              labelText: 'JAN / バーコード',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            key: const Key('edit_isbn'),
            controller: _isbnController,
            decoration: const InputDecoration(
              labelText: 'ISBN',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            key: const Key('edit_label'),
            controller: _labelController,
            decoration: const InputDecoration(
              labelText: 'ラベルコード',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            key: const Key('edit_save_button'),
            onPressed: saving ? null : _save,
            icon: saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(saving ? '保存中…' : '保存'),
          ),
        ],
      ),
    );
  }
}
