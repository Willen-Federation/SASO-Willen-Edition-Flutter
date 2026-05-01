import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/feature_flags/feature_flag_service.dart';
import '../../../core/feature_flags/providers/local_flag_provider.dart';
import '../../../core/network/connection_tester.dart';
import '../../providers/server_config_provider.dart';

class ServerSettingsPage extends ConsumerStatefulWidget {
  const ServerSettingsPage({super.key});

  @override
  ConsumerState<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends ConsumerState<ServerSettingsPage> {
  final _urlController = TextEditingController();
  late ApiMode _selectedMode;
  final _localFlags = LocalFlagProvider();
  final Map<String, bool> _flagOverrides = {};
  final ConnectionTester _connectionTester = ConnectionTester();
  bool _testing = false;
  ConnectionTestResult? _lastTestResult;

  @override
  void initState() {
    super.initState();
    _localFlags.initialize();
    final config = ref.read(serverConfigNotifierProvider);
    _urlController.text = config.baseUrl;
    _selectedMode = config.apiMode;
    _initFlagOverrides();
  }

  void _initFlagOverrides() {
    for (final key in FeatureFlags.defaults.keys) {
      _flagOverrides[key] = FeatureFlagService.instance.getBool(key);
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    await ref
        .read(serverConfigNotifierProvider.notifier)
        .save(url: _urlController.text.trim(), mode: _selectedMode);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('設定を保存しました')));
    context.pop();
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _lastTestResult = null;
    });
    final config = ref
        .read(serverConfigNotifierProvider)
        .copyWith(baseUrl: _urlController.text.trim(), apiMode: _selectedMode);
    final result = await _connectionTester.test(config);
    if (!mounted) return;
    setState(() {
      _testing = false;
      _lastTestResult = result;
    });
  }

  String _resultLabel(ConnectionTestResult result) => switch (result) {
    ConnectionTestSuccess(:final latency, :final statusCode) =>
      '接続成功 (HTTP $statusCode, ${latency.inMilliseconds}ms)',
    ConnectionTestFailure(:final message) => message,
    ConnectionTestTimeout(:final timeout) => 'タイムアウト (${timeout.inSeconds}秒)',
  };

  Color _resultColor(ConnectionTestResult result) => switch (result) {
    ConnectionTestSuccess() => Colors.green,
    ConnectionTestFailure() => Colors.red,
    ConnectionTestTimeout() => Colors.orange,
  };

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('サーバー設定'),
      actions: [TextButton(onPressed: _save, child: const Text('保存'))],
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // API Mode
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('APIモード', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                RadioGroup<ApiMode>(
                  groupValue: _selectedMode,
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedMode = v);
                  },
                  child: Column(
                    children: ApiMode.values
                        .map(
                          (mode) => RadioListTile<ApiMode>(
                            value: mode,
                            title: Text(_modeLabel(mode)),
                            subtitle: Text(_modeDescription(mode)),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Server URL
        if (_selectedMode != ApiMode.mock)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'サーバーURL',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _urlController,
                    decoration: const InputDecoration(
                      hintText: 'https://saso.example.com',
                      labelText: 'サーバーURL',
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        key: const Key('test_connection_button'),
                        onPressed: _testing ? null : _testConnection,
                        icon:
                            _testing
                                ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Icon(Icons.network_check),
                        label: const Text('接続テスト'),
                      ),
                      const SizedBox(width: 12),
                      if (_lastTestResult != null)
                        Expanded(
                          child: Text(
                            _resultLabel(_lastTestResult!),
                            style: TextStyle(
                              color: _resultColor(_lastTestResult!),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),

        // Feature Flags (debug only visible to users too for QA)
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '機能フラグ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: 8),
                    if (kDebugMode)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'DEBUG: 全ON',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'インフラ側でリモート制御可能（Firebase Remote Config）',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                ..._flagOverrides.entries.map(
                  (e) => SwitchListTile(
                    title: Text(_flagLabel(e.key)),
                    subtitle: Text(e.key),
                    value: e.value,
                    onChanged: (v) {
                      setState(() => _flagOverrides[e.key] = v);
                      _localFlags.setFlag(e.key, v);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  String _modeLabel(ApiMode mode) => switch (mode) {
    ApiMode.mock => 'モック（サーバー不要）',
    ApiMode.legacy => 'レガシー（互換モード）',
    ApiMode.rest => 'REST v1（M3以降）',
  };

  String _modeDescription(ApiMode mode) => switch (mode) {
    ApiMode.mock => 'テスト・開発用。実データは使用しない',
    ApiMode.legacy => '既存SASAサーバーに接続。廃止予定エンドポイント使用',
    ApiMode.rest => 'SASO M3以降のREST APIに接続（要M3サーバー）',
  };

  String _flagLabel(String key) => switch (key) {
    FeatureFlags.restApiV1 => 'REST API v1',
    FeatureFlags.pushFcm => 'FCMプッシュ通知',
    FeatureFlags.pushSns => 'Amazon SNSプッシュ通知',
    FeatureFlags.authOidc => 'OIDC認証',
    FeatureFlags.authFirebase => 'Firebase認証',
    FeatureFlags.offlineMode => 'オフラインモード',
    FeatureFlags.barcodeScanner => 'バーコードスキャン',
    FeatureFlags.labelPrint => 'ラベル印刷',
    _ => key,
  };
}
