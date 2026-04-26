import 'package:flutter/material.dart';
import '../../../domain/entities/item.dart';

class ItemListTile extends StatelessWidget {
  const ItemListTile({super.key, required this.item, this.onTap});

  final Item item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        key: Key('item_tile_${item.id}'),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            item.name.substring(0, 1),
            style: TextStyle(color: theme.colorScheme.onPrimaryContainer),
          ),
        ),
        title: Text(item.name),
        subtitle: Text(
          item.id.value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.outline,
            fontFamily: 'monospace',
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${item.features.length} バリエーション',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              '在庫 ${item.totalStock}',
              style: theme.textTheme.bodySmall?.copyWith(
                color:
                    item.totalStock > 0
                        ? Colors.green
                        : theme.colorScheme.error,
              ),
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
