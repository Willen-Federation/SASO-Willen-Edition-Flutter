import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/item.dart';
import '../../../domain/entities/item_status.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/item_provider.dart';
import '../../widgets/common/error_display_widget.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/item/item_status_badge.dart';

class ItemDetailPage extends ConsumerWidget {
  const ItemDetailPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemByIdProvider(itemId));
    final l10n = AppLocalizations.of(context)!;

    ref.listen<AsyncValue<void>>(itemStatusUpdaterProvider, (prev, next) {
      next.whenOrNull(
        data: (_) {
          if (prev is AsyncLoading) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(l10n.itemStatusUpdated)));
          }
        },
        error: (e, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.itemStatusUpdateFailed(e.toString())),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(itemId),
        actions: [
          IconButton(
            key: const Key('item_edit_button'),
            icon: const Icon(Icons.edit_outlined),
            tooltip: '編集',
            onPressed: () => context.push('/items/$itemId/edit'),
          ),
        ],
      ),
      body: itemAsync.when(
        loading: () => const LoadingWidget(),
        error: (e, _) => ErrorDisplayWidget(
          error: e,
          onRetry: () => ref.invalidate(itemByIdProvider(itemId)),
        ),
        data: (item) => _ItemDetail(item: item),
      ),
    );
  }
}

class _ItemDetail extends ConsumerWidget {
  const _ItemDetail({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: theme.textTheme.headlineSmall,
                        key: const Key('item_name'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Wrapped in ConstrainedBox to guarantee an HIG-compliant
                    // 44x44 minimum touch target (issue #134). The badge
                    // itself stays visually compact; the InkWell expands to
                    // fill the constrained area so taps near the edges are
                    // still registered.
                    MergeSemantics(
                      child: Semantics(
                        button: true,
                        label: 'ステータスを変更',
                        child: InkWell(
                          key: const Key('item_status_badge_button'),
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => _pickStatus(context, ref),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              minWidth: 44,
                              minHeight: 44,
                            ),
                            child: Center(
                              widthFactor: 1,
                              heightFactor: 1,
                              child: ItemStatusBadge(status: item.status),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.id.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    color: theme.colorScheme.outline,
                  ),
                  key: const Key('item_id'),
                ),
                if (item.description != null) ...[
                  const SizedBox(height: 8),
                  Text(item.description!),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        Card(
          child: ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('カテゴリ'),
            subtitle: Text(item.category.name),
          ),
        ),
        const SizedBox(height: 8),

        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today_outlined),
            title: const Text('登録日'),
            subtitle: Text(
              '${item.registeredAt.year}/${item.registeredAt.month.toString().padLeft(2, '0')}/${item.registeredAt.day.toString().padLeft(2, '0')}',
            ),
          ),
        ),
        const SizedBox(height: 8),

        if (item.note != null && item.note!.isNotEmpty) ...[
          Card(
            key: const Key('item_note_card'),
            child: ListTile(
              leading: const Icon(Icons.sticky_note_2_outlined),
              title: const Text('備考'),
              subtitle: Text(item.note!),
              isThreeLine: item.note!.length > 40,
            ),
          ),
          const SizedBox(height: 8),
        ],

        if (item.features.isNotEmpty) ...[
          Text('バリエーション', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          ...item.features.map(
            (f) => Card(
              key: Key('feature_${f.code}'),
              child: ListTile(
                leading: const Icon(Icons.style_outlined),
                title: Text(f.displayLabel),
                subtitle: Text('コード: ${f.code.value}'),
                trailing: _StockBadge(count: f.stockCount),
              ),
            ),
          ),
        ],

        const SizedBox(height: 80),
      ],
    );
  }

  Future<void> _pickStatus(BuildContext context, WidgetRef ref) async {
    final picked = await showModalBottomSheet<ItemStatus>(
      context: context,
      showDragHandle: true,
      builder: (sheetCtx) {
        final l10n = AppLocalizations.of(sheetCtx)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                  l10n.itemStatusChange,
                  style: Theme.of(sheetCtx).textTheme.titleMedium,
                ),
              ),
              const Divider(height: 1),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    for (final s in ItemStatus.values)
                      ListTile(
                        key: Key('status_option_${s.jsonValue}'),
                        leading: Icon(
                          s == item.status
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: s == item.status
                              ? Theme.of(sheetCtx).colorScheme.primary
                              : Theme.of(sheetCtx).colorScheme.outline,
                        ),
                        title: Row(
                          children: [
                            ItemStatusBadge(status: s, compact: true),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ItemStatusBadge.labelFor(s, sheetCtx),
                              ),
                            ),
                          ],
                        ),
                        onTap: () => Navigator.of(sheetCtx).pop(s),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );

    if (picked == null || picked == item.status) return;
    await ref
        .read(itemStatusUpdaterProvider.notifier)
        .changeStatus(item.id.value, picked);
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final color = count > 0 ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        '在庫 $count',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
