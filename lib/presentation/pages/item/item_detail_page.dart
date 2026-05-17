import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/item.dart';
import '../../providers/item_provider.dart';
import '../../widgets/common/error_display_widget.dart';
import '../../widgets/common/loading_widget.dart';

class ItemDetailPage extends ConsumerWidget {
  const ItemDetailPage({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemByIdProvider(itemId));

    return Scaffold(
      appBar: AppBar(title: Text(itemId)),
      body: itemAsync.when(
        loading: () => const LoadingWidget(),
        error:
            (e, _) => ErrorDisplayWidget(
              error: e,
              onRetry: () => ref.invalidate(itemByIdProvider(itemId)),
            ),
        data: (item) => _ItemDetail(item: item),
      ),
    );
  }
}

class _ItemDetail extends StatelessWidget {
  const _ItemDetail({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: theme.textTheme.headlineSmall,
                  key: const Key('item_name'),
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

        // Category
        Card(
          child: ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('カテゴリ'),
            subtitle: Text(item.category.name),
          ),
        ),
        const SizedBox(height: 8),

        // Label code (custom shelf label)
        if (item.labelCode != null) ...[
          Card(
            child: ListTile(
              leading: const Icon(Icons.label_outline),
              title: const Text('ラベルコード'),
              subtitle: Text(
                item.labelCode!,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // JAN code
        if (item.janCode != null) ...[
          Card(
            child: ListTile(
              leading: const Icon(Icons.barcode_reader),
              title: const Text('JANコード'),
              subtitle: Text(
                item.janCode!,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // ISBN
        if (item.isbnCode != null) ...[
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('ISBN'),
              subtitle: Text(
                item.isbnCode!,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Registration date
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

        // Features
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
