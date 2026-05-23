import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/database_helper.dart';
import '../../../data/datasources/local/pending_adjustment_dao.dart';
import '../../../data/models/mcp_item_model.dart';
import '../../../data/models/pending_adjustment.dart';
import '../../../data/models/stock_adjustment_model.dart';
import '../../../domain/value_objects/feature_code.dart';
import '../../../domain/value_objects/item_id.dart';
import '../../providers/mcp_provider.dart';
import '../../providers/server_config_provider.dart';
import '../../widgets/common/adaptive_dialog.dart';

enum _Phase { shelf, item, adjust }

class InventoryAdjustPage extends ConsumerStatefulWidget {
  const InventoryAdjustPage({
    super.key,
    this.prefillJanCode,
    this.prefillItemId,
  });

  final String? prefillJanCode;
  final int? prefillItemId;

  @override
  ConsumerState<InventoryAdjustPage> createState() =>
      _InventoryAdjustPageState();
}

class _InventoryAdjustPageState extends ConsumerState<InventoryAdjustPage> {
  _Phase _phase = _Phase.shelf;
  String? _scannedShelfId;
  String? _scannedItemCode;
  McpItemModel? _item;
  bool _loadingItem = false;

  int _delta = 1;
  AdjustmentReason _reason = AdjustmentReason.checkIn;
  bool _submitting = false;
  String? _errorMessage;
  StockAdjustmentResult? _result;

  @override
  void initState() {
    super.initState();
    if (widget.prefillJanCode != null) {
      _scannedShelfId = '';
      _scannedItemCode = widget.prefillJanCode;
      _phase = _Phase.adjust;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _resolveItem(widget.prefillJanCode!),
      );
    } else if (widget.prefillItemId != null) {
      _scannedShelfId = '';
      _phase = _Phase.adjust;
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => _resolveItemById(widget.prefillItemId!),
      );
    }
  }

  Future<void> _resolveItem(String code) async {
    setState(() {
      _loadingItem = true;
      _errorMessage = null;
    });
    try {
      final client = ref.read(mcpClientProvider);
      if (client == null) return;

      McpItemModel? found;

      // 12-digit feature code
      final fc = FeatureCode.tryParse(code);
      if (fc != null) {
        final result = await client.callTool('get_item', {
          'id': int.tryParse(fc.itemIdPart) ?? 0,
        });
        if (result['found'] == true && result['item'] != null) {
          found = McpItemModel.fromJson(result['item'] as Map<String, dynamic>);
        }
      }

      // 8-digit item ID
      if (found == null) {
        final itemId = ItemId.tryParse(code);
        if (itemId != null) {
          final numId = int.tryParse(itemId.value);
          if (numId != null) {
            final result = await client.callTool('get_item', {'id': numId});
            if (result['found'] == true && result['item'] != null) {
              found = McpItemModel.fromJson(
                result['item'] as Map<String, dynamic>,
              );
            }
          }
        }
      }

      // JAN code search
      if (found == null) {
        final result = await client.callTool('search_items', {
          'query': code,
          'limit': 1,
        });
        final items = result['items'] as List<dynamic>? ?? [];
        if (items.isNotEmpty) {
          found = McpItemModel.fromJson(items.first as Map<String, dynamic>);
        }
      }

      if (mounted) setState(() => _item = found);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'アイテム取得失敗: $e');
    } finally {
      if (mounted) setState(() => _loadingItem = false);
    }
  }

  Future<void> _resolveItemById(int id) async {
    setState(() {
      _loadingItem = true;
      _errorMessage = null;
    });
    try {
      final client = ref.read(mcpClientProvider);
      if (client == null) return;
      final result = await client.callTool('get_item', {'id': id});
      if (!mounted) return;
      if (result['found'] == true && result['item'] != null) {
        setState(
          () => _item = McpItemModel.fromJson(
            result['item'] as Map<String, dynamic>,
          ),
        );
      } else {
        setState(() => _errorMessage = 'アイテムが見つかりません');
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'アイテム取得失敗: $e');
    } finally {
      if (mounted) setState(() => _loadingItem = false);
    }
  }

  Future<void> _submit() async {
    if (_item == null) return;
    final client = ref.read(mcpClientProvider);
    if (client == null) return;

    final signedDelta = _reason == AdjustmentReason.checkOut ? -_delta : _delta;
    final isOffline = ref.read(serverConfigNotifierProvider).offlineMode;

    final db = await ref.read(databaseHelperProvider.future);
    final dao = PendingAdjustmentDao(db.db);
    final localId = await dao.insert(
      PendingAdjustment(
        itemId: _item!.id,
        itemName: _item!.name,
        delta: signedDelta,
        reason: _reason.mcpValue,
        shelfId: _scannedShelfId?.isEmpty == true ? null : _scannedShelfId,
        status: 'pending',
        createdAt: DateTime.now(),
      ),
    );

    if (isOffline) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('オフラインモード: キューに保存しました')));
      setState(
        () => _result = StockAdjustmentResult(
          itemId: _item!.id,
          previousStock: _item!.stock,
          newStock: _item!.stock + signedDelta,
          delta: signedDelta,
        ),
      );
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    try {
      await dao.updateStatus(localId, 'syncing');
      final result = await adjustStock(
        client,
        StockAdjustmentParams(
          itemId: _item!.id,
          delta: signedDelta,
          reason: _reason,
          shelfId: _scannedShelfId?.isEmpty == true ? null : _scannedShelfId,
        ),
      );
      await dao.updateStatus(localId, 'completed', syncedAt: DateTime.now());
      if (mounted) setState(() => _result = result);
    } catch (e) {
      await dao.updateStatus(localId, 'failed', errorMessage: '$e');
      if (mounted) setState(() => _errorMessage = 'エラー: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _scanShelf() async {
    final code = await context.push<String?>('/scanner/jan');
    if (code != null && mounted) {
      setState(() {
        _scannedShelfId = code;
        _phase = _Phase.item;
      });
    }
  }

  Future<void> _scanItem() async {
    final code = await context.push<String?>('/scanner/jan');
    if (code != null && mounted) {
      setState(() {
        _scannedItemCode = code;
        _phase = _Phase.adjust;
      });
      await _resolveItem(code);
    }
  }

  Future<void> _manualEnterShelf() async {
    final controller = TextEditingController();
    // The dialog returns the submitted shelf code, or null on cancel.
    // We use [showSasoAdaptiveDialogBuilder] so the "確定" button can read
    // the live `controller.text` at tap time (an [AdaptiveDialogAction]'s
    // `value` is captured at construction and would be the empty initial
    // string otherwise).
    final result = await showSasoAdaptiveDialogBuilder<String>(
      context: context,
      title: '棚番号を入力',
      contentBuilder: (dialogCtx) => TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        decoration: const InputDecoration(
          hintText: '例: A-01',
          labelText: '棚番号',
        ),
        onSubmitted: (v) => Navigator.of(dialogCtx).pop(v),
      ),
      actionsBuilder: (dialogCtx) => [
        AdaptiveDialogActionBuilder<String>(
          label: 'キャンセル',
          onPressed: () => Navigator.of(dialogCtx).pop(),
        ),
        AdaptiveDialogActionBuilder<String>.primary(
          label: '確定',
          onPressed: () => Navigator.of(dialogCtx).pop(controller.text),
        ),
      ],
    );
    if (!mounted) return;
    if (result != null && result.isNotEmpty) {
      setState(() {
        _scannedShelfId = result;
        _phase = _Phase.item;
      });
    }
  }

  Future<void> _manualEnterItem() async {
    final controller = TextEditingController();
    final result = await showSasoAdaptiveDialogBuilder<String>(
      context: context,
      title: '商品コードを入力',
      contentBuilder: (dialogCtx) => TextField(
        controller: controller,
        autofocus: true,
        keyboardType: TextInputType.text,
        decoration: const InputDecoration(
          hintText: '例: 00001234',
          labelText: '商品コード / JANコード',
        ),
        onSubmitted: (v) => Navigator.of(dialogCtx).pop(v),
      ),
      actionsBuilder: (dialogCtx) => [
        AdaptiveDialogActionBuilder<String>(
          label: 'キャンセル',
          onPressed: () => Navigator.of(dialogCtx).pop(),
        ),
        AdaptiveDialogActionBuilder<String>.primary(
          label: '確定',
          onPressed: () => Navigator.of(dialogCtx).pop(controller.text),
        ),
      ],
    );
    if (!mounted) return;
    if (result != null && result.isNotEmpty) {
      setState(() {
        _scannedItemCode = result;
        _phase = _Phase.adjust;
      });
      await _resolveItem(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) {
      return _SuccessView(
        result: _result!,
        itemName: _item?.name ?? _scannedItemCode ?? '',
        shelfId: _scannedShelfId,
      );
    }

    final client = ref.watch(mcpClientProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('入出庫')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (client == null) const _NoMcpBanner(),
          if (_phase == _Phase.shelf) ...[
            _ScanPhaseCard(
              stepNumber: 1,
              title: '棚番号をスキャン',
              icon: Icons.shelves,
              hint: '棚のバーコード/QRコードを読み取ってください',
              onScan: _scanShelf,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _manualEnterShelf,
              icon: const Icon(Icons.keyboard),
              label: const Text('棚番号を手入力'),
            ),
          ],
          if (_phase == _Phase.item) ...[
            _ConfirmedBadge(icon: Icons.shelves, label: '棚: $_scannedShelfId'),
            const SizedBox(height: 12),
            _ScanPhaseCard(
              stepNumber: 2,
              title: '商品コードをスキャン',
              icon: Icons.qr_code_scanner,
              hint: '商品のバーコード/QRコードを読み取ってください',
              onScan: _scanItem,
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _manualEnterItem,
              icon: const Icon(Icons.keyboard),
              label: const Text('コードを手入力'),
            ),
          ],
          if (_phase == _Phase.adjust) ...[
            if (_scannedShelfId != null && _scannedShelfId!.isNotEmpty)
              _ConfirmedBadge(
                icon: Icons.shelves,
                label: '棚: $_scannedShelfId',
              ),
            if (_scannedItemCode != null) ...[
              const SizedBox(height: 8),
              _ConfirmedBadge(
                icon: Icons.qr_code,
                label: '商品コード: $_scannedItemCode',
              ),
            ],
            const SizedBox(height: 16),
            if (_loadingItem) const LinearProgressIndicator(),
            if (_item != null) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(_item!.name),
                  subtitle: Text('現在在庫: ${_item!.stock}'),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text('調整数量', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.outlined(
                  key: const Key('delta_decrement'),
                  onPressed: _delta > 1 ? () => setState(() => _delta--) : null,
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: 24),
                Text(
                  key: const Key('delta_value'),
                  '$_delta',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(width: 24),
                IconButton.outlined(
                  key: const Key('delta_increment'),
                  onPressed: () => setState(() => _delta++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('操作区分', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<AdjustmentReason>(
              key: const Key('reason_selector'),
              segments: AdjustmentReason.values
                  .map(
                    (r) => ButtonSegment<AdjustmentReason>(
                      value: r,
                      label: Text(r.label),
                    ),
                  )
                  .toList(),
              selected: {_reason},
              onSelectionChanged: (s) => setState(() => _reason = s.first),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null) ...[
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              const SizedBox(height: 8),
            ],
            FilledButton.icon(
              key: const Key('submit_button'),
              onPressed: (_submitting || _item == null) ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(_submitting ? '処理中…' : '確定'),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _NoMcpBanner extends StatelessWidget {
  const _NoMcpBanner();

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.errorContainer,
    margin: const EdgeInsets.only(bottom: 16),
    child: const ListTile(
      leading: Icon(Icons.cloud_off_outlined),
      title: Text('サーバー未接続'),
      subtitle: Text('入出庫操作にはRESTモードとJWTが必要です'),
    ),
  );
}

class _ScanPhaseCard extends StatelessWidget {
  const _ScanPhaseCard({
    required this.stepNumber,
    required this.title,
    required this.icon,
    required this.hint,
    required this.onScan,
  });

  final int stepNumber;
  final String title;
  final IconData icon;
  final String hint;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.secondaryContainer,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                child: Text(
                  '$stepNumber',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Icon(icon, size: 24),
            ],
          ),
          const SizedBox(height: 8),
          Text(hint, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onScan,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('スキャン'),
          ),
        ],
      ),
    ),
  );
}

class _ConfirmedBadge extends StatelessWidget {
  const _ConfirmedBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    ),
  );
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.result,
    required this.itemName,
    this.shelfId,
  });

  final StockAdjustmentResult result;
  final String itemName;
  final String? shelfId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('完了')),
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
              itemName,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '在庫: ${result.previousStock} → ${result.newStock}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (shelfId != null && shelfId!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('棚: $shelfId'),
            ],
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  key: const Key('continue_scan'),
                  onPressed: () =>
                      context.pushReplacement('/scanner?mode=inventory'),
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('続けてスキャン'),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  key: const Key('go_home'),
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
