import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/services/pairing_web_auth_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../data/datasources/remote/discovery_api_client.dart';
import '../../../data/datasources/remote/v1/rest_api_client.dart';
import '../../layout/responsive.dart';
import '../../providers/server_config_provider.dart';

/// Two-tab registration screen: scan a SASO QR code or type a server URL.
///
/// Both paths funnel into [RestV1ApiClient.connect] and on success persist
/// the access + refresh tokens to secure storage and the server URL to
/// shared preferences.
class RegistrationPage extends ConsumerStatefulWidget {
  const RegistrationPage({super.key});

  @override
  ConsumerState<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends ConsumerState<RegistrationPage> {
  final _urlController = TextEditingController();
  bool _busy = false;
  String? _error;
  String? _status;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _handleQrPayload(String payload) async {
    if (!payload.startsWith('SASO1:')) {
      setState(() => _error = 'SASO の QR ではありません');
      return;
    }
    final body = payload.substring('SASO1:'.length);
    final pipe = body.indexOf('|');
    if (pipe < 0 || pipe >= body.length - 1) {
      setState(() => _error = 'QR の形式が壊れています');
      return;
    }
    final token = body.substring(0, pipe);
    final server = body.substring(pipe + 1);
    await _completeWithPairingToken(server: server, token: token);
  }

  Future<void> _handleUrl() async {
    final input = _urlController.text.trim();
    if (input.isEmpty) {
      setState(() => _error = 'サーバー URL を入力してください');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _status = '接続を確認しています…';
    });

    try {
      final discovery = await DiscoveryApiClient().discover(input);
      setState(() => _status = '${discovery.serverName} にログインしています…');

      final setupUri = Uri.parse(discovery.mobileSetupUrl);
      final auth = PairingWebAuthService();
      final result = await auth.requestPairing(setupUri);

      await _completeWithPairingToken(
        server: result.serverUrl,
        token: result.token,
      );
    } on DiscoveryFailure catch (e) {
      _showError(e.message);
    } on PairingWebAuthFailure catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('接続に失敗しました: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _completeWithPairingToken({
    required String server,
    required String token,
  }) async {
    setState(() {
      _busy = true;
      _error = null;
      _status = 'トークンを取得しています…';
    });
    try {
      final deviceName = await _deviceName();
      final client = RestV1ApiClient(serverUrl: server);
      final tokens = await client.connect(
        pairingToken: token,
        deviceName: deviceName,
      );

      final secure = ref.read(secureStorageProvider);
      await secure.write(AppConstants.jwtTokenKey, tokens.accessToken);
      await secure.write(AppConstants.refreshTokenKey, tokens.refreshToken);

      await ref.read(serverConfigNotifierProvider.notifier).save(
            url: server,
            mode: ApiMode.rest,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登録が完了しました')),
      );
      context.go('/home');
    } catch (e) {
      _showError('連携に失敗しました: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String> _deviceName() async {
    if (kIsWeb) return 'SASO Web';
    if (Platform.isIOS) return 'SASO iOS';
    if (Platform.isAndroid) return 'SASO Android';
    if (Platform.isMacOS) return 'SASO macOS';
    return 'SASO Mobile';
  }

  void _showError(String message) {
    setState(() {
      _error = message;
      _status = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('システム登録'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.qr_code_2), text: 'QR コード'),
              Tab(icon: Icon(Icons.link), text: 'URL を入力'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _QrTab(
              onPayload: _handleQrPayload,
              busy: _busy,
              error: _error,
              status: _status,
            ),
            _UrlTab(
              controller: _urlController,
              onSubmit: _handleUrl,
              busy: _busy,
              error: _error,
              status: _status,
            ),
          ],
        ),
      ),
    );
  }
}

class _QrTab extends StatelessWidget {
  const _QrTab({
    required this.onPayload,
    required this.busy,
    required this.error,
    required this.status,
  });

  final ValueChanged<String> onPayload;
  final bool busy;
  final String? error;
  final String? status;

  @override
  Widget build(BuildContext context) {
    return AdaptiveContainer(
      maxWidth: 480,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '管理画面で表示した QR コードをスキャンします',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '管理画面: 設定 > モバイル接続 > QR コード生成',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: busy
                        ? null
                        : () async {
                            final result =
                                await context.push<String>('/scanner/jan');
                            if (result != null) onPayload(result);
                          },
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('QR を読み取る'),
                  ),
                ],
              ),
            ),
          ),
          if (status != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(status!)),
                ],
              ),
            ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}

class _UrlTab extends StatelessWidget {
  const _UrlTab({
    required this.controller,
    required this.onSubmit,
    required this.busy,
    required this.error,
    required this.status,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final bool busy;
  final String? error;
  final String? status;

  @override
  Widget build(BuildContext context) {
    return AdaptiveContainer(
      maxWidth: 480,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'サーバー URL を入力',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '入力後、サーバーの設定に従ってログイン画面が表示されます',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'サーバー URL',
                      hintText: 'https://saso.example.com',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    enableSuggestions: false,
                    enabled: !busy,
                    onSubmitted: (_) => onSubmit(),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: busy ? null : onSubmit,
                    icon: const Icon(Icons.login),
                    label: const Text('ログインに進む'),
                  ),
                ],
              ),
            ),
          ),
          if (status != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text(status!)),
                ],
              ),
            ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
        ],
      ),
    );
  }
}
