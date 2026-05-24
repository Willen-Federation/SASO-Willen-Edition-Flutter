import 'package:flutter/material.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/item_status.dart';
import '../../../l10n/app_localizations.dart';

/// Pill-shaped badge that renders the localized label of an [ItemStatus]
/// using Material 3 `ColorScheme` tones. Dark mode and high-contrast
/// accessibility are picked up automatically because every colour pair is
/// drawn from the theme rather than hard-coded hex values.
class ItemStatusBadge extends StatelessWidget {
  const ItemStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  final ItemStatus status;

  /// When `true`, renders with reduced padding/font for use inside a
  /// `ListTile` trailing slot. Detail screens use the default size.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (fg, bg) = _palette(scheme);
    final baseStyle = compact
        ? theme.textTheme.labelSmall
        : theme.textTheme.labelMedium;
    final label = labelFor(status, context);
    return Semantics(
      label: label,
      container: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.sm : 12,
          vertical: compact ? 2 : AppSpacing.xs,
        ),
        decoration: BoxDecoration(color: bg, borderRadius: AppRadii.lgAll),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: baseStyle?.copyWith(color: fg, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  (Color fg, Color bg) _palette(ColorScheme s) => switch (status) {
    ItemStatus.active => (s.onPrimaryContainer, s.primaryContainer),
    ItemStatus.archived => (s.onSurfaceVariant, s.surfaceContainerHighest),
    ItemStatus.discontinued => (s.onErrorContainer, s.errorContainer),
    ItemStatus.pending => (s.onTertiaryContainer, s.tertiaryContainer),
    ItemStatus.inStorage => (s.onSecondaryContainer, s.secondaryContainer),
    ItemStatus.inUse => (s.onPrimary, s.primary),
    ItemStatus.forSale => (s.onTertiary, s.tertiary),
    ItemStatus.reserved => (s.onError, s.error),
    ItemStatus.shipped => (s.outline, s.surfaceContainerLow),
  };

  /// Resolves the localized label for a status. Exposed as a top-level
  /// helper (not a method) so `BottomSheet` rows and other call sites can
  /// look up labels without instantiating a widget.
  static String labelFor(ItemStatus status, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return switch (status) {
      ItemStatus.active => l10n.itemStatusActive,
      ItemStatus.archived => l10n.itemStatusArchived,
      ItemStatus.discontinued => l10n.itemStatusDiscontinued,
      ItemStatus.pending => l10n.itemStatusPending,
      ItemStatus.inStorage => l10n.itemStatusInStorage,
      ItemStatus.inUse => l10n.itemStatusInUse,
      ItemStatus.forSale => l10n.itemStatusForSale,
      ItemStatus.reserved => l10n.itemStatusReserved,
      ItemStatus.shipped => l10n.itemStatusShipped,
    };
  }
}
