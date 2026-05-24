import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Whether the host should render a Cupertino-style dialog. Web (including
/// iOS Safari) always falls back to Material — Cupertino widgets depend on
/// `dart:io` Platform checks which throw on web.
bool _isCupertinoHost() => !kIsWeb && Platform.isIOS;

// ---------------------------------------------------------------------------
// Declarative API (value-based).
// ---------------------------------------------------------------------------

/// Describes a single action button rendered inside [showSasoAdaptiveDialog].
/// The same description is rendered as a [CupertinoDialogAction] on iOS and
/// as a Material [TextButton] / [FilledButton] on Android / Web.
///
/// Use [AdaptiveDialogAction.primary] for the affirmative default action
/// (e.g. "OK", "Continue"), and [AdaptiveDialogAction.destructive] for
/// dangerous actions (e.g. "Logout", "Delete"). Both helpers map to the
/// platform-native emphasis: Cupertino bolds the default action and
/// renders destructive actions in red, while Material renders the primary
/// action as a [FilledButton] and destructive actions with error-colour
/// text.
@immutable
class AdaptiveDialogAction<T> {
  /// Generic action — non-default, non-destructive (e.g. "Cancel").
  const AdaptiveDialogAction({required this.label, this.value, this.icon})
    : isDefault = false,
      isDestructive = false;

  /// Affirmative / default action. Bolded on iOS, rendered as a
  /// [FilledButton] on Material.
  const AdaptiveDialogAction.primary({
    required this.label,
    this.value,
    this.icon,
  }) : isDefault = true,
       isDestructive = false;

  /// Destructive action. Rendered in error colour on both platforms.
  const AdaptiveDialogAction.destructive({
    required this.label,
    this.value,
    this.icon,
  }) : isDefault = false,
       isDestructive = true;

  /// Button label.
  final String label;

  /// Value returned via [Navigator.pop] when the user taps this action.
  /// `null` is a valid value (Navigator returns `null` by default).
  final T? value;

  /// Optional icon. Only rendered on Material — iOS HIG discourages icons
  /// inside alert dialog actions, so this is silently ignored on iOS.
  final IconData? icon;

  /// Whether this action is the affirmative default. iOS bolds the label.
  final bool isDefault;

  /// Whether this action is destructive. iOS renders red, Material uses
  /// the theme's error colour.
  final bool isDestructive;
}

/// Shows a platform-adaptive alert dialog with a static set of actions.
///
/// On iOS (non-web) renders a [CupertinoAlertDialog]; on Android, Web and
/// other platforms renders a Material [AlertDialog]. Named with the `Saso`
/// prefix to avoid collision with Flutter's built-in `showAdaptiveDialog`
/// in `package:flutter/material.dart`, which doesn't support our
/// declarative action list.
///
/// Use this variant when each action returns a fixed value. For dialogs
/// whose action result depends on dialog-local state (e.g. an input
/// `TextField` controller's text at tap time), use
/// [showSasoAdaptiveDialogBuilder].
///
/// `icon` is rendered above the title on both platforms — matching the
/// QR-pairing success dialog pattern in `qr_pairing_page.dart`.
Future<T?> showSasoAdaptiveDialog<T>({
  required BuildContext context,
  required String title,
  String? message,
  Widget? content,
  Widget? icon,
  List<AdaptiveDialogAction<T>> actions = const [],
  bool barrierDismissible = true,
}) {
  assert(
    message != null || content != null,
    'showSasoAdaptiveDialog requires either a message or a content widget.',
  );

  if (_isCupertinoHost()) {
    return showCupertinoDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: _cupertinoTitle(title: title, icon: icon),
        content: content ?? (message != null ? Text(message) : null),
        actions: actions
            .map(
              (a) => CupertinoDialogAction(
                isDefaultAction: a.isDefault,
                isDestructiveAction: a.isDestructive,
                onPressed: () => Navigator.of(dialogCtx).pop(a.value),
                child: Text(a.label),
              ),
            )
            .toList(),
      ),
    );
  }

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogCtx) => AlertDialog(
      icon: icon,
      title: Text(title),
      content: content ?? (message != null ? Text(message) : null),
      actions: actions.map((a) => _materialActionFor<T>(dialogCtx, a)).toList(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Imperative builder API.
// ---------------------------------------------------------------------------

/// An action whose tap handler is provided directly. Use this with
/// [showSasoAdaptiveDialogBuilder] when the action's behaviour depends on
/// dialog-local state (e.g. reading a [TextEditingController].text at tap
/// time).
@immutable
class AdaptiveDialogActionBuilder<T> {
  const AdaptiveDialogActionBuilder({
    required this.label,
    required this.onPressed,
  }) : isDefault = false,
       isDestructive = false;

  const AdaptiveDialogActionBuilder.primary({
    required this.label,
    required this.onPressed,
  }) : isDefault = true,
       isDestructive = false;

  const AdaptiveDialogActionBuilder.destructive({
    required this.label,
    required this.onPressed,
  }) : isDefault = false,
       isDestructive = true;

  final String label;
  final VoidCallback onPressed;
  final bool isDefault;
  final bool isDestructive;
}

/// Shows a platform-adaptive alert dialog whose content and actions are
/// built from the dialog's [BuildContext] so callers can wire `Navigator.pop`
/// directly and read live widget state at tap time.
Future<T?> showSasoAdaptiveDialogBuilder<T>({
  required BuildContext context,
  required String title,
  WidgetBuilder? contentBuilder,
  Widget? icon,
  required List<AdaptiveDialogActionBuilder<T>> Function(BuildContext)
  actionsBuilder,
  bool barrierDismissible = true,
}) {
  if (_isCupertinoHost()) {
    return showCupertinoDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (dialogCtx) => CupertinoAlertDialog(
        title: _cupertinoTitle(title: title, icon: icon),
        content: contentBuilder?.call(dialogCtx),
        actions: actionsBuilder(dialogCtx)
            .map(
              (a) => CupertinoDialogAction(
                isDefaultAction: a.isDefault,
                isDestructiveAction: a.isDestructive,
                onPressed: a.onPressed,
                child: Text(a.label),
              ),
            )
            .toList(),
      ),
    );
  }

  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (dialogCtx) => AlertDialog(
      icon: icon,
      title: Text(title),
      content: contentBuilder?.call(dialogCtx),
      actions: actionsBuilder(
        dialogCtx,
      ).map((a) => _materialBuilderActionFor<T>(dialogCtx, a)).toList(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Shared widget helpers.
// ---------------------------------------------------------------------------

Widget _cupertinoTitle({required String title, Widget? icon}) {
  if (icon == null) return Text(title);
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [icon, const SizedBox(height: 8), Text(title)],
  );
}

Widget _materialActionFor<T>(
  BuildContext context,
  AdaptiveDialogAction<T> action,
) {
  void onPressed() => Navigator.of(context).pop(action.value);
  return _materialButton(
    context,
    label: action.label,
    icon: action.icon,
    isDefault: action.isDefault,
    isDestructive: action.isDestructive,
    onPressed: onPressed,
  );
}

Widget _materialBuilderActionFor<T>(
  BuildContext context,
  AdaptiveDialogActionBuilder<T> action,
) {
  return _materialButton(
    context,
    label: action.label,
    icon: null,
    isDefault: action.isDefault,
    isDestructive: action.isDestructive,
    onPressed: action.onPressed,
  );
}

Widget _materialButton(
  BuildContext context, {
  required String label,
  required IconData? icon,
  required bool isDefault,
  required bool isDestructive,
  required VoidCallback onPressed,
}) {
  final text = Text(label);

  if (isDestructive) {
    final errorColor = Theme.of(context).colorScheme.error;
    if (isDefault) {
      return icon != null
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: text,
              style: FilledButton.styleFrom(backgroundColor: errorColor),
            )
          : FilledButton(
              onPressed: onPressed,
              style: FilledButton.styleFrom(backgroundColor: errorColor),
              child: text,
            );
    }
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(foregroundColor: errorColor),
      child: text,
    );
  }

  if (isDefault) {
    return icon != null
        ? FilledButton.icon(onPressed: onPressed, icon: Icon(icon), label: text)
        : FilledButton(onPressed: onPressed, child: text);
  }

  return TextButton(onPressed: onPressed, child: text);
}
