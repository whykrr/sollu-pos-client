import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sollu_pos_client/core/models/printer_model.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/features/settings/presentation/providers/printer_provider.dart';

class PrinterSettingsScreen extends ConsumerStatefulWidget {
  const PrinterSettingsScreen({super.key});

  @override
  ConsumerState<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends ConsumerState<PrinterSettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isTesting = false;

  // Controllers for Network Printer Form
  final TextEditingController _netNameController =
      TextEditingController(text: 'Printer Kasir LAN');
  final TextEditingController _netIpController =
      TextEditingController(text: '192.168.1.200');
  final TextEditingController _netPortController =
      TextEditingController(text: '9100');
  PrinterPaperSize _netPaperSize = PrinterPaperSize.mm80;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _netNameController.dispose();
    _netIpController.dispose();
    _netPortController.dispose();
    super.dispose();
  }

  Future<void> _handleTestPrint(PrinterConfig config) async {
    setState(() => _isTesting = true);
    final service = ref.read(printerServiceProvider);
    
    final result = await service.printTest(config);

    if (mounted) {
      setState(() => _isTesting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                result.success ? Icons.check_circle : Icons.error_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(result.message)),
            ],
          ),
          backgroundColor: result.success ? SolluColors.success : SolluColors.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedPrinter = ref.watch(selectedPrinterProvider);
    final availablePrintersAsync = ref.watch(availablePrintersProvider);
    final isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    return Scaffold(
      backgroundColor: SolluColors.background,
      appBar: AppBar(
        title: const Text(
          'Pengaturan Printer',
          style: TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textDark),
        ),
        backgroundColor: SolluColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: SolluColors.textDark),
        actions: [
          IconButton(
            tooltip: 'Segarkan Perangkat',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(availablePrintersProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Kartu Status Printer Utama
          _buildActivePrinterCard(selectedPrinter),

          const SizedBox(height: 24),

          // 2. Pengaturan Format Kertas & Struk
          if (selectedPrinter != null) ...[
            _buildPrinterPreferencesCard(selectedPrinter),
            const SizedBox(height: 24),
          ],

          // 3. Tab Pilihan: Perangkat Terpasang vs Printer Jaringan (LAN)
          Container(
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih & Tambah Printer',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: SolluColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isDesktop
                            ? 'Pilih printer USB/Driver yang terpasang di komputer atau hubungkan lewat IP Jaringan (LAN).'
                            : 'Pilih printer Bluetooth yang terpasang di HP/Tablet atau hubungkan lewat IP Jaringan (LAN).',
                        style: const TextStyle(fontSize: 12, color: SolluColors.textMuted),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: SolluColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: SolluColors.neutral),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: SolluColors.primary,
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.white,
                          unselectedLabelColor: SolluColors.textDark,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          dividerColor: Colors.transparent,
                          tabs: [
                            Tab(
                              iconMargin: EdgeInsets.zero,
                              text: isDesktop ? 'Printer OS / USB' : 'Printer Bluetooth',
                            ),
                            const Tab(
                              iconMargin: EdgeInsets.zero,
                              text: 'Printer Jaringan (LAN IP)',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 380,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Tab 1: Local / OS Printers (USB / Bluetooth)
                      _buildLocalPrintersTab(availablePrintersAsync, selectedPrinter, isDesktop),

                      // Tab 2: Network / LAN IP Printer Form
                      _buildNetworkPrinterTab(selectedPrinter),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePrinterCard(PrinterConfig? selected) {
    final hasPrinter = selected != null;

    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: hasPrinter
                          ? SolluColors.success.withValues(alpha: 0.1)
                          : SolluColors.textMuted.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.print,
                      color: hasPrinter ? SolluColors.success : SolluColors.textMuted,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Printer Aktif Saat Ini',
                        style: TextStyle(
                          fontSize: 13,
                          color: SolluColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hasPrinter ? selected.name : 'Belum Ada Printer Dipilih',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: SolluColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (hasPrinter)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: SolluColors.secondary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selected.connectionType.label,
                        style: const TextStyle(
                          color: SolluColors.secondaryDark,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: SolluColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        selected.paperSize.label.split(' ').first,
                        style: const TextStyle(
                          color: SolluColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (hasPrinter) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  selected.connectionType == PrinterConnectionType.bluetooth
                      ? Icons.bluetooth
                      : (selected.connectionType == PrinterConnectionType.network ? Icons.lan : Icons.usb),
                  size: 16,
                  color: SolluColors.textMuted,
                ),
                const SizedBox(width: 6),
                Text(
                  selected.connectionType == PrinterConnectionType.network
                      ? 'IP: ${selected.ipAddress ?? selected.address}:${selected.port}'
                      : 'Target / Alamat: ${selected.address}',
                  style: const TextStyle(fontSize: 13, color: SolluColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isTesting ? null : () => _handleTestPrint(selected),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: SolluColors.primary,
                      side: const BorderSide(color: SolluColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: _isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.receipt_long, size: 18),
                    label: Text(_isTesting ? 'Mencetak...' : 'Uji Cetak (Test Print)'),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: 'Hapus Printer',
                  style: IconButton.styleFrom(
                    backgroundColor: SolluColors.danger.withValues(alpha: 0.1),
                    foregroundColor: SolluColors.danger,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    ref.read(selectedPrinterProvider.notifier).removePrinter();
                  },
                ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 12),
            const Text(
              'Silakan pilih printer di bawah untuk digunakan saat mencetak struk transaksi kasir.',
              style: TextStyle(fontSize: 13, color: SolluColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrinterPreferencesCard(PrinterConfig selected) {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Konfigurasi Kertas & Struk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: SolluColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Ukuran Kertas Thermal',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SolluColors.textDark),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildPaperOption(
                  title: '58 mm',
                  subtitle: 'Standar Mobile (32 Chars)',
                  isSelected: selected.paperSize == PrinterPaperSize.mm58,
                  onTap: () {
                    ref.read(selectedPrinterProvider.notifier).updatePaperSize(PrinterPaperSize.mm58);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPaperOption(
                  title: '80 mm',
                  subtitle: 'Standar Desktop (48 Chars)',
                  isSelected: selected.paperSize == PrinterPaperSize.mm80,
                  onTap: () {
                    ref.read(selectedPrinterProvider.notifier).updatePaperSize(PrinterPaperSize.mm80);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Potong Kertas Otomatis (Auto-Cut)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Kirim perintah pemotong kertas jika didukung printer', style: TextStyle(fontSize: 12, color: SolluColors.textMuted)),
            value: selected.autoCut,
            activeTrackColor: SolluColors.primary,
            onChanged: (val) {
              ref.read(selectedPrinterProvider.notifier).updateAutoCut(val);
            },
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Buka Laci Kasir (Cash Drawer)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: const Text('Buka laci kasir otomatis saat mencetak struk', style: TextStyle(fontSize: 12, color: SolluColors.textMuted)),
            value: selected.openCashDrawer,
            activeTrackColor: SolluColors.primary,
            onChanged: (val) {
              ref.read(selectedPrinterProvider.notifier).updateCashDrawer(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaperOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? SolluColors.primary.withValues(alpha: 0.05) : SolluColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? SolluColors.primary : SolluColors.neutral,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: isSelected ? SolluColors.primary : SolluColors.textDark,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, size: 18, color: SolluColors.primary)
                else
                  const Icon(Icons.radio_button_unchecked, size: 18, color: SolluColors.textMuted),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: SolluColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalPrintersTab(
    AsyncValue<List<DiscoveredPrinterInfo>> availablePrintersAsync,
    PrinterConfig? selected,
    bool isDesktop,
  ) {
    return availablePrintersAsync.when(
      data: (devices) {
        if (devices.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isDesktop ? Icons.print_disabled : Icons.bluetooth_searching,
                    size: 44,
                    color: SolluColors.textMuted.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isDesktop ? 'Tidak ada printer OS ditemukan' : 'Tidak ada perangkat Bluetooth ditemukan',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: SolluColors.textDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isDesktop
                        ? 'Pastikan driver printer sudah terpasang di Windows/macOS.'
                        : 'Pastikan Bluetooth aktif & printer sudah di-Pairing di menu Pengaturan HP/Tablet.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: SolluColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(availablePrintersProvider.notifier).refresh();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SolluColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Segarkan'),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: devices.length,
          separatorBuilder: (context, index) => const Divider(height: 16),
          itemBuilder: (context, index) {
            final dev = devices[index];
            final isCurrentSelected = selected?.address == dev.address;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isCurrentSelected
                      ? SolluColors.primary.withValues(alpha: 0.1)
                      : SolluColors.background,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  dev.connectionType == PrinterConnectionType.bluetooth
                      ? Icons.bluetooth
                      : Icons.print,
                  color: isCurrentSelected ? SolluColors.primary : SolluColors.textMuted,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      dev.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isCurrentSelected ? SolluColors.primary : SolluColors.textDark,
                      ),
                    ),
                  ),
                  if (dev.isDefault)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Default OS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.brown)),
                    ),
                ],
              ),
              subtitle: Text(
                dev.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: SolluColors.textMuted),
              ),
              trailing: isCurrentSelected
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: SolluColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, size: 14, color: SolluColors.success),
                          SizedBox(width: 4),
                          Text(
                            'Terpilih',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: SolluColors.success,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        final newConfig = PrinterConfig(
                          name: dev.name,
                          address: dev.address,
                          connectionType: dev.connectionType,
                          paperSize: selected?.paperSize ?? (isDesktop ? PrinterPaperSize.mm80 : PrinterPaperSize.mm58),
                          autoCut: selected?.autoCut ?? false,
                          openCashDrawer: selected?.openCashDrawer ?? false,
                        );
                        ref.read(selectedPrinterProvider.notifier).savePrinter(newConfig);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Printer ${dev.name} berhasil dipilih!'),
                            backgroundColor: SolluColors.success,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SolluColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Pilih'),
                    ),
            );
          },
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, _) => Center(
        child: Text('Gagal memuat perangkat: $err', style: const TextStyle(color: SolluColors.danger)),
      ),
    );
  }

  Widget _buildNetworkPrinterTab(PrinterConfig? selected) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _netNameController,
            decoration: InputDecoration(
              labelText: 'Nama Printer',
              hintText: 'Contoh: Printer Kasir LAN / Printer Dapur',
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _netIpController,
                  keyboardType: TextInputType.url,
                  decoration: InputDecoration(
                    labelText: 'IP Address Printer',
                    hintText: '192.168.1.200',
                    prefixIcon: const Icon(Icons.lan_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _netPortController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Port',
                    hintText: '9100',
                    prefixIcon: const Icon(Icons.numbers),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('Ukuran Kertas: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('58 mm'),
                selected: _netPaperSize == PrinterPaperSize.mm58,
                onSelected: (val) {
                  if (val) setState(() => _netPaperSize = PrinterPaperSize.mm58);
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('80 mm'),
                selected: _netPaperSize == PrinterPaperSize.mm80,
                onSelected: (val) {
                  if (val) setState(() => _netPaperSize = PrinterPaperSize.mm80);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final ip = _netIpController.text.trim();
                    final port = int.tryParse(_netPortController.text.trim()) ?? 9100;
                    if (ip.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('IP Address wajib diisi!'), backgroundColor: SolluColors.danger),
                      );
                      return;
                    }
                    final tempConfig = PrinterConfig(
                      name: _netNameController.text.trim().isNotEmpty ? _netNameController.text.trim() : 'Network Printer',
                      address: '$ip:$port',
                      ipAddress: ip,
                      port: port,
                      connectionType: PrinterConnectionType.network,
                      paperSize: _netPaperSize,
                    );
                    _handleTestPrint(tempConfig);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SolluColors.primary,
                    side: const BorderSide(color: SolluColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.wifi_tethering, size: 18),
                  label: const Text('Uji Koneksi (Test)'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    final ip = _netIpController.text.trim();
                    final port = int.tryParse(_netPortController.text.trim()) ?? 9100;
                    if (ip.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('IP Address wajib diisi!'), backgroundColor: SolluColors.danger),
                      );
                      return;
                    }
                    final config = PrinterConfig(
                      name: _netNameController.text.trim().isNotEmpty ? _netNameController.text.trim() : 'Network Printer',
                      address: '$ip:$port',
                      ipAddress: ip,
                      port: port,
                      connectionType: PrinterConnectionType.network,
                      paperSize: _netPaperSize,
                      autoCut: selected?.autoCut ?? false,
                      openCashDrawer: selected?.openCashDrawer ?? false,
                    );
                    ref.read(selectedPrinterProvider.notifier).savePrinter(config);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Printer Jaringan ($ip:$port) berhasil disimpan!'),
                        backgroundColor: SolluColors.success,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SolluColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Simpan Printer'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
