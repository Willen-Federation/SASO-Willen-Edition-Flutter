import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saso_willen_edition/l10n/app_localizations.dart';

import '../../../core/errors/problem_details.dart';
import '../../../core/theme/app_spacing.dart';

/// MaterialBanner that surfaces a `SASO-MOBILE-2008` scope-insufficient
/// failure with a clear pictogram, the missing scope, and a CTA that
/// routes to the settings page (where the "manage paired devices on web"
/// tile lives).
///
/// Pass the parsed [problem] directly — the banner is responsible for
/// pulling the required scope out of the detail string or showing a
/// generic message if it's not present.
class ScopeDeniedBanner extends StatelessWidget {
  const ScopeDeniedBanner({super.key, required this.problem});

  final ProblemDetails problem;

  /// Convenience for showing this banner from anywhere with a [BuildContext].
  /// Replaces any banner that is already on screen.
  static void show(BuildContext context, ProblemDetails problem) {
    if (!problem.isScopeInsufficient) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearMaterialBanners();
    messenger.showMaterialBanner(
      MaterialBanner(
        leading: const Icon(Icons.lock_outline, color: Colors.amber),
        backgroundColor: Colors.amber.shade50,
        content: ScopeDeniedBanner(problem: problem),
        actions: [
          TextButton(
            onPressed: () {
              messenger.hideCurrentMaterialBanner();
              context.push('/settings');
            },
            child: Text(AppLocalizations.of(context)!.scopeInsufficientCta),
          ),
          TextButton(
            onPressed: messenger.hideCurrentMaterialBanner,
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scope = _extractScope(problem.detail) ?? '?';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.scopeInsufficientTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(l10n.scopeInsufficientDetail(scope)),
      ],
    );
  }

  /// The backend's RFC 7807 `detail` reads like:
  ///
  ///     This endpoint requires the "items:write" scope.
  ///
  /// We pull the scope out of the quoted segment so the localized message
  /// can mention it specifically.
  static String? _extractScope(String? detail) {
    if (detail == null) return null;
    final match = RegExp(r'"([^"]+)"').firstMatch(detail);
    return match?.group(1);
  }
}
