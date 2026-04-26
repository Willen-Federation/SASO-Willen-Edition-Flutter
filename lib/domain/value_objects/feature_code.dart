import 'package:flutter/foundation.dart';

/// 12-digit feature code: [8-digit itemId][2-digit color][2-digit size].
@immutable
final class FeatureCode {
  const FeatureCode._(this.value);

  final String value;

  factory FeatureCode.parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.length != 12 || !RegExp(r'^\d{12}$').hasMatch(trimmed)) {
      throw ArgumentError(
        'FeatureCode must be exactly 12 digits, got: "$raw"',
      );
    }
    return FeatureCode._(trimmed);
  }

  static FeatureCode? tryParse(String raw) {
    try {
      return FeatureCode.parse(raw);
    } on ArgumentError {
      return null;
    }
  }

  static bool isValid(String raw) => tryParse(raw) != null;

  String get itemIdPart => value.substring(0, 8);
  String get colorPart => value.substring(8, 10);
  String get sizePart => value.substring(10, 12);

  @override
  bool operator ==(Object other) =>
      other is FeatureCode && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
