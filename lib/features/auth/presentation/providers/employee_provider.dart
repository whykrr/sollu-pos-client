import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/employee_repository.dart';
import '../../providers/auth_provider.dart'; // import to get dioClientProvider

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final database = ref.watch(databaseProvider);
  return EmployeeRepository(dioClient, database);
});

final employeeListProvider = FutureProvider((ref) async {
  final repository = ref.watch(employeeRepositoryProvider);
  return await repository.getEmployees();
});
