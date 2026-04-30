import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/storage/database_helper.dart';
import '../../data/datasources/local/pending_adjustment_dao.dart';
import '../../data/datasources/local/pending_registration_dao.dart';

part 'outbox_provider.g.dart';

/// Total count of pending/failed outbox items (registrations + adjustments).
@riverpod
Future<int> pendingCount(Ref ref) async {
  final db = await ref.watch(databaseHelperProvider.future);
  final regDao = PendingRegistrationDao(db.db);
  final adjDao = PendingAdjustmentDao(db.db);
  return (await regDao.getPending()).length +
      (await adjDao.getPending()).length;
}
