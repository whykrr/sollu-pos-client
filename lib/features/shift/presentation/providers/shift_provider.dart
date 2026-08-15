import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/shift_repository.dart';

final shiftRepositoryProvider = Provider<ShiftRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final database = ref.watch(databaseProvider);
  return ShiftRepository(dioClient, database);
});

/// StreamProvider untuk memantau shift aktif di UI secara live
final activeShiftProvider = StreamProvider<Shift?>((ref) {
  final repository = ref.watch(shiftRepositoryProvider);
  return repository.watchActiveShift();
});

/// Provider ringkasan finansial shift
final shiftSummaryProvider = FutureProvider.family<ShiftSummary, String>((ref, shiftId) async {
  final repository = ref.watch(shiftRepositoryProvider);
  return await repository.calculateShiftSummary(shiftId);
});
