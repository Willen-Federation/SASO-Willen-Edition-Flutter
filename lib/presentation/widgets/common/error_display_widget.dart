import 'package:flutter/material.dart';

import '../../../core/theme/app_icon_size.dart';
import '../../../core/theme/app_spacing.dart';

class ErrorDisplayWidget extends StatelessWidget {
  const ErrorDisplayWidget({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
<<<<<<< HEAD
          const Icon(
            Icons.error_outline,
            size: AppIconSize.xxLarge,
            color: Colors.red,
          ),
          const SizedBox(height: AppSpacing.md),
=======
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
>>>>>>> b0ef396 (feat(theme): migrate hardcoded colors to ColorTokens / ColorScheme (Android compliance))
          Text(
            error.toString(),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('再試行'),
            ),
          ],
        ],
      ),
    ),
  );
}
