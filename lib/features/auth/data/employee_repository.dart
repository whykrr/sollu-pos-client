import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/database/app_database.dart';

class EmployeeRepository {
  final DioClient _dioClient;
  final AppDatabase _database;

  EmployeeRepository(this._dioClient, this._database);

  Future<void> syncEmployees() async {
    try {
      final response = await _dioClient.dio.get('/employees');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        
        await _database.transaction(() async {
          // Clear old employees
          await _database.delete(_database.employees).go();
          
          // Insert new employees
          for (final item in data) {
            await _database.into(_database.employees).insert(
              EmployeesCompanion.insert(
                id: item['id'],
                name: item['name'],
                email: Value(item['email']),
                pin: Value(item['pin']),
                photo: Value(item['photo']),
                role: Value(item['role']),
              ),
            );
          }
        });
      }
    } on DioException catch (e) {
      throw Exception('Failed to fetch employees: ${e.response?.data['message'] ?? e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  Future<List<Employee>> getEmployees() async {
    return await _database.select(_database.employees).get();
  }
}
