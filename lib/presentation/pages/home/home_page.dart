import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/providers/server_config_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(serverConfigNotifierProvider);
    final isMock = config.apiMode == ApiMode.mock;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SASO Willen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push('/settings'),
            tooltip: '設定',
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          if (isMock)
            SliverToBoxAdapter(
              child: Container(
                color: Colors.amber.shade100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: const Row(
                  children: [
                    Icon(Icons.science_outlined, size: 16, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('モックモード（サーバー不要）'),
                  ],
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _MenuCard(
                  key: const Key('menu_search'),
                  icon: Icons.search,
                  label: 'アイテム検索',
                  color: Colors.blue,
                  onTap: () => context.push('/items/search'),
                ),
                _MenuCard(
                  key: const Key('menu_scanner'),
                  icon: Icons.qr_code_scanner,
                  label: 'バーコードスキャン',
                  color: Colors.green,
                  onTap: () => context.push('/scanner'),
                ),
                _MenuCard(
                  icon: Icons.category_outlined,
                  label: 'カテゴリ',
                  color: Colors.orange,
                  onTap: () => context.push('/categories'),
                ),
                _MenuCard(
                  icon: Icons.shelves,
                  label: '棚を見る',
                  color: Colors.purple,
                  onTap: () => _showShelfDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('search_fab'),
        onPressed: () => context.push('/items/search'),
        icon: const Icon(Icons.search),
        label: const Text('検索'),
      ),
    );
  }

  void _showShelfDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('棚IDを入力'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '例: A-01',
                labelText: '棚ID',
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (v) {
                ctx.pop();
                if (v.isNotEmpty) context.push('/shelves/$v');
              },
            ),
            actions: [
              TextButton(onPressed: ctx.pop, child: const Text('キャンセル')),
              FilledButton(
                onPressed: () {
                  ctx.pop();
                  if (controller.text.isNotEmpty) {
                    context.push('/shelves/${controller.text.toUpperCase()}');
                  }
                },
                child: const Text('移動'),
              ),
            ],
          ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.hardEdge,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
      ),
    ),
  );
}
