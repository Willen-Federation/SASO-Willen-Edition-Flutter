import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/providers/outbox_provider.dart';
import '../../../presentation/providers/server_config_provider.dart';
import '../../layout/responsive.dart';
import '../../widgets/common/offline_indicator.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(serverConfigNotifierProvider);
    final isMock = config.apiMode == ApiMode.mock;

    final pendingCountAsync = ref.watch(pendingCountProvider);
    final pendingCount = pendingCountAsync.when(
      data: (n) => n,
      loading: () => 0,
      error: (_, __) => 0,
    );

    final responsive = Responsive.of(context);
    final crossAxisCount = responsive.adaptiveColumns(tablet: 3, desktop: 4);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/branding/saso-compact-rounded-256.png',
              height: 28,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text('SASO Willen'),
          ],
        ),
        actions: [
          const OfflineIndicator(),
          if (pendingCount > 0)
            Badge.count(
              count: pendingCount,
              child: IconButton(
                icon: const Icon(Icons.sync_problem_outlined),
                tooltip: '保留中データ',
                onPressed: () => context.push('/outbox'),
              ),
            ),
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
              crossAxisCount: crossAxisCount,
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
                  icon: Icons.add_box_outlined,
                  label: 'アイテム登録',
                  color: Colors.teal,
                  onTap: () => context.push('/items/register'),
                ),
                _MenuCard(
                  icon: Icons.warehouse_outlined,
                  label: '場所管理',
                  color: Colors.indigo,
                  onTap: () => context.push('/locations'),
                ),
                _MenuCard(
                  icon: Icons.category_outlined,
                  label: 'カテゴリ',
                  color: Colors.orange,
                  onTap: () => context.push('/categories'),
                ),
                _MenuCard(
                  key: const Key('menu_inventory_scan'),
                  icon: Icons.inventory_2_outlined,
                  label: '入出庫スキャン',
                  color: Colors.deepOrange,
                  onTap: () => context.push('/scanner?mode=inventory'),
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
