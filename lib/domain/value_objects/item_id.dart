import 'package:flutter/foundation.dart';

/// 8-digit item ID in YYMMNNNN format.
/// YY = last 2 digits of year, MM = month (01–12), NNNN = sequence.
@immutable
final class ItemId {
  const ItemId._(this.value);

  final String value;

  factory ItemId.parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.length != 8 || !RegExp(r'^\d{8}$').hasMatch(trimmed)) {
      throw ArgumentError('ItemId must be exactly 8 digits, got: "$raw"');
    }
    final month = int.parse(trimmed.substring(2, 4));
    if (month < 1 || month > 12) {
      throw ArgumentError(
        'ItemId month must be 01–12, got: ${trimmed.substring(2, 4)}',
      );
    }
    return ItemId._(trimmed);
  }

  static ItemId? tryParse(String raw) {
    try {
      return ItemId.parse(raw);
    } on ArgumentError {
      return null;
    }
  }

  static bool isValid(String raw) => tryParse(raw) != null;

  int get registrationYear => 2000 + int.parse(value.substring(0, 2));
  int get registrationMonth => int.parse(value.substring(2, 4));
  String get sequenceNumber => value.substring(4);

  @override
  bool operator ==(Object other) => other is ItemId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
