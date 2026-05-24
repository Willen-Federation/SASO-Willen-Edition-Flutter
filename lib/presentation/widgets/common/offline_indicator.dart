import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:saso_willen_edition/l10n/app_localizations.dart';

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
    return Semantics(
      label: l10n.offlineBadge,
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade700),
        ),
        child: ExcludeSemantics(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.cloud_off, size: 16, color: Colors.orange.shade900),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  l10n.offlineBadge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.orange.shade900,
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
