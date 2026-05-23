import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saso_willen_edition/core/logging/app_logger.dart';

/// Issue #157 — AppLogger smoke tests.
///
/// We cannot directly assert "release builds emit nothing" from a Dart
/// unit test (Flutter's test runner sets `kDebugMode == true`), but we
/// CAN assert:
///   1. Every public surface routes through `debugPrint`, which the
///      Flutter framework already promises is a no-op in release.
///   2. The formatter prefixes each line with the supplied tag, so log
///      streams in debug builds remain greppable.
///   3. Optional error / stack-trace arguments are appended without
///      crashing on null / typed payloads.
///
/// The release-mode "nothing leaks" guarantee is verified manually with
/// `flutter build apk --release && adb logcat` per the PR acceptance
/// criteria (see docs/architecture/logging.md and PR #157).
void main() {
  group('AppLogger', () {
    final lines = <String>[];
    late DebugPrintCallback originalDebugPrint;

    setUp(() {
      lines.clear();
      originalDebugPrint = debugPrint;
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) lines.add(message);
      };
    });

    tearDown(() {
      debugPrint = originalDebugPrint;
    });

    test('debug emits tagged message', () {
      AppLogger.debug('TestTag', 'hello');
      expect(lines, ['[TestTag] hello']);
    });

    test('debug appends optional error payload', () {
      AppLogger.debug('TestTag', 'fetch failed', 'SocketException');
      expect(lines, ['[TestTag] fetch failed — SocketException']);
    });

    test('info emits tagged message', () {
      AppLogger.info('TestTag', 'ready');
      expect(lines, ['[TestTag] ready']);
    });

    test('warn emits WARN-prefixed message', () {
      AppLogger.warn('TestTag', 'fallback fired');
      expect(lines, ['[TestTag] WARN fallback fired']);
    });

    test('warn appends optional error payload', () {
      AppLogger.warn('TestTag', 'timeout', Exception('boom'));
      expect(lines.single, contains('[TestTag] WARN timeout — '));
      expect(lines.single, contains('Exception: boom'));
    });

    test('error always carries an error object', () {
      final err = StateError('bad');
      AppLogger.error('TestTag', 'crash', err);
      expect(lines.single, contains('[TestTag] ERROR crash — '));
      expect(lines.single, contains('Bad state: bad'));
    });

    test('error appends stack trace when provided', () {
      final err = StateError('bad');
      final stack = StackTrace.fromString('#0 at line 1');
      AppLogger.error('TestTag', 'crash', err, stack);
      expect(lines.single, contains('#0 at line 1'));
    });
  });
}
