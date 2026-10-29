import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sollu_pos_client/features/auth/presentation/widgets/outlet_inactive_dialog.dart';

void main() {
  testWidgets('OutletInactiveDialog renders informative message and guidance properly', (tester) async {
    const customMessage = 'Cabang outlet ini sedang dinonaktifkan oleh pemilik usaha. Silakan aktifkan cabang pada menu Pengaturan Outlet untuk melanjutkan transaksi kasir.';

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: OutletInactiveDialog(
              message: customMessage,
            ),
          ),
        ),
      ),
    );

    // Verify Title and Subtitle Badges
    expect(find.text('Cabang Dinonaktifkan'), findsOneWidget);
    expect(find.text('Koneksi Kasir Dikunci'), findsOneWidget);

    // Verify Informative Server Message
    expect(find.text(customMessage), findsOneWidget);

    // Verify Step by step guidance
    expect(find.text('Panduan Pengaktifan Kembali:'), findsOneWidget);
    expect(find.text('Buka dashboard web pemilik usaha.'), findsOneWidget);
    expect(find.text('Masuk ke menu Pengaturan > Outlet.'), findsOneWidget);
    expect(find.text('Aktifkan kembali saklar status cabang ini.'), findsOneWidget);
    expect(find.text('Tekan tombol Periksa Status di bawah ini.'), findsOneWidget);

    // Verify Action Buttons
    expect(find.text('Periksa Status'), findsOneWidget);
    expect(find.text('Keluar Sesi'), findsOneWidget);
  });

  testWidgets('OutletInactiveDialog uses fallback message if none provided', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: OutletInactiveDialog(),
          ),
        ),
      ),
    );

    expect(find.text('Cabang Dinonaktifkan'), findsOneWidget);
    expect(
      find.text(
        'Cabang outlet ini sedang dinonaktifkan oleh pemilik usaha. Silakan aktifkan cabang pada menu Pengaturan Outlet untuk melanjutkan transaksi kasir.',
      ),
      findsOneWidget,
    );
  });
}
