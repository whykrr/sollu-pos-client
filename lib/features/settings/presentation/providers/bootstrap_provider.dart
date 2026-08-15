import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/employee_provider.dart';
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

  // 2. Coba Sinkronisasi Karyawan
  try {
    final employeeRepository = ref.read(employeeRepositoryProvider);
    await employeeRepository.syncEmployees();
  } catch (_) {
    isOnline = false;
  }

  // 3. Cek Status Shift Aktif di SQLite Lokal
  final shiftRepository = ref.read(shiftRepositoryProvider);
  final activeShift = await shiftRepository.getActiveShift();

  return BootstrapResult(
    isOnline: isOnline,
    hasActiveShift: activeShift != null,
    errorMessage: errorMessage,
  );
});
