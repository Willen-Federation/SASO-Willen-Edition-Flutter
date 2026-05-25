import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_provider_config.dart';
import '../../../core/auth/auth_service.dart';
import '../../../router/adaptive_page.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/server_config_provider.dart';
import 'mobile_setup_webview_page.dart';

/// Unified login page.
///
/// Renders independent sections back-to-back, each gated on what the
/// server's `/api/v1/auth/providers` discovery returned:
///   1. Username / password form — shown when the server advertises the
///      built-in `local` provider in discovery, OR when the active
///      [ApiMode] is [ApiMode.rest]. The REST-mode fallback exists
///      because `POST /api/v1/auth/login` (PR-A3) is always available
///      on REST-capable servers regardless of which IdP rows are
///      registered in the `auth_provider` table — discovery only lists
///      externally-configured IdPs (OIDC / SAML / Auth0 / …) and never
///      synthesizes a `local` entry of its own.
///   2. Auth0 — dedicated branded button shown only when discovery
///      returned an enabled `auth0` provider with `domain` + `clientId`
///      in its `config` map. Drives Auth0 Universal Login through the
///      native `auth0_flutter` SDK, bypassing the WebView setup flow.
///   3. Other server-configured providers — one button per enabled
///      non-local, non-Auth0 provider (OIDC / SAML / Cognito / Firebase).
///      Tapping opens the server's `/m/setup?provider_id=…` flow in an
///      in-app WebView and exchanges the returned pairing token for a JWT.
///   4. QR pairing + manual token entry — always available regardless of
///      discovery, since the pairing tokens come from `/mypage/devicePair`.
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
      failure: (msg, _) => setState(() {
        _loading = false;
        _errorMessage = msg;
      }),
    );
  }

  Future<void> _loginWithAuth0(AuthProviderSummary provider) async {
    final domain = provider.auth0Domain;
    final clientId = provider.auth0ClientId;
    if (domain == null || clientId == null) {
      setState(() => _errorMessage = 'Auth0 設定が不完全です (domain / clientId)');
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    final result = await ref
        .read(authStateNotifierProvider.notifier)
        .loginWithAuth0(domain: domain, clientId: clientId);
    if (!mounted) return;
    result.when(
      success: (_, __, ___, ____) => context.go('/home'),
      failure: (msg, _) => setState(() {
        _loading = false;
        _errorMessage = msg;
      }),
    );
  }

  Future<void> _loginWithProvider(AuthProviderSummary provider) async {
    final serverUrl = ref.read(serverConfigNotifierProvider).baseUrl;
    if (serverUrl.isEmpty) {
      setState(() => _errorMessage = 'サーバーURLが設定されていません');
      return;
    }

    final token = await Navigator.of(context).push<String?>(
      adaptivePageRoute<String?>(
        builder: (_) => MobileSetupWebViewPage(
          serverUrl: serverUrl,
          providerId: provider.id,
          providerName: provider.name,
        ),
      ),
    );
    if (!mounted) return;
    if (token == null || token.isEmpty) {
      setState(() => _errorMessage = 'ログインがキャンセルされました');
      return;
    }
    await _exchangePairingToken(token, serverUrl);
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

    await _exchangePairingToken(pairingToken, serverUrl);
  }

  Future<void> _exchangePairingToken(
    String pairingToken,
    String serverUrl,
  ) async {
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
    final discovery = ref.watch(serverAuthDiscoveryNotifierProvider);
    final theme = Theme.of(context);

    // Show the credential form when the server advertises a `local`
    // provider, OR when the active API mode is `rest` — the REST
    // `/api/v1/auth/login` endpoint is always available against a
    // REST-capable server, even when discovery only lists external IdPs.
    final showCredentialForm =
        discovery.hasLocalLogin || config.apiMode == ApiMode.rest;
    final auth0Provider = discovery.auth0Provider;
    final externalProviders = discovery.externalProviders;

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
      // Issue #146 — Android 15 edge-to-edge: wrap body in SafeArea so
      // ListView padding still clears the gesture inset, but the AppBar
      // can draw through the status-bar area.
      body: SafeArea(
        top: false,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: Image.asset(
                        'assets/images/branding/saso-full-512.png',
                        height: 80,
                        fit: BoxFit.contain,
                        semanticLabel: 'SASO-WILLEN ロゴ',
                      ),
                    ),
                  ),
                  if (config.baseUrl.isNotEmpty ||
                      discovery.serverName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          if (discovery.serverName.isNotEmpty)
                            Text(
                              discovery.serverName,
                              style: theme.textTheme.titleMedium,
                              textAlign: TextAlign.center,
                            ),
                          if (config.baseUrl.isNotEmpty)
                            Text(
                              config.baseUrl,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                              textAlign: TextAlign.center,
                            ),
                        ],
                      ),
                    ),

                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      // SelectableText so the user can long-press and copy
                      // the (potentially long) HTTP status + body snippet to
                      // share with support.
                      child: SelectableText(
                        _errorMessage!,
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),

                  // ── 2-a. Username / password ─────────────────────────────
                  if (showCredentialForm) ...[
                    const _SectionHeader(
                      icon: Icons.lock_outline,
                      label: 'ユーザー名でログイン',
                    ),
                    const SizedBox(height: 12),
                    _CredentialForm(
                      usernameController: _usernameController,
                      passwordController: _passwordController,
                      obscurePassword: _obscurePassword,
                      onTogglePassword: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      onSubmit: _loginWithCredentials,
                    ),
                  ],

                  // ── 2-b. Auth0 (dedicated, native SDK) ───────────────────
                  if (auth0Provider != null) ...[
                    if (showCredentialForm) const SizedBox(height: 24),
                    const _SectionHeader(
                      icon: Icons.verified_user,
                      label: 'Auth0 でログイン',
                    ),
                    const SizedBox(height: 12),
                    _Auth0Button(
                      label: auth0Provider.name.isNotEmpty
                          ? auth0Provider.name
                          : 'Auth0 でログイン',
                      onPressed: () => _loginWithAuth0(auth0Provider),
                    ),
                  ],

                  // ── 2-c. Other server-configured providers ───────────────
                  if (externalProviders.isNotEmpty) ...[
                    if (showCredentialForm || auth0Provider != null)
                      const SizedBox(height: 24),
                    const _SectionHeader(
                      icon: Icons.open_in_browser,
                      label: 'サーバー設定のログイン方法',
                    ),
                    const SizedBox(height: 12),
                    for (final provider in externalProviders) ...[
                      _ProviderButton(
                        provider: provider,
                        onPressed: () => _loginWithProvider(provider),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],

                  // ── 2-d. QR / manual pairing token ───────────────────────
                  const SizedBox(height: 24),
                  const _SectionHeader(
                    icon: Icons.qr_code_scanner,
                    label: 'QRコード / 手動トークン',
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    key: const Key('qr_pairing_button'),
                    onPressed: () => context.push('/auth/qr'),
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('QRコードでペアリング'),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    key: const Key('manual_token_toggle'),
                    onPressed: () =>
                        setState(() => _showManualToken = !_showManualToken),
                    child: Text(_showManualToken ? 'トークン入力を閉じる' : '手動でトークンを入力'),
                  ),
                  if (_showManualToken) ...[
                    const SizedBox(height: 8),
                    Text(
                      'サーバー画面 (/mypage/devicePair) で発行したペアリングトークンを貼り付けてください。',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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
        const SizedBox(height: 12),
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
              tooltip: obscurePassword ? 'パスワードを表示' : 'パスワードを隠す',
              onPressed: onTogglePassword,
            ),
          ),
          obscureText: obscurePassword,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 12),
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

/// Auth0-branded login button. Sits in its own widget so the brand
/// colour / accessibility label can evolve without touching the generic
/// provider list. Only rendered when discovery confirms Auth0 is enabled
/// and configured.
class _Auth0Button extends StatelessWidget {
  const _Auth0Button({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  // Auth0 brand orange (https://auth0.com/brand). The foreground is pinned to
  // white because Auth0's brand guidelines specify white-on-orange for the
  // primary CTA — it does not follow `ColorScheme` in either theme. Both are
  // declared as named constants so the brand exception is explicit (per #128
  // acceptance criterion 5) rather than scattered `Colors.white` literals.
  static const _brand = Color(0xFFEB5424);
  static const _onBrand = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        key: const Key('auth0_login_button'),
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: _brand,
          foregroundColor: _onBrand,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: const Icon(Icons.verified_user),
        label: Text(label),
      ),
    );
  }
}

class _ProviderButton extends StatelessWidget {
  const _ProviderButton({required this.provider, required this.onPressed});

  final AuthProviderSummary provider;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = switch (provider.type) {
      AuthProviderType.oidc => Icons.open_in_browser,
      AuthProviderType.saml => Icons.security,
      AuthProviderType.firebase => Icons.local_fire_department,
      AuthProviderType.auth0 => Icons.verified_user,
      AuthProviderType.cognito => Icons.cloud,
      _ => Icons.login,
    };
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        key: Key('provider_button_${provider.id}'),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(provider.name),
      ),
    );
  }
}
