import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sollu_pos_client/core/theme/sollu_colors.dart';
import 'package:sollu_pos_client/core/theme/sollu_spacing.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/promo_provider.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/transaction_provider.dart';
import 'package:sollu_pos_client/core/utils/currency_input_formatter.dart';
import 'package:sollu_pos_client/features/pos/presentation/providers/cart_provider.dart';

class DiscountDialog extends ConsumerStatefulWidget {
  const DiscountDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const DiscountDialog(),
    );
  }

  @override
  ConsumerState<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends ConsumerState<DiscountDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _manualValController = TextEditingController();
  final TextEditingController _manualNameController = TextEditingController();
  String _manualType = 'percentage'; // 'percentage' or 'fixed'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _manualValController.dispose();
    _manualNameController.dispose();
    super.dispose();
  }

  void _applyManualDiscount() {
    final val = _manualType == 'fixed'
        ? CurrencyInputFormatter.parse(_manualValController.text)
        : (double.tryParse(_manualValController.text.trim().replaceAll(',', '.')) ?? 0.0);
    if (val <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan nilai diskon yang valid'),
          backgroundColor: SolluColors.danger,
        ),
      );
      return;
    }

    final customName = _manualNameController.text.trim().isNotEmpty
        ? _manualNameController.text.trim()
        : (_manualType == 'percentage' ? 'Diskon $val%' : 'Potongan ${CurrencyFormatter.format(val.toInt())}');

    ref.read(appliedDiscountProvider.notifier).applyManualDiscount(
      type: _manualType,
      value: val,
      name: customName,
    );

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Diskon "$customName" berhasil diterapkan!'),
        backgroundColor: SolluColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final promosAsync = ref.watch(activePromosProvider);
    final appliedDiscount = ref.watch(appliedDiscountProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 540,
        height: 520,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: SolluColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.discount_outlined, color: SolluColors.primary, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Promo & Diskon (F4)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: SolluColors.textDark),
                      ),
                      if (appliedDiscount != null)
                        Text(
                          'Aktif: ${appliedDiscount.name}',
                          style: const TextStyle(fontSize: 12, color: SolluColors.success, fontWeight: FontWeight.bold),
                        )
                      else
                        const Text(
                          'Pilih promo master atau atur diskon manual',
                          style: TextStyle(fontSize: 12, color: SolluColors.textMuted),
                        ),
                    ],
                  ),
                ),
                if (appliedDiscount != null)
                  TextButton.icon(
                    onPressed: () {
                      ref.read(appliedDiscountProvider.notifier).clearDiscount();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.delete_outline, size: 16, color: SolluColors.danger),
                    label: const Text('Hapus Promo', style: TextStyle(color: SolluColors.danger, fontSize: 12)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: SolluColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: SolluColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: SolluColors.textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                tabs: const [
                  Tab(text: 'Pilih Promo Master'),
                  Tab(text: 'Diskon Manual'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Promos List from Master Data
                  promosAsync.when(
                    data: (promos) {
                      if (promos.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_offer_outlined, size: 48, color: SolluColors.neutralMuted.withValues(alpha: 0.5)),
                              const SizedBox(height: 12),
                              const Text('Belum ada promo aktif', style: TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textDark)),
                              const SizedBox(height: 4),
                              const Text('Promo master data dapat disinkronkan dari web backoffice.', textAlign: TextAlign.center, style: TextStyle(color: SolluColors.textMuted, fontSize: 12)),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: promos.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final promo = promos[index];
                          final isSelected = appliedDiscount?.promoId == promo.id;

                          final String discountTag = promo.promoType == 'percentage'
                              ? '${promo.discountValue.toInt()}% OFF'
                              : 'Potongan ${CurrencyFormatter.format(promo.discountValue.toInt())}';

                          final String dateStr = promo.endDate != null
                              ? 'Berlaku s/d ${DateFormat('dd MMM yyyy').format(promo.endDate!)}'
                              : 'Berlaku selamanya';

                          return Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected ? SolluColors.primary.withValues(alpha: 0.06) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? SolluColors.primary : SolluColors.neutral,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isSelected ? SolluColors.primary : SolluColors.secondary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    discountTag,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: isSelected ? Colors.white : SolluColors.secondaryDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        promo.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: SolluColors.textDark),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Target: ${promo.targetType == "product" ? "Per Produk" : "Per Bill"} • $dateStr',
                                        style: const TextStyle(fontSize: 11, color: SolluColors.textMuted),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(appliedDiscountProvider.notifier).applyPromo(promo);
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Promo "${promo.name}" berhasil diterapkan!'),
                                        backgroundColor: SolluColors.success,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected ? SolluColors.success : SolluColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    isSelected ? 'Terpasang' : 'Terapkan',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Gagal memuat promo: $err')),
                  ),

                  // Tab 2: Manual Discount
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tipe Diskon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SolluColors.textDark)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() {
                                  _manualType = 'percentage';
                                  _manualValController.clear();
                                }),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _manualType == 'percentage' ? SolluColors.primary.withValues(alpha: 0.1) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _manualType == 'percentage' ? SolluColors.primary : SolluColors.neutral,
                                      width: _manualType == 'percentage' ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Persentase (%)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _manualType == 'percentage' ? SolluColors.primary : SolluColors.textDark,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(() {
                                  _manualType = 'fixed';
                                  _manualValController.clear();
                                }),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _manualType == 'fixed' ? SolluColors.primary.withValues(alpha: 0.1) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: _manualType == 'fixed' ? SolluColors.primary : SolluColors.neutral,
                                      width: _manualType == 'fixed' ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Nominal Tetap (Rp)',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _manualType == 'fixed' ? SolluColors.primary : SolluColors.textDark,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _manualType == 'percentage' ? 'Persentase Diskon (%)' : 'Jumlah Potongan (Rp)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SolluColors.textDark),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _manualValController,
                          keyboardType: TextInputType.number,
                          inputFormatters: _manualType == 'fixed' ? [CurrencyInputFormatter()] : [],
                          autofocus: true,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: SolluColors.primary),
                          decoration: InputDecoration(
                            hintText: _manualType == 'percentage' ? 'Contoh: 10' : 'Contoh: 15000',
                            prefixText: _manualType == 'fixed' ? 'Rp ' : null,
                            suffixText: _manualType == 'percentage' ? '%' : null,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text('Catatan / Keterangan (Opsional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: SolluColors.textDark)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _manualNameController,
                          decoration: InputDecoration(
                            hintText: 'Cth: Diskon Khusus Karyawan / Kerabat',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _applyManualDiscount,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SolluColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              elevation: 0,
                            ),
                            child: const Text('Terapkan Diskon Manual', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup (Esc)', style: TextStyle(color: SolluColors.textMuted)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerDialog extends ConsumerStatefulWidget {
  const CustomerDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const CustomerDialog(),
    );
  }

  @override
  ConsumerState<CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends ConsumerState<CustomerDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);

    return AlertDialog(
      title: const Text('Pilih Pelanggan (F5)', style: TextStyle(fontWeight: FontWeight.bold, color: SolluColors.textDark)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (v) => setState(() => _searchQuery = v.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Cari nama atau no HP pelanggan...',
                prefixIcon: const Icon(Icons.person_search),
                contentPadding: SolluSpacing.inputPadding,
                border: OutlineInputBorder(borderRadius: SolluSpacing.radiusSm),
              ),
            ),
            const SizedBox(height: SolluSpacing.lg),
            SizedBox(
              height: 260,
              child: customersAsync.when(
                data: (customers) {
                  final filtered = customers.where((c) {
                    if (_searchQuery.isEmpty) return true;
                    return c.name.toLowerCase().contains(_searchQuery) ||
                        (c.phone != null && c.phone!.contains(_searchQuery));
                  }).toList();

                  return ListView.separated(
                    itemCount: filtered.length + 1,
                    separatorBuilder: (context, index) => const Divider(height: 1, color: SolluColors.neutral),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          leading: const Icon(Icons.people_outline, color: SolluColors.primary),
                          title: const Text('Pelanggan Umum (Walk-in)', style: TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text('Tanpa data member khusus', style: TextStyle(fontSize: 11, color: SolluColors.textMuted)),
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                        );
                      }

                      final cust = filtered[index - 1];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        leading: const Icon(Icons.person, color: SolluColors.primary),
                        title: Text(cust.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(cust.phone ?? cust.code ?? 'Member', style: const TextStyle(fontSize: 11, color: SolluColors.textMuted)),
                        onTap: () {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Pelanggan "${cust.name}" dipilih'),
                              backgroundColor: SolluColors.success,
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal (Esc)', style: TextStyle(color: SolluColors.textMuted)),
        ),
      ],
    );
  }
}

class EditCartItemDialog extends StatefulWidget {
  final CartItem item;
  final void Function(int qty, String? discountType, double? discountValue, String? notes) onSaved;

  const EditCartItemDialog({
    super.key,
    required this.item,
    required this.onSaved,
  });

  static Future<void> show({
    required BuildContext context,
    required CartItem item,
    required void Function(int qty, String? discountType, double? discountValue, String? notes) onSaved,
  }) {
    return showDialog(
      context: context,
      builder: (context) => EditCartItemDialog(
        item: item,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<EditCartItemDialog> createState() => _EditCartItemDialogState();
}

class _EditCartItemDialogState extends State<EditCartItemDialog> {
  late final TextEditingController _qtyController;
  late final TextEditingController _discountController;
  late final TextEditingController _notesController;
  String _discountType = 'fixed';

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: widget.item.qty.toString());
    _qtyController.selection = TextSelection(baseOffset: 0, extentOffset: _qtyController.text.length);
    
    _discountType = widget.item.discountType ?? 'fixed';
    _discountController = TextEditingController(
        text: widget.item.discountValue != null && widget.item.discountValue! > 0
            ? widget.item.discountValue!.toInt().toString()
            : '');
    _notesController = TextEditingController(text: widget.item.notes ?? '');
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _discountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final newQty = int.tryParse(_qtyController.text.trim());
    if (newQty != null && newQty > 0) {
      double? discVal;
      final discText = _discountController.text.trim().replaceAll(',', '.');
      if (discText.isNotEmpty) {
        discVal = double.tryParse(discText);
      }
      
      widget.onSaved(
        newQty,
        discVal != null && discVal > 0 ? _discountType : null,
        discVal != null && discVal > 0 ? discVal : null,
        _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent || event is KeyRepeatEvent) {
          if (event.logicalKey == LogicalKeyboardKey.enter || event.logicalKey == LogicalKeyboardKey.numpadEnter) {
            _submit();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SolluColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.edit_note, color: SolluColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ubah Detail Item',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: SolluColors.textDark),
                  ),
                  Text(
                    widget.item.name,
                    style: const TextStyle(fontSize: 12, color: SolluColors.textMuted, fontWeight: FontWeight.normal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 380,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // QTY
                const Text('Kuantitas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SolluColors.textDark)),
                const SizedBox(height: 8),
                TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: SolluColors.primary),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 16),
                
                // DISCOUNT
                const Text('Diskon Per Item', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SolluColors.textDark)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: SolluColors.neutral),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _discountType,
                          items: const [
                            DropdownMenuItem(value: 'fixed', child: Text('Rp')),
                            DropdownMenuItem(value: 'percentage', child: Text('%')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _discountType = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _discountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Nilai Diskon',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // NOTES
                const Text('Catatan Tambahan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SolluColors.textDark)),
                const SizedBox(height: 8),
                TextField(
                  controller: _notesController,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText: 'Misal: Jangan pakai bawang...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal (Esc)', style: TextStyle(color: SolluColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: SolluColors.primary,
              foregroundColor: Colors.white,
              padding: SolluSpacing.buttonPadding,
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}

class ShortcutHelpDialog extends StatelessWidget {
  const ShortcutHelpDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const ShortcutHelpDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> shortcuts = [
      {'key': 'F1', 'desc': 'Cari Produk / Scan Barcode'},
      {'key': 'F2', 'desc': 'Fokus Daftar Produk (Pilih Item #1)'},
      {'key': 'F3', 'desc': 'Fokus List Keranjang & Ubah Qty via Enter'},
      {'key': 'F4', 'desc': 'Tambah Diskon Bill'},
      {'key': 'F5', 'desc': 'Pilih Pelanggan / Member'},
      {'key': 'F6', 'desc': 'Tahan Pesanan (Hold Order)'},
      {'key': 'F7', 'desc': 'Daftar Transaksi Ditahan (Recall Hold)'},
      {'key': 'F8', 'desc': 'Checkout & Pembayaran'},
      {'key': 'F9', 'desc': 'Daftar Riwayat Transaksi Shift'},
      {'key': 'F10', 'desc': 'Cetak Ulang Struk (Reprint)'},
      {'key': 'F12', 'desc': 'Tutup Shift Kasir'},
      {'key': 'Esc', 'desc': 'Tutup Popup / Batal'},
    ];

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.keyboard, color: SolluColors.primary),
          SizedBox(width: SolluSpacing.md),
          Text('Panduan Keyboard Shortcut', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: SolluColors.textDark)),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gunakan tombol fungsi pada keyboard untuk mempercepat navigasi kasir:',
              style: TextStyle(color: SolluColors.textMuted, fontSize: 13),
            ),
            const SizedBox(height: SolluSpacing.lg),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: shortcuts.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: SolluColors.neutral),
                itemBuilder: (context, index) {
                  final s = shortcuts[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: SolluColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: SolluColors.primaryLight.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            s['key']!,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: SolluColors.primary),
                          ),
                        ),
                        const SizedBox(width: SolluSpacing.lg),
                        Expanded(
                          child: Text(s['desc']!, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: SolluColors.textDark)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: SolluColors.primary,
            foregroundColor: Colors.white,
            padding: SolluSpacing.buttonPadding,
          ),
          child: const Text('Tutup (Esc)'),
        ),
      ],
    );
  }
}

class EmptyCartDialog extends StatelessWidget {
  const EmptyCartDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const EmptyCartDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SolluColors.warning.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.remove_shopping_cart_outlined,
                size: 48,
                color: SolluColors.warning,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Keranjang Masih Kosong',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: SolluColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tidak dapat melanjutkan pembayaran. Silakan pilih minimal satu produk ke dalam keranjang terlebih dahulu.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: SolluColors.textMuted,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SolluColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Mengerti (Esc)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

