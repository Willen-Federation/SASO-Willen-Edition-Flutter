import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_provider_config.dart';
import '../../../core/auth/auth_service.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/server_config_provider.dart';
import 'saml_webview_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _manualTokenController = TextEditingController();
  bool _loading = false;
  bool _showManualToken = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _manualTokenController.dispose();
    super.dispose();
  }

  Future<void> _loginWithCredentials() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'ユーザー名とパスワードを入力してください');
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final result = await ref
        .read(authStateNotifierProvider.notifier)
        .loginWithCredentials(username: username, password: password);
    if (!mounted) return;
    result.when(
      success: (_, __, ___, ____) => context.go('/home'),
      failure:
          (msg, __) => setState(() {
            _loading = false;
            _errorMessage = msg;
          }),
    );
  }

  Future<void> _loginWithBrowser() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final result =
        await ref.read(authStateNotifierProvider.notifier).loginWithBrowser();
    if (!mounted) return;
    result.when(
      success: (_, __, ___, ____) => context.go('/home'),
      failure:
          (msg, __) => setState(() {
            _loading = false;
            _errorMessage = msg;
          }),
    );
  }

  Future<void> _loginWithSaml() async {
    final providerConfig = ref.read(authProviderConfigNotifierProvider);
    if (providerConfig is! SamlAuthConfig) return;

    final token = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => SamlWebViewPage(loginUrl: providerConfig.loginUrl),
      ),
    );
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      setState(() => _errorMessage = 'SAMLログインがキャンセルされました');
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final result = await ref
        .read(authStateNotifierProvider.notifier)
        .loginWithSamlToken(token);
    if (!mounted) return;
    result.when(
      success: (_, __, ___, ____) => context.go('/home'),
      failure:
          (msg, __) => setState(() {
            _loading = false;
            _errorMessage = msg;
          }),
    );
  }

  Future<void> _loginWithManualToken() async {
    final raw = _manualTokenController.text.trim();
    if (raw.isEmpty) {
      setState(() => _errorMessage = 'ペアリングトークンを入力してください');
      return;
    }
    final serverUrl = ref.read(serverConfigNotifierProvider).baseUrl;
    if (serverUrl.isEmpty) {
      setState(() => _errorMessage = 'サーバーURLが設定されていません');
      return;
    }

    // Accept either a raw pairing token, or the full `SASO1:{token}|{host}`
    // payload (the same string a QR scan would produce). The token segment
    // is whatever sits between `SASO1:` and `|`.
    var pairingToken = raw;
    if (pairingToken.startsWith('SASO1:')) {
      pairingToken = pairingToken.substring('SASO1:'.length);
    }
    final pipe = pairingToken.indexOf('|');
    if (pipe >= 0) {
      pairingToken = pairingToken.substring(0, pipe);
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final result = await ref
        .read(authStateNotifierProvider.notifier)
        .loginWithQrToken(pairingToken: pairingToken, serverUrl: serverUrl);

    if (!mounted) return;
    result.when(
      success: (_, __, ___, ____) => context.go('/home'),
      failure: (msg, _) => setState(() {
        _loading = false;
        _errorMessage = msg;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(serverConfigNotifierProvider);
    final providerConfig = ref.watch(authProviderConfigNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ログイン'),
        actions: [
          TextButton(
            onPressed: () => context.push('/settings'),
            child: const Text('設定'),
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  // Server URL display
                  if (config.baseUrl.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        config.baseUrl,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                  // Provider badge
                  Center(child: _ProviderBadge(providerConfig)),
                  const SizedBox(height: 32),

                  // Error message
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ),
                    ),

                  // Adaptive login UI
                  switch (providerConfig) {
                    LegacyAuthConfig() ||
                    FirebaseAuthConfig() => _CredentialForm(
                      usernameController: _usernameController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      onTogglePassword:
                          () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                      onSubmit: _loginWithCredentials,
                    ),
                    OidcAuthConfig() ||
                    Auth0AuthConfig() ||
                    CognitoAuthConfig() => _BrowserLoginButton(
                      label: 'ブラウザでログイン',
                      onPressed: _loginWithBrowser,
                    ),
                    SamlAuthConfig() => _BrowserLoginButton(
                      label: 'SSOでログイン',
                      onPressed: _loginWithSaml,
                    ),
                  },

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 8),

                  // QR pairing link
                  OutlinedButton.icon(
                    key: const Key('qr_pairing_button'),
                    onPressed: () => context.push('/auth/qr'),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('QRコードでペアリング'),
                  ),

                  const SizedBox(height: 8),

                  // Manual token entry (collapsible)
                  TextButton(
                    key: const Key('manual_token_toggle'),
                    onPressed:
                        () => setState(
                          () => _showManualToken = !_showManualToken,
                        ),
                    child: Text(_showManualToken ? 'トークン入力を閉じる' : '手動でトークンを入力'),
                  ),

                  if (_showManualToken) ...[
                    const SizedBox(height: 8),
                    Text(
                      'サーバー画面 (/mypage/devicePair) で発行したペアリングトークンを貼り付けてください。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      key: const Key('manual_token_field'),
                      controller: _manualTokenController,
                      decoration: const InputDecoration(
                        labelText: 'ペアリングトークン',
                        hintText: 'SASO1:... もしくは生トークン',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      key: const Key('manual_token_submit'),
                      onPressed: _loginWithManualToken,
                      child: const Text('ペアリングを実行'),
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

class _ProviderBadge extends StatelessWidget {
  const _ProviderBadge(this.config);

  final AuthProviderConfig config;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (config) {
      LegacyAuthConfig() => ('標準ログイン', Icons.lock_outline),
      OidcAuthConfig() => ('OIDC / SSO', Icons.open_in_browser),
      SamlAuthConfig() => ('SAML SSO', Icons.security),
      FirebaseAuthConfig() => ('Firebase 認証', Icons.local_fire_department),
      Auth0AuthConfig() => ('Auth0', Icons.verified_user),
      CognitoAuthConfig() => ('Amazon Cognito', Icons.cloud),
    };

    return Chip(avatar: Icon(icon, size: 18), label: Text(label));
  }
}

class _CredentialForm extends StatelessWidget {
  const _CredentialForm({
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePassword,
    required this.onSubmit,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          key: const Key('username_field'),
          controller: usernameController,
          decoration: const InputDecoration(
            labelText: 'ユーザー名',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          keyboardType: TextInputType.text,
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: const [AutofillHints.username],
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextField(
          key: const Key('password_field'),
          controller: passwordController,
          decoration: InputDecoration(
            labelText: 'パスワード',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: onTogglePassword,
            ),
          ),
          obscureText: obscurePassword,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            key: const Key('login_submit_button'),
            onPressed: onSubmit,
            child: const Text('ログイン'),
          ),
        ),
      ],
    );
  }
}

class _BrowserLoginButton extends StatelessWidget {
  const _BrowserLoginButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        key: const Key('browser_login_button'),
        onPressed: onPressed,
        icon: const Icon(Icons.open_in_browser),
        label: Text(label),
      ),
    );
  }
}
