import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';

/// Provider global untuk instance database utama.
/// Penggunaan: ref.read(databaseProvider) atau ref.watch(databaseProvider)
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  
  // Memastikan database ditutup saat provider didispose (misal aplikasi ditutup)
  ref.onDispose(() {
    db.close();
  });
  
  return db;
});
