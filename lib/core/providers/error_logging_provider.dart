import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/services/error_logging_service.dart';
import 'package:sollu_pos_client/features/auth/providers/auth_provider.dart';

final errorLoggingServiceProvider = Provider<ErrorLoggingService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ErrorLoggingService(dioClient);
});
