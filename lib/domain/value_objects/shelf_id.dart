import 'package:flutter/foundation.dart';

/// Shelf ID: uppercase alphanumeric with hyphens, 1–15 characters.
@immutable
final class ShelfId {
  const ShelfId._(this.value);

  final String value;

  factory ShelfId.parse(String raw) {
    final upper = raw.trim().toUpperCase();
    if (upper.isEmpty || upper.length > 15) {
      throw ArgumentError('ShelfId must be 1–15 characters, got: "$raw"');
    }
    if (!RegExp(r'^[A-Z0-9\-]+$').hasMatch(upper)) {
      throw ArgumentError(
        'ShelfId must contain only alphanumeric characters and hyphens, got: "$raw"',
      );
    }
    return ShelfId._(upper);
  }

  static ShelfId? tryParse(String raw) {
    try {
      return ShelfId.parse(raw);
    } on ArgumentError {
      return null;
    }
  }

  static bool isValid(String raw) => tryParse(raw) != null;

  @override
  bool operator ==(Object other) => other is ShelfId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
