import 'package:flutter/material.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';
import 'package:sollu_pos_app/core/services/secure_storage_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_app/features/auth/presentation/providers/employee_provider.dart';
import 'package:sollu_pos_app/features/settings/presentation/providers/sync_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SolluColors.background,
      appBar: AppBar(
        title: const Text(
          'Pengaturan Aplikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: SolluColors.surface,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Pengaturan Umumu & Perangkat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: SolluColors.textDark,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SolluColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.print, color: SolluColors.primary),
                ),
                title: const Text(
                  'Pengaturan Printer',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Kelola koneksi printer Bluetooth & Thermal'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SolluColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store, color: SolluColors.secondary),
                ),
                title: const Text(
                  'Profil Toko & Struk',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Ubah nama outlet, header, dan footer struk'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.security, color: Colors.orange),
                ),
                title: const Text(
                  'Keamanan & Akses PIN',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {},
              ),
              const Divider(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info_outline, color: Colors.blue),
                ),
                title: const Text(
                  'Info Perangkat & Token',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Lihat token Sanctum, Device UUID, & Hardware Signature'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDeviceInfoDialog(context),
              ),
              const Divider(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.sync, color: Colors.green),
                ),
                title: const Text(
                  'Sinkronisasi Data',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Tarik data master terbaru dari server'),
                trailing: _isSyncing 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right),
                onTap: _isSyncing ? null : _syncData,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _syncData() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      // Sinkronisasi data karyawan
      final employeeRepository = ref.read(employeeRepositoryProvider);
      await employeeRepository.syncEmployees();
      
      // Sinkronisasi data master (Produk, Inventory, dll)
      final syncRepository = ref.read(syncRepositoryProvider);
      await syncRepository.syncMasterData();
      
      // Refresh state yang diperlukan
      ref.invalidate(employeeListProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sinkronisasi data master & karyawan berhasil'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal sinkronisasi data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  void _showDeviceInfoDialog(BuildContext context) async {
    final storage = SecureStorageService();
    final token = await storage.getToken();
    final uuid = await storage.getDeviceUuid();
    final signature = await storage.getHardwareSignature();

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Detail Perangkat & Token',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoItem('Bearer Token (Sanctum)', token ?? 'Belum ada token'),
              const SizedBox(height: 12),
              _buildInfoItem('Device UUID', uuid ?? 'Belum tergenerasi'),
              const SizedBox(height: 12),
              _buildInfoItem('Hardware Signature (SHA-256)', signature ?? 'Belum tergenerasi'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: SelectableText(
            value,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ],
    );
  }
}
