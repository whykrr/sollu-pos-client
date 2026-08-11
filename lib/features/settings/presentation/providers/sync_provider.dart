import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../data/sync_repository.dart';

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final database = ref.watch(databaseProvider);
  return SyncRepository(dioClient, database);
});
