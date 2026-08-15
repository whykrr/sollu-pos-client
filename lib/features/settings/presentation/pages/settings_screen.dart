import 'package:flutter/material.dart';
import 'package:sollu_pos_client/core/config/app_config.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/services/secure_storage_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:sollu_pos_client/features/auth/presentation/providers/employee_provider.dart';
import 'package:sollu_pos_client/features/auth/presentation/widgets/change_pin_dialog.dart';
import 'package:sollu_pos_client/features/auth/presentation/widgets/employee_login_dialog.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/sync_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/printer_provider.dart';
import 'package:sollu_pos_client/features/settings/presentation/widgets/receipt_settings_dialog.dart';
import 'package:sollu_pos_client/core/providers/preferences_provider.dart';

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
              Builder(
                builder: (context) {
                  final printerConfig = ref.watch(selectedPrinterProvider);
                  return ListTile(
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
                    subtitle: Text(
                      printerConfig != null
                          ? '${printerConfig.name} (${printerConfig.paperSize.label.split(' ').first})'
                          : 'Kelola koneksi printer Bluetooth & Thermal',
                      style: TextStyle(
                        color: printerConfig != null ? SolluColors.primary : null,
                        fontWeight: printerConfig != null ? FontWeight.w500 : null,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/settings/printer'),
                  );
                },
              ),
              const Divider(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SolluColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long, color: SolluColors.secondaryDark),
                ),
                title: const Text(
                  'Pengaturan Struk',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Kustomisasi teks header, footer, dan catatan struk'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => ReceiptSettingsDialog.show(context),
              ),
              const Divider(height: 24),
              Builder(
                builder: (context) {
                  final activeEmployee = ref.watch(activeEmployeeProvider);
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.password, color: Colors.orange),
                    ),
                    title: const Text(
                      'Ubah PIN',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      activeEmployee != null
                          ? 'PIN Pengguna: ${activeEmployee['name']} (${activeEmployee['role']})'
                          : 'Masuk untuk mengubah PIN akun Anda',
                      style: TextStyle(
                        color: activeEmployee != null ? SolluColors.primary : null,
                        fontWeight: activeEmployee != null ? FontWeight.w500 : null,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      if (activeEmployee == null) {
                        EmployeeLoginDialog.show(context);
                      } else {
                        ChangePinDialog.show(context);
                      }
                    },
                  );
                },
              ),
              const Divider(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.dashboard_customize, color: Colors.purple),
                ),
                title: const Text(
                  'Mode Tampilan Kasir',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Pilih cara menampilkan produk di layar kasir'),
                trailing: DropdownButton<String>(
                  value: ref.watch(posDisplayModeProvider),
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'product', child: Text('Berbasis Produk')),
                    DropdownMenuItem(value: 'variant', child: Text('Berbasis Varian')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(posDisplayModeProvider.notifier).setMode(val);
                    }
                  },
                ),
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
              const Divider(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.verified, color: Colors.blueGrey),
                ),
                title: const Text(
                  'Versi Aplikasi',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('${AppConfig.appName} • ${AppConfig.fullVersionString} (${AppConfig.appEnv})'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: SolluColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'v${AppConfig.appVersion}',
                    style: const TextStyle(
                      color: SolluColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
