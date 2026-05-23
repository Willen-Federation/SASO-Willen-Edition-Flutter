import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:saso_willen_edition/l10n/app_localizations.dart';

import '../../../core/theme/app_colors.dart';

/// Small badge that shows when the device has no network connectivity.
///
/// Subscribes to [Connectivity.onConnectivityChanged] so the badge appears
/// the instant Wi-Fi/cellular drops and disappears as soon as it returns.
/// Drop it into an [AppBar.actions] list (or any Row) to give the user a
/// stable, always-on indicator instead of relying on one-shot snackbars.
class OfflineIndicator extends StatefulWidget {
  const OfflineIndicator({super.key});

  @override
  State<OfflineIndicator> createState() => _OfflineIndicatorState();
}

class _OfflineIndicatorState extends State<OfflineIndicator> {
  final _connectivity = Connectivity();
  bool _offline = false;

  @override
  void initState() {
    super.initState();
    _connectivity.checkConnectivity().then(_apply);
    _connectivity.onConnectivityChanged.listen(_apply);
  }

  void _apply(List<ConnectivityResult> results) {
    final hasNet = results.any(
      (r) => r != ConnectivityResult.none && r != ConnectivityResult.bluetooth,
    );
    if (!mounted) return;
    setState(() => _offline = !hasNet);
  }

  @override
  Widget build(BuildContext context) {
    if (!_offline) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context)!;
<<<<<<< HEAD
    // WCAG 2.1 AA: use ColorScheme.errorContainer / onErrorContainer so the
    // badge keeps a ≥4.5:1 contrast ratio in both light and dark themes.
    // Previously hardcoded `Colors.orange.shade*` rendered the dark-mode
    // AppBar with a near-invisible orange-on-orange combination.
    final scheme = Theme.of(context).colorScheme;
=======
    final tokens = context.semanticColors;
>>>>>>> b0ef396 (feat(theme): migrate hardcoded colors to ColorTokens / ColorScheme (Android compliance))
    return Semantics(
      label: l10n.offlineBadge,
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
<<<<<<< HEAD
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: scheme.error),
=======
          color: tokens.warningContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: tokens.warning),
>>>>>>> b0ef396 (feat(theme): migrate hardcoded colors to ColorTokens / ColorScheme (Android compliance))
        ),
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
<<<<<<< HEAD
              Icon(Icons.cloud_off, size: 16, color: scheme.onErrorContainer),
=======
              Icon(
                Icons.cloud_off,
                size: 16,
                color: tokens.onWarningContainer,
              ),
>>>>>>> b0ef396 (feat(theme): migrate hardcoded colors to ColorTokens / ColorScheme (Android compliance))
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  l10n.offlineBadge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
<<<<<<< HEAD
                    color: scheme.onErrorContainer,
=======
                    color: tokens.onWarningContainer,
>>>>>>> b0ef396 (feat(theme): migrate hardcoded colors to ColorTokens / ColorScheme (Android compliance))
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
