import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sollu_pos_app/core/theme/sollu_colors.dart';
import 'package:sollu_pos_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:sollu_pos_app/features/auth/presentation/widgets/employee_login_dialog.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  void _handleMenuClick(BuildContext context, WidgetRef ref, String route) {
    final activeEmployee = ref.read(activeEmployeeProvider);
    if (activeEmployee == null) {
      // Jika belum login, tampilkan popup login
      EmployeeLoginDialog.show(context);
    } else {
      // Jika sudah login, lanjutkan ke route
      context.push(route);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeEmployee = ref.watch(activeEmployeeProvider);

    return Scaffold(
      backgroundColor: SolluColors.background,
      body: Stack(
          children: [
            Positioned(
              bottom: 80,
              left: 60,
              child: Opacity(
                opacity: 0.15,
                child: Image.asset('img/icon-colored.png', width: 140),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              child: GestureDetector(
                onLongPress: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sistem Pelaporan Masalah (Fitur akan datang)')),
                  );
                },
                child: const Text(
                  'v1.0.0+1',
                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset('img/logo-colored.png', width: 170),
                        activeEmployee == null
                            ? ElevatedButton.icon(
                                onPressed: () => EmployeeLoginDialog.show(context),
                                icon: const Icon(Icons.login),
                                label: const Text('Masuk Karyawan'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: SolluColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: SolluColors.primary,
                                      child: Text(activeEmployee['name'][0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          activeEmployee['name'],
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textDark, fontSize: 14),
                                        ),
                                        Text(
                                          activeEmployee['role'],
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                      IconButton(
                                        icon: const Icon(Icons.logout, color: SolluColors.danger, size: 20),
                                        tooltip: 'Keluar',
                                        onPressed: () {
                                        ref.read(activeEmployeeProvider.notifier).logout();
                                      },
                                    )
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),

                  // Main Content Cards
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _DashboardCard(
                            title: 'Kasir',
                            subtitle: 'Buka menu POS & transaksi tunai',
                            icon: Icons.point_of_sale,
                            color: SolluColors.primary,
                            onTap: () => _handleMenuClick(context, ref, '/pos'),
                          ),
                          const SizedBox(width: 40),
                          _DashboardCard(
                            title: 'Transaksi',
                            subtitle: 'Lihat daftar & riwayat pesanan',
                            icon: Icons.receipt_long,
                            color: SolluColors.secondary,
                            onTap: () => _handleMenuClick(context, ref, '/history'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 280,
            height: 280,
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 64, color: color),
                ),
                const SizedBox(height: 24),
                Text(
                  title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SolluColors.textDark),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: SolluColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
