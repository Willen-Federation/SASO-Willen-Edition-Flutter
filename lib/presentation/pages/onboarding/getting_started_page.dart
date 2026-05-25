import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/auth/auth_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/connection_tester.dart';
import '../../../core/network/url_validator.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/server_config_provider.dart';

/// First-launch configuration screen.
///
/// Shown whenever no server URL has been saved yet. The user can either:
///   • Tap the camera icon to scan a QR code shown on the SASO web portal
///     (the QR embeds the server URL as a plain string or JSON `{"url":"…"}`).
///   • Type the URL manually and tap "接続して始める".
///
/// On a successful connection test the URL is saved in REST mode and
/// the router redirects to the auth login page automatically.
class GettingStartedPage extends ConsumerStatefulWidget {
  const GettingStartedPage({super.key});

  @override
  ConsumerState<GettingStartedPage> createState() => _GettingStartedPageState();
}

class _GettingStartedPageState extends ConsumerState<GettingStartedPage> {
  final _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _connecting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  /// Open the barcode scanner in register mode; the scanned raw string is
  /// expected to be either:
  ///   • `SASO1:{base64url_token}|{server_url}` — full pairing QR (token + URL)
  ///   • a plain URL or JSON `{"url":"…"}` — server-URL-only QR
  Future<void> _scanQrCode() async {
    final raw = await context.push<String?>('/scanner/jan');
    if (raw == null || raw.trim().isEmpty) return;
    final trimmed = raw.trim();

    // Full pairing QR: contains both the token and the server URL.
    // Parse it and establish the session directly without requiring a
    // separate manual URL step.
    final pairing = _parseSaso1Qr(trimmed);
    if (pairing != null) {
      await _connectWithPairingQr(pairing.$1, pairing.$2);
      return;
    }

    // URL-only QR: populate the text field so the user can confirm.
    final url = _extractUrl(trimmed);
    if (url != null) {
      _urlController.text = url;
      setState(() => _errorMessage = null);
    } else {
      setState(() => _errorMessage = 'QRコードからURLを読み取れませんでした: $trimmed');
    }
  }

  /// Parses a `SASO1:{token}|{serverUrl}` payload.
  /// Returns `(token, serverUrl)` or null if the raw string is not in that format.
  (String, String)? _parseSaso1Qr(String raw) {
    const prefix = 'SASO1:';
    if (!raw.startsWith(prefix)) return null;
    final payload = raw.substring(prefix.length);
    final pipe = payload.indexOf('|');
    if (pipe < 0) return null;
    final token = payload.substring(0, pipe);
    final url = payload.substring(pipe + 1);
    if (token.isEmpty || url.isEmpty) return null;
    return (token, url);
  }

  /// Handles a full SASO1 pairing QR: saves the server URL, then exchanges
  /// the pairing token for a JWT in one step.
  Future<void> _connectWithPairingQr(
    String pairingToken,
    String serverUrl,
  ) async {
    setState(() {
      _connecting = true;
      _errorMessage = null;
    });
    try {
      final normalized =
          UrlValidator.ensureHttpsOrLoopback(serverUrl).toString();
      final detected = await ConnectionTester().autoDetect(normalized);

      if (!mounted) return;

      final result = detected.result;
      if (result is ConnectionTestFailure || result is ConnectionTestTimeout) {
        final msg = switch (result) {
          ConnectionTestFailure(message: final m) => m,
          ConnectionTestTimeout(timeout: final t) => 'タイムアウト (${t.inSeconds}秒)',
          _ => '接続失敗',
        };
        setState(() => _errorMessage = '接続できませんでした: $msg');
        return;
      }

      await ref
          .read(serverConfigNotifierProvider.notifier)
          .save(url: normalized, mode: detected.mode);

      if (!mounted) return;

      final authResult = await ref
          .read(authStateNotifierProvider.notifier)
          .loginWithQrToken(
            pairingToken: pairingToken,
            serverUrl: normalized,
          );

      if (!mounted) return;

      authResult.when(
        success: (_, __, ___, ____) => context.go('/home'),
        failure: (msg, _) =>
            setState(() => _errorMessage = 'ペアリング失敗: $msg'),
      );
    } on ArgumentError catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'サーバーURL不正: ${e.message}');
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'エラー: $e');
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  /// Extract a server URL from a raw QR payload.
  ///
  /// Handles:
  ///   1. Plain URL — `https://saso.example.com`
  ///   2. JSON — `{"url":"https://saso.example.com"}`
  ///   3. Prefixed — `SASO:https://saso.example.com`
  String? _extractUrl(String raw) {
    // JSON object?
    if (raw.startsWith('{')) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        final urlField = map['url'] ?? map['server_url'] ?? map['baseUrl'];
        if (urlField is String && urlField.isNotEmpty) return urlField;
      } catch (_) {}
    }
    // Prefixed?
    for (final prefix in ['SASO:', 'SASO_CONFIG:']) {
      if (raw.startsWith(prefix)) {
        return raw.substring(prefix.length);
      }
    }
    // Plain URL?
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return null;
  }

  /// Open the locale-appropriate Privacy Policy URL in an external browser.
  ///
  /// Issue #142 / #122 require a privacy-policy link in the onboarding
  /// flow because users may submit credentials on the next screen without
  /// ever reaching Settings. The link is shown unconditionally; SnackBar
  /// errors are surfaced rather than failing silently.
  Future<void> _openPrivacyPolicy() async {
    final locale = Localizations.localeOf(context);
    final url = locale.languageCode == 'ja'
        ? AppConstants.privacyPolicyUrlJa
        : AppConstants.privacyPolicyUrlEn;
    final uri = Uri.parse(url);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('プライバシーポリシーを開けませんでした: $url')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('プライバシーポリシーを開けませんでした: $e')));
    }
  }

  Future<void> _connect() async {
    if (!_formKey.currentState!.validate()) return;
    final urlRaw = _urlController.text.trim();

    setState(() {
      _connecting = true;
      _errorMessage = null;
    });

    try {
      // Normalise (strips trailing slash, enforces https for non-loopback).
      final normalized = UrlValidator.ensureHttpsOrLoopback(urlRaw).toString();

      // Auto-detect whether the server speaks REST v1 (/api/v1/health) or
      // the legacy API (/category/list.json) and save the matching mode so
      // the correct ApiClient and auth flow are used downstream.
      final detected = await ConnectionTester().autoDetect(normalized);

      if (!mounted) return;

      final result = detected.result;
      if (result is ConnectionTestFailure || result is ConnectionTestTimeout) {
        final msg = switch (result) {
          ConnectionTestFailure(message: final m) => m,
          ConnectionTestTimeout(timeout: final t) => 'タイムアウト (${t.inSeconds}秒)',
          _ => '接続失敗',
        };
        setState(() => _errorMessage = '接続できませんでした: $msg');
        return;
      }

      // Save URL + detected mode; the GoRouter redirect will take the user to
      // /auth/login automatically once the state changes.
      await ref
          .read(serverConfigNotifierProvider.notifier)
          .save(url: normalized, mode: detected.mode);

      if (!mounted) return;
      context.go('/auth/login');
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'エラー: $e');
    } finally {
      if (mounted) setState(() => _connecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Hero ───────────────────────────────────────────────────
                const SizedBox(height: 16),
                Center(
                  child: Image.asset(
                    'assets/images/branding/saso-full-512.png',
                    height: 96,
                    fit: BoxFit.contain,
                    semanticLabel: 'SASO Willen ロゴ',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'サーバーに接続して始めましょう',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 40),

                // ── QR scan card ───────────────────────────────────────────
                MergeSemantics(
                  child: Semantics(
                    button: true,
                    enabled: !_connecting,
                    label:
                        'QRコードをスキャン。'
                        'サーバー管理画面に表示されるQRコードを読み取ります',
                    child: Card(
                      child: InkWell(
                        onTap: _connecting ? null : _scanQrCode,
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.qr_code_scanner,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'QRコードをスキャン',
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'サーバー管理画面に表示されるQRコードを読み取ります',
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Divider ────────────────────────────────────────────────
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'または',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Manual URL input ───────────────────────────────────────
                TextFormField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    labelText: 'サーバーURL',
                    hintText: 'https://saso.example.com',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.language_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'URLをクリア',
                      onPressed: () => _urlController.clear(),
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'URLを入力してください';
                    }
                    final trimmed = v.trim();
                    if (!trimmed.startsWith('http://') &&
                        !trimmed.startsWith('https://')) {
                      return 'http:// または https:// で始まるURLを入力してください';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // ── Error message ──────────────────────────────────────────
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: colorScheme.error),
                    ),
                  ),

                // ── Connect button ─────────────────────────────────────────
                FilledButton.icon(
                  onPressed: _connecting ? null : _connect,
                  icon: _connecting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.link),
                  label: Text(_connecting ? '接続中…' : '接続して始める'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),

                const SizedBox(height: 40),

                // ── Footer hint ────────────────────────────────────────────
                Text(
                  'サーバーURLは管理者にお問い合わせください',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 16),

                // ── Privacy Policy link ───────────────────────────────────
                //
                // Required by Google Play (Issue #142) and App Store
                // (Issue #122). Surfaced here because the next screen
                // collects credentials — users must be able to review the
                // policy before signing in.
                Center(
                  child: TextButton.icon(
                    key: const Key('privacy_policy_link'),
                    onPressed: _openPrivacyPolicy,
                    icon: const Icon(Icons.privacy_tip_outlined, size: 18),
                    label: const Text('プライバシーポリシー'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
