import 'package:flutter/material.dart';
import '../../../domain/entities/item.dart';
import 'item_status_badge.dart';

class ItemListTile extends StatelessWidget {
  const ItemListTile({super.key, required this.item, this.onTap});

  final Item item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Compose a single, screen-reader-friendly label so TalkBack/VoiceOver
    // announces "<name>, <variation count> バリエーション, 在庫 <n>,
    // <status>" in one continuous utterance instead of fragment by
    // fragment. The trailing column is then excluded from semantics so
    // there's no duplicate readout.
    final statusLabel = ItemStatusBadge.labelFor(item.status, context);
    final semanticLabel =
        '${item.name}, ${item.features.length} バリエーション, '
        '在庫 ${item.totalStock}, $statusLabel';

    return MergeSemantics(
      child: Semantics(
        button: onTap != null,
        label: semanticLabel,
        child: ExcludeSemantics(
          child: Card(
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
                  ItemStatusBadge(status: item.status, compact: true),
                  const SizedBox(height: 2),
                  Text(
                    '${item.features.length} バリエーション',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '在庫 ${item.totalStock}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: item.totalStock > 0
                          ? Colors.green
                          : theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
              onTap: onTap,
            ),
          ),
        ),
      ),
    );
  }
}
