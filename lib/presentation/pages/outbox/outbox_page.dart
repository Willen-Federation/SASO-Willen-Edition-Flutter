import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/database_helper.dart';
<<<<<<< HEAD
import '../../../core/theme/app_icon_size.dart';
import '../../../core/theme/app_spacing.dart';
=======
import '../../../core/theme/app_colors.dart';
>>>>>>> b0ef396 (feat(theme): migrate hardcoded colors to ColorTokens / ColorScheme (Android compliance))
import '../../../data/datasources/local/pending_adjustment_dao.dart';
import '../../../data/datasources/local/pending_registration_dao.dart';
import '../../../data/models/pending_adjustment.dart';
import '../../../data/models/pending_registration.dart';
import '../../../data/models/stock_adjustment_model.dart';
import '../../providers/mcp_provider.dart';
import '../../providers/server_config_provider.dart';

/// Shows pending / failed outbox items and allows manual sync.
class OutboxPage extends ConsumerStatefulWidget {
  const OutboxPage({super.key});

  @override
  ConsumerState<OutboxPage> createState() => _OutboxPageState();
}

class _OutboxPageState extends ConsumerState<OutboxPage> {
  List<PendingRegistration> _regs = [];
  List<PendingAdjustment> _adjs = [];
  bool _loading = true;
  bool _syncing = false;
  String? _syncError;
  int _syncDone = 0;
  int _syncTotal = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final db = await ref.read(databaseHelperProvider.future);
    final regDao = PendingRegistrationDao(db.db);
    final adjDao = PendingAdjustmentDao(db.db);
    final regs = await regDao.getPending();
    final adjs = await adjDao.getPending();
    if (mounted) {
      setState(() {
        _regs = regs;
        _adjs = adjs;
        _loading = false;
      });
    }
  }

  Future<void> _syncAll() async {
    final config = ref.read(serverConfigNotifierProvider);
    if (config.apiMode != ApiMode.rest || config.jwtToken == null) {
      setState(() => _syncError = 'RESTモードとJWTトークンが必要です');
      return;
    }

    final db = await ref.read(databaseHelperProvider.future);
    final regDao = PendingRegistrationDao(db.db);
    final adjDao = PendingAdjustmentDao(db.db);
    final mcpClient = ref.read(mcpClientProvider);

    final all = [..._regs, ..._adjs];
    if (all.isEmpty) return;

    setState(() {
      _syncing = true;
      _syncError = null;
      _syncDone = 0;
      _syncTotal = all.length;
    });

    for (final item in _regs) {
      if (item.id == null) continue;
      await Future<void>.delayed(const Duration(milliseconds: 300));
      try {
        if (mcpClient == null) throw Exception('MCP未接続');
        await regDao.updateStatus(item.id!, 'syncing');
        // Re-send via MCP register_item with stored data
        await registerItem(
          mcpClient,
          RegisterItemParams(
            name: item.name,
            categoryId: item.categoryId,
            janCode: item.janCode,
            price: item.price,
            stock: item.stock,
            draftId: item.draftId,
          ),
        );
        await regDao.updateStatus(
          item.id!,
          'completed',
          syncedAt: DateTime.now(),
        );
      } catch (e) {
        await regDao.updateStatus(item.id!, 'failed', errorMessage: '$e');
      }
      if (mounted) setState(() => _syncDone++);
    }

    for (final item in _adjs) {
      if (item.id == null) continue;
      await Future<void>.delayed(const Duration(milliseconds: 300));
      try {
        if (mcpClient == null) throw Exception('MCP未接続');
        await adjDao.updateStatus(item.id!, 'syncing');
        await adjustStock(
          mcpClient,
          StockAdjustmentParams(
            itemId: item.itemId,
            delta: item.delta,
            reason: _reasonFromString(item.reason),
            shelfId: item.shelfId,
            locationId: item.locationId,
          ),
        );
        await adjDao.updateStatus(
          item.id!,
          'completed',
          syncedAt: DateTime.now(),
        );
      } catch (e) {
        await adjDao.updateStatus(item.id!, 'failed', errorMessage: '$e');
      }
      if (mounted) setState(() => _syncDone++);
    }

    if (mounted) {
      setState(() => _syncing = false);
      await _load();
    }
  }

  AdjustmentReason _reasonFromString(String value) => switch (value) {
    'check_out' => AdjustmentReason.checkOut,
    'audit' => AdjustmentReason.audit,
    _ => AdjustmentReason.checkIn,
  };

  @override
  Widget build(BuildContext context) {
    final total = _regs.length + _adjs.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('保留中データ'),
        actions: [
          if (total > 0)
            IconButton(
              icon: const Icon(Icons.sync),
              tooltip: '一括送信',
              onPressed: _syncing ? null : _syncAll,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : total == 0
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_outline,
<<<<<<< HEAD
                    size: AppIconSize.display,
                    color: Colors.green,
                  ),
                  SizedBox(height: AppSpacing.md),
                  Text('保留中のデータはありません'),
=======
                    size: 64,
                    color: context.semanticColors.success,
                  ),
                  const SizedBox(height: 16),
                  const Text('保留中のデータはありません'),
>>>>>>> b0ef396 (feat(theme): migrate hardcoded colors to ColorTokens / ColorScheme (Android compliance))
                ],
              ),
            )
          : Column(
              children: [
                if (_syncing)
                  LinearProgressIndicator(
                    value: _syncTotal > 0 ? _syncDone / _syncTotal : null,
                  ),
                if (_syncError != null)
                  Container(
                    color: Theme.of(context).colorScheme.errorContainer,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Text(
                      _syncError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView(
                    children: [
                      if (_regs.isNotEmpty) ...[
                        const _SectionHeader(
                          icon: Icons.add_box_outlined,
                          title: '登録保留',
                        ),
                        ..._regs.map(
                          (r) => _RegistrationTile(
                            reg: r,
                            onRetry: () => _retryRegistration(r),
                          ),
                        ),
                      ],
                      if (_adjs.isNotEmpty) ...[
                        const _SectionHeader(
                          icon: Icons.inventory_2_outlined,
                          title: '入出庫保留',
                        ),
                        ..._adjs.map(
                          (a) => _AdjustmentTile(
                            adj: a,
                            onRetry: () => _retryAdjustment(a),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: total > 0
          ? FloatingActionButton.extended(
              onPressed: _syncing ? null : _syncAll,
              icon: _syncing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              label: Text(_syncing ? '送信中 $_syncDone/$_syncTotal' : '全件送信'),
            )
          : null,
    );
  }

  Future<void> _retryRegistration(PendingRegistration reg) async {
    if (reg.id == null) return;
    final mcpClient = ref.read(mcpClientProvider);
    if (mcpClient == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('MCP未接続')));
      return;
    }
    final db = await ref.read(databaseHelperProvider.future);
    final dao = PendingRegistrationDao(db.db);
    try {
      await dao.updateStatus(reg.id!, 'syncing');
      await registerItem(
        mcpClient,
        RegisterItemParams(
          name: reg.name,
          categoryId: reg.categoryId,
          janCode: reg.janCode,
          price: reg.price,
          stock: reg.stock,
          draftId: reg.draftId,
        ),
      );
      await dao.updateStatus(reg.id!, 'completed', syncedAt: DateTime.now());
    } catch (e) {
      await dao.updateStatus(reg.id!, 'failed', errorMessage: '$e');
    }
    await _load();
  }

  Future<void> _retryAdjustment(PendingAdjustment adj) async {
    if (adj.id == null) return;
    final mcpClient = ref.read(mcpClientProvider);
    if (mcpClient == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('MCP未接続')));
      return;
    }
    final db = await ref.read(databaseHelperProvider.future);
    final dao = PendingAdjustmentDao(db.db);
    try {
      await dao.updateStatus(adj.id!, 'syncing');
      await adjustStock(
        mcpClient,
        StockAdjustmentParams(
          itemId: adj.itemId,
          delta: adj.delta,
          reason: _reasonFromString(adj.reason),
          shelfId: adj.shelfId,
          locationId: adj.locationId,
        ),
      );
      await dao.updateStatus(adj.id!, 'completed', syncedAt: DateTime.now());
    } catch (e) {
      await dao.updateStatus(adj.id!, 'failed', errorMessage: '$e');
    }
    await _load();
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});
  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.md,
      AppSpacing.sm,
      AppSpacing.md,
      AppSpacing.xs,
    ),
    child: Row(
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: AppSpacing.sm),
        Text(title, style: Theme.of(context).textTheme.titleSmall),
      ],
    ),
  );
}

class _RegistrationTile extends StatelessWidget {
  const _RegistrationTile({required this.reg, required this.onRetry});
  final PendingRegistration reg;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: _StatusIcon(status: reg.status),
    title: Text(reg.name),
    subtitle: Text(
      '¥${reg.price}  在庫: ${reg.stock}  ${reg.createdAt.toLocal().toString().substring(0, 16)}',
    ),
    trailing: (reg.status == 'pending' || reg.status == 'failed')
        ? TextButton(onPressed: onRetry, child: const Text('再送'))
        : null,
  );
}

class _AdjustmentTile extends StatelessWidget {
  const _AdjustmentTile({required this.adj, required this.onRetry});
  final PendingAdjustment adj;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final sign = adj.delta >= 0 ? '+${adj.delta}' : '${adj.delta}';
    return ListTile(
      leading: _StatusIcon(status: adj.status),
      title: Text(adj.itemName),
      subtitle: Text(
        '$sign  ${adj.reason}  ${adj.shelfId ?? ''}  ${adj.createdAt.toLocal().toString().substring(0, 16)}',
      ),
      trailing: (adj.status == 'pending' || adj.status == 'failed')
          ? TextButton(onPressed: onRetry, child: const Text('再送'))
          : null,
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final tokens = context.semanticColors;
    final scheme = Theme.of(context).colorScheme;
    return switch (status) {
      'completed' => Icon(Icons.check_circle, color: tokens.success),
      'failed' => Icon(Icons.error_outline, color: scheme.error),
      'syncing' => const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      _ => Icon(Icons.schedule, color: tokens.warning),
    };
  }
}
