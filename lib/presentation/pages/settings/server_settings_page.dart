import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saso_willen_edition/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/feature_flags/feature_flag_service.dart';
import '../../../core/feature_flags/providers/local_flag_provider.dart';
import '../../../core/network/connection_tester.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../providers/auth_state_provider.dart';
import '../../providers/server_config_provider.dart';
import '../../widgets/common/adaptive_dialog.dart';

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
  late bool _offlineMode;
  late bool _aiAutofill;

  @override
  void initState() {
    super.initState();
    _localFlags.initialize();
    final config = ref.read(serverConfigNotifierProvider);
    _urlController.text = config.baseUrl;
    _selectedMode = config.apiMode;
    _offlineMode = config.offlineMode;
    _aiAutofill = config.aiAutofillEnabled;
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
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.settingsSaved)));
    context.pop();
  }

  Future<void> _openMyPage() async {
    final base = _urlController.text.trim();
    final l10n = AppLocalizations.of(context)!;
    if (base.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.qrPairingNoServerUrl)));
      return;
    }
    Uri uri;
    try {
      uri = Uri.parse('$base/mypage/');
    } on FormatException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.openWebPortalFailed(e.message))),
      );
      return;
    }
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.openWebPortalFailed(uri.toString()))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.openWebPortalFailed(e.toString()))),
      );
    }
  }

  Future<void> _logout() async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showSasoAdaptiveDialog<bool>(
      context: context,
      title: l10n.logout,
      message: l10n.logoutConfirmMessage,
      actions: [
        AdaptiveDialogAction<bool>(label: l10n.cancel, value: false),
        AdaptiveDialogAction<bool>.destructive(label: l10n.logout, value: true),
      ],
    );
    if (confirm != true) return;
    if (!mounted) return;
    await ref.read(authStateNotifierProvider.notifier).logout();
    if (!mounted) return;
    context.go('/auth/login');
  }

  /// Open the Privacy Policy page in an external browser.
  ///
  /// Required by Google Play (Issue #142) and the App Store (Issue #122).
  /// The locale-appropriate URL is selected from [AppConstants]; both URLs
  /// resolve to the same Markdown source published at
  /// `docs/legal/privacy-policy.md`. Errors are surfaced via SnackBar so
  /// users on a kiosked device know to ask their administrator.
  Future<void> _openPrivacyPolicy() async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    final url = locale.languageCode == 'ja'
        ? AppConstants.privacyPolicyUrlJa
        : AppConstants.privacyPolicyUrlEn;
    final uri = Uri.parse(url);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.privacyPolicyOpenFailed(url))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.privacyPolicyOpenFailed(e.toString()))),
      );
    }
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

  String _resultLabel(ConnectionTestResult result) {
    final l10n = AppLocalizations.of(context)!;
    if (result is ConnectionTestSuccess) {
      return '${l10n.connectionSuccess} (HTTP ${result.statusCode}, ${result.latency.inMilliseconds}ms)';
    }
    if (result is ConnectionTestTimeout) {
      return '${l10n.connectionFailed} (${result.timeout.inSeconds}s)';
    }
    if (result is ConnectionTestFailure) {
      final msg = result.message;
      if (msg == 'URL_MISSING') return l10n.connectionTestUrlMissing;
      if (msg == 'URL_INVALID') return l10n.connectionTestUrlInvalid;
      if (msg == 'HTTP_ERROR') {
        return l10n.connectionTestHttpError(result.statusCode ?? 0);
      }
      if (msg.startsWith('NETWORK_ERROR:')) {
        return l10n.connectionTestFailure(
          msg.substring('NETWORK_ERROR:'.length),
        );
      }
      return l10n.connectionTestFailure(msg);
    }
    return l10n.error;
  }

  Color _resultColor(ConnectionTestResult result) => switch (result) {
    ConnectionTestSuccess() => Colors.green,
    ConnectionTestFailure() => Colors.red,
    ConnectionTestTimeout() => Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final baseUrl = _urlController.text.trim();
    final mypageUrl = baseUrl.isEmpty ? '<server>/mypage/' : '$baseUrl/mypage/';
    final isProduction = _selectedMode == ApiMode.rest;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsHeader),
        actions: [TextButton(onPressed: _save, child: Text(l10n.save))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ── Brand header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Center(
              child: Image.asset(
                'assets/images/branding/saso-full-512.png',
                height: 56,
                fit: BoxFit.contain,
                semanticLabel: 'SASO Willen ロゴ',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Production mode banner ─────────────────────────────────────
          if (isProduction) ...[
            Card(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: ListTile(
                leading: Icon(
                  Icons.verified_outlined,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                title: Text(
                  '本番モードで接続中',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  _urlController.text.isNotEmpty
                      ? _urlController.text
                      : 'サーバーURL未設定',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                trailing: TextButton.icon(
                  icon: const Icon(Icons.link_off),
                  label: const Text('再設定'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer,
                  ),
                  onPressed: () => context.go('/onboarding'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // ── API Mode (hidden in production / REST mode) ────────────────
          //
          // Mode selector layout (PR-B2, deprecation phase):
          //   • Primary radios: only mock + rest. These are the modes new
          //     deployments should use.
          //   • Collapsed "Compatibility mode (deprecated)" ExpansionTile:
          //     holds the legacy radio, opened by default ONLY when legacy
          //     is currently selected so existing users still see their
          //     selection without an extra click.
          //   • Deprecation banner: surfaces above the selector whenever
          //     legacy is the active mode, regardless of expansion state.
          //
          // The ApiMode.legacy enum value carries @Deprecated; analyzer
          // warnings inside this widget are suppressed because we render
          // the chooser explicitly to let users migrate off the mode.
          if (!isProduction) ...[
            // ignore: deprecated_member_use_from_same_package
            if (_selectedMode == ApiMode.legacy) _LegacyDeprecationBanner(l10n),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.apiMode,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    // Primary, supported modes — mock + rest only.
                    ...[ApiMode.mock, ApiMode.rest].map(
                      (mode) => RadioListTile<ApiMode>(
                        value: mode,
                        // ignore: deprecated_member_use
                        groupValue: _selectedMode,
                        title: Text(_modeLabel(mode, l10n)),
                        subtitle: Text(_modeDescription(mode, l10n)),
                        // ignore: deprecated_member_use
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedMode = v);
                        },
                      ),
                    ),
                    const Divider(height: 24),
                    // Deprecated mode — collapsed by default unless the
                    // user is currently in legacy mode.
                    ExpansionTile(
                      key: const Key('compatibility_mode_section'),
                      // ignore: deprecated_member_use_from_same_package
                      initiallyExpanded: _selectedMode == ApiMode.legacy,
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.history_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      title: Text(
                        l10n.compatibilityModeSection,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      subtitle: Text(
                        l10n.compatibilityModeSubtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      children: [
                        RadioListTile<ApiMode>(
                          // ignore: deprecated_member_use_from_same_package
                          value: ApiMode.legacy,
                          // ignore: deprecated_member_use
                          groupValue: _selectedMode,
                          // ignore: deprecated_member_use_from_same_package
                          title: Text(_modeLabel(ApiMode.legacy, l10n)),
                          // ignore: deprecated_member_use_from_same_package
                          subtitle: Text(
                            // ignore: deprecated_member_use_from_same_package
                            _modeDescription(ApiMode.legacy, l10n),
                          ),
                          // ignore: deprecated_member_use
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedMode = v);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Server URL
          if (_selectedMode != ApiMode.mock)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.serverUrl,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _urlController,
                      decoration: InputDecoration(
                        hintText: l10n.serverUrlHint,
                        labelText: l10n.serverUrl,
                      ),
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          key: const Key('test_connection_button'),
                          onPressed: _testing ? null : _testConnection,
                          icon: _testing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.network_check),
                          label: Text(l10n.testConnection),
                        ),
                        const SizedBox(width: AppSpacing.sm),
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
          const SizedBox(height: AppSpacing.md),

          // Paired-devices section: redirects to the web /mypage portal.
          // Mobile JWTs can't manage device tokens directly (admin session
          // required) — see docs/api-endpoint-map.md.
          if (_selectedMode != ApiMode.mock)
            Card(
              child: ListTile(
                key: const Key('manage_devices_on_web_tile'),
                leading: const Icon(Icons.devices_other_outlined),
                title: Text(l10n.manageDevicesOnWeb),
                subtitle: Text(l10n.manageDevicesOnWebSubtitle(mypageUrl)),
                trailing: const Icon(Icons.open_in_new),
                onTap: _openMyPage,
              ),
            ),
          if (_selectedMode != ApiMode.mock)
            const SizedBox(height: AppSpacing.md),

          // Offline / data sync section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.offlineMode,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SwitchListTile(
                    title: Text(l10n.offlineMode),
                    subtitle: Text(l10n.offlineModeDescription),
                    value: _offlineMode,
                    onChanged: (v) {
                      setState(() => _offlineMode = v);
                      ref
                          .read(serverConfigNotifierProvider.notifier)
                          .setOfflineMode(enabled: v);
                    },
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Data management',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.cloud_download_outlined),
                        label: Text(l10n.downloadAllData),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.featureNotReady)),
                          );
                        },
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.sync_outlined),
                        label: Text(l10n.sendPendingData),
                        onPressed: () => context.push('/outbox'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── AI autofill (only in REST/production mode) ─────────────────
          if (isProduction) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome_outlined),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          'AI自動入力',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    SwitchListTile(
                      title: const Text('バーコードスキャン時に自動入力'),
                      subtitle: const Text(
                        'JANコード・ISBNを読み取ると商品情報を自動取得してフォームに入力します',
                      ),
                      value: _aiAutofill,
                      onChanged: (v) {
                        setState(() => _aiAutofill = v);
                        ref
                            .read(serverConfigNotifierProvider.notifier)
                            .setAiAutofill(enabled: v);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // ── Feature Flags (hidden in production, debug/QA only) ────────
          if (!isProduction)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          l10n.featureFlags,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        if (kDebugMode)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.amber,
                              borderRadius: AppRadii.smAll,
                            ),
                            child: Text(
                              'DEBUG',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ..._flagOverrides.entries.map(
                      (e) => SwitchListTile(
                        title: Text(_flagLabel(e.key, l10n)),
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

          // ── Logout (hidden in mock mode) ───────────────────────────────
          if (_selectedMode != ApiMode.mock) ...[
            const SizedBox(height: AppSpacing.md),
            Card(
              child: ListTile(
                key: const Key('logout_tile'),
                leading: Icon(
                  Icons.logout,
                  color: Theme.of(context).colorScheme.error,
                ),
                title: Text(
                  l10n.logout,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: _logout,
              ),
            ),
          ],

          // ── Privacy Policy link (always visible) ───────────────────────
          //
          // Required by Google Play (Issue #142) and App Store (Issue #122).
          // Must remain reachable in every API mode, including mock, so QA
          // and reviewers can audit the link without signing in.
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              key: const Key('privacy_policy_tile'),
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(l10n.privacyPolicy),
              subtitle: Text(l10n.privacyPolicySubtitle),
              trailing: const Icon(Icons.open_in_new),
              onTap: _openPrivacyPolicy,
            ),
          ),
        ],
      ),
    );
  }

  String _modeLabel(ApiMode mode, AppLocalizations l10n) => switch (mode) {
    ApiMode.mock => l10n.apiModeMock,
    // ignore: deprecated_member_use_from_same_package
    ApiMode.legacy => l10n.apiModeLegacy,
    ApiMode.rest => l10n.apiModeRest,
  };

  String _modeDescription(ApiMode mode, AppLocalizations l10n) =>
      switch (mode) {
        ApiMode.mock => l10n.apiModeMockDescription,
        // ignore: deprecated_member_use_from_same_package
        ApiMode.legacy => l10n.apiModeLegacyDescription,
        ApiMode.rest => l10n.apiModeRestDescription,
      };

  String _flagLabel(String key, AppLocalizations l10n) => switch (key) {
    FeatureFlags.restApiV1 => l10n.flagRestApi,
    FeatureFlags.pushFcm => l10n.flagPushFcm,
    FeatureFlags.pushSns => l10n.flagPushSns,
    FeatureFlags.authOidc => l10n.flagAuthOidc,
    FeatureFlags.authFirebase => l10n.flagAuthFirebase,
    FeatureFlags.offlineMode => l10n.flagOfflineMode,
    FeatureFlags.barcodeScanner => l10n.flagBarcodeScanner,
    FeatureFlags.labelPrint => l10n.flagLabelPrint,
    _ => key,
  };
}

/// Deprecation banner shown above the mode selector whenever the user is
/// currently in legacy mode. Built as a standalone widget so it can be
/// addressed by tests via [Key] and so the parent build method stays
/// flat. See PR-B2 + the migration timeline in
/// `docs/auth-migration.md` (added in PR-B3 once `/api/v1/auth/login`
/// ships server-side).
class _LegacyDeprecationBanner extends StatelessWidget {
  const _LegacyDeprecationBanner(this.l10n);

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        key: const Key('legacy_deprecation_banner'),
        color: scheme.errorContainer,
        margin: EdgeInsets.zero,
        child: ListTile(
          leading: Icon(
            Icons.warning_amber_outlined,
            color: scheme.onErrorContainer,
          ),
          title: Text(
            l10n.apiModeLegacyDeprecationNotice,
            style: TextStyle(
              color: scheme.onErrorContainer,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
