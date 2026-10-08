import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shift/presentation/providers/shift_provider.dart';

class BootstrapResult {
  final bool isOnline;
  final bool hasActiveShift;
  final String? errorMessage;

  BootstrapResult({
    required this.isOnline,
    required this.hasActiveShift,
    this.errorMessage,
  });
}

final bootstrapProvider = FutureProvider<BootstrapResult>((ref) async {
  bool isOnline = true;
  String? errorMessage;

  // Sinkronisasi otomatis sudah dipindah ke autoSyncProvider (rule 6 jam)
  // Data karyawan sudah didapatkan dari endpoint initial master data (/sync/master)

  // Cek Status Shift Aktif di SQLite Lokal
  final shiftRepository = ref.read(shiftRepositoryProvider);
  final activeShift = await shiftRepository.getActiveShift();

  return BootstrapResult(
    isOnline: isOnline,
    hasActiveShift: activeShift != null,
    errorMessage: errorMessage,
  );
});
