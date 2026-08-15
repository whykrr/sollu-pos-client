import 'package:drift/drift.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/network/dio_client.dart';
import '../presentation/providers/cart_provider.dart';

class TransactionDetailData {
  final Transaction transaction;
  final List<TransactionItem> items;
  final Map<String, List<TransactionItemModifier>> modifiersByItemId;
  final List<TransactionPayment> payments;
  final TransactionPromo? promo;
  final PaymentMethod? paymentMethod;

  TransactionDetailData({
    required this.transaction,
    required this.items,
    required this.modifiersByItemId,
    required this.payments,
    this.promo,
    this.paymentMethod,
  });
}

class TransactionRepository {
  final AppDatabase _database;
  final DioClient _dioClient;
  final Uuid _uuid = const Uuid();

  TransactionRepository(this._database, this._dioClient);

  /// Menghasilkan nomor transaksi unik TRX/YYYY/MM/XXXX
  Future<String> generateTransactionNumber() async {
    final now = DateTime.now();
    final datePrefix = 'TRX/${DateFormat('yyyy/MM').format(now)}/';
    
    final countRows = await (_database.select(_database.transactions)
          ..where((t) => t.transactionNumber.like('$datePrefix%')))
        .get();

    final nextNumber = countRows.length + 1;
    return '$datePrefix${nextNumber.toString().padLeft(4, '0')}';
  }

  /// Membuat transaksi lengkap secara offline-first dan potong stok
  Future<Transaction> createTransaction({
    String? shiftId,
    String? customerId,
    required List<CartItem> items,
    required double subtotal,
    required double discountAmount,
    String? discountType,
    double? discountValue,
    String? promoName,
    String? promoId,
    required double taxAmount,
    double serviceChargeAmount = 0.0,
    required double total,
    required PaymentMethod paymentMethod,
    required double cashReceived,
    required double changeAmount,
    String? notes,
    String outletId = 'default-outlet',
  }) async {
    final txId = _uuid.v4();
    final txNumber = await generateTransactionNumber();
    final now = DateTime.now();

    return await _database.transaction(() async {
      // 1. Simpan Transaksi Utama
      await _database.into(_database.transactions).insert(
        TransactionsCompanion.insert(
          id: txId,
          outletId: outletId,
          shiftId: Value(shiftId),
          customerId: Value(customerId),
          channel: const Value('pos'),
          transactionNumber: txNumber,
          subtotal: subtotal,
          discountAmount: Value(discountAmount),
          discountType: Value(discountType),
          discountValue: Value(discountValue),
          promoName: Value(promoName),
          taxAmount: Value(taxAmount),
          serviceChargeAmount: Value(serviceChargeAmount),
          shippingFee: const Value(0.0),
          total: total,
          paymentStatus: 'paid',
          status: 'completed',
          notes: Value(notes),
          isOffline: const Value(true),
          offlineId: Value(txId),
          createdAt: Value(now),
        ),
      );

      // 2. Simpan Item Transaksi & Potong Stok Lokal
      final List<Map<String, dynamic>> itemsPayload = [];

      for (final cartItem in items) {
        final itemId = _uuid.v4();
        
        String? resolvedProductId = cartItem.productId.isNotEmpty ? cartItem.productId : null;
        String? resolvedInventoryItemId = cartItem.inventoryItemId.isNotEmpty ? cartItem.inventoryItemId : null;
        String? resolvedVariantGroupOptionId = cartItem.variantGroupOptionId;

        // Jika variantGroupOptionId belum terpasang langsung tapi ada selectedVariants
        if (resolvedVariantGroupOptionId == null && cartItem.selectedVariants.isNotEmpty) {
          resolvedVariantGroupOptionId = cartItem.selectedVariants.values.firstOrNull;
        }

        // Jika inventoryItemId belum ada, cari dari database
        if (resolvedInventoryItemId == null && resolvedProductId != null) {
          if (resolvedVariantGroupOptionId != null) {
            // Cari inventory item yang berelasi dengan variant option ini
            final row = await _database.customSelect(
              '''
              SELECT i.id FROM inventories i
              INNER JOIN inventory_item_variant_group_options piv ON piv.inventory_item_id = i.id
              WHERE i.product_id = ? AND piv.variant_group_option_id = ?
              LIMIT 1
              ''',
              variables: [
                Variable.withString(resolvedProductId),
                Variable.withString(resolvedVariantGroupOptionId),
              ],
            ).getSingleOrNull();

            if (row != null) {
              resolvedInventoryItemId = row.read<String>('id');
            }
          }

          // Jika masih null, ambil inventory item standalone default untuk produk ini
          if (resolvedInventoryItemId == null) {
            final inv = await (_database.select(_database.inventories)
                  ..where((i) => i.productId.equals(resolvedProductId)))
                .getSingleOrNull();
            if (inv != null) {
              resolvedInventoryItemId = inv.id;
            }
          }
        }

        // Jika variantGroupOptionId masih null tapi inventoryItemId ada, cari variantGroupOptionId dari pivot
        if (resolvedVariantGroupOptionId == null && resolvedInventoryItemId != null) {
          final piv = await (_database.select(_database.inventoryItemVariantGroupOptions)
                ..where((p) => p.inventoryItemId.equals(resolvedInventoryItemId!)))
              .getSingleOrNull();
          if (piv != null) {
            resolvedVariantGroupOptionId = piv.variantGroupOptionId;
          }
        }
        
        // Hitung nilai diskon
        double itemDiscountAmount = 0.0;
        String? itemDiscountType = cartItem.discountType;
        double? itemDiscountValue = cartItem.discountValue;

        if (itemDiscountType == 'percentage') {
          itemDiscountAmount = (cartItem.price * (itemDiscountValue ?? 0) / 100) * cartItem.qty;
        } else if (itemDiscountType == 'fixed') {
          itemDiscountAmount = (itemDiscountValue ?? 0) * cartItem.qty;
        }

        final itemSubtotal = (cartItem.price * cartItem.qty) - itemDiscountAmount;

        await _database.into(_database.transactionItems).insert(
          TransactionItemsCompanion.insert(
            id: itemId,
            transactionId: txId,
            productId: Value(resolvedProductId),
            inventoryItemId: Value(resolvedInventoryItemId),
            variantGroupOptionId: Value(resolvedVariantGroupOptionId),
            productName: cartItem.name,
            price: cartItem.price,
            qty: cartItem.qty.toDouble(),
            discountType: Value(itemDiscountType),
            discountValue: Value(itemDiscountValue),
            discountAmount: Value(itemDiscountAmount),
            subtotal: itemSubtotal,
            notes: Value(cartItem.notes),
            createdAt: Value(now),
          ),
        );

        // Potong stok lokal jika ada inventoryItemId
        if (resolvedInventoryItemId != null) {
          final inventory = await (_database.select(_database.inventories)
                ..where((i) => i.id.equals(resolvedInventoryItemId!)))
              .getSingleOrNull();

          if (inventory != null && inventory.trackInventory) {
            final newStock = inventory.stock - cartItem.qty;
            await (_database.update(_database.inventories)
                  ..where((i) => i.id.equals(resolvedInventoryItemId!)))
                .write(InventoriesCompanion(stock: Value(newStock)));
          }
        }

        // Siapkan payload sync untuk item
        final List<Map<String, dynamic>> modPayload = [];
        if (cartItem.selectedModifiers.isNotEmpty) {
          for (final entry in cartItem.selectedModifiers.entries) {
            for (final modOptionIdOrName in entry.value) {
              final modId = _uuid.v4();
              final modOption = await (_database.select(_database.modifierOptions)
                    ..where((m) => m.id.equals(modOptionIdOrName)))
                  .getSingleOrNull();

              final modName = modOption?.name ?? modOptionIdOrName;
              final modPrice = modOption?.price ?? 0.0;
              final modOptionId = modOption?.id ?? (modOptionIdOrName.contains('-') ? modOptionIdOrName : null);

              await _database.into(_database.transactionItemModifiers).insert(
                TransactionItemModifiersCompanion.insert(
                  id: modId,
                  transactionItemId: itemId,
                  modifierName: modName,
                  price: Value(modPrice),
                  qty: const Value(1.0),
                ),
              );

              modPayload.add({
                'modifier_option_id': modOptionId,
                'modifier_name': modName,
                'price': modPrice,
                'qty': 1,
              });
            }
          }
        }

        itemsPayload.add({
          'product_id': resolvedProductId,
          'inventory_item_id': resolvedInventoryItemId,
          'variant_group_option_id': resolvedVariantGroupOptionId,
          'product_name': cartItem.name,
          'price': cartItem.price,
          'qty': cartItem.qty,
          'discount_type': itemDiscountType,
          'discount_value': itemDiscountValue,
          'discount_amount': itemDiscountAmount,
          'subtotal': itemSubtotal,
          'modifiers': modPayload,
        });
      }

      // 3. Simpan Pembayaran Transaksi
      final paymentId = _uuid.v4();
      final paymentAmount = paymentMethod.type == 'cash' ? cashReceived : total;

      await _database.into(_database.transactionPayments).insert(
        TransactionPaymentsCompanion.insert(
          id: paymentId,
          transactionId: txId,
          paymentMethodId: Value(paymentMethod.id),
          amount: paymentAmount,
          changeAmount: Value(changeAmount),
          paidAt: Value(now),
        ),
      );

      // 4. Simpan Promo Transaksi jika ada
      if (promoName != null && promoName.isNotEmpty) {
        final txPromoId = _uuid.v4();
        await _database.into(_database.transactionPromos).insert(
          TransactionPromosCompanion.insert(
            id: txPromoId,
            transactionId: txId,
            promoId: Value(promoId),
            promoName: promoName,
            discountType: discountType ?? 'fixed',
            discountValue: Value(discountValue ?? discountAmount),
            discountAmount: Value(discountAmount),
            createdAt: Value(now),
          ),
        );
      }

      // Ambil objek transaksi yang tersimpan
      final createdTx = await (_database.select(_database.transactions)
            ..where((t) => t.id.equals(txId)))
          .getSingle();

      // 5. Coba sinkronkan ke backend jika online di background
      _syncTransactionOnline(
        txId: txId,
        txNumber: txNumber,
        shiftId: shiftId,
        customerId: customerId,
        subtotal: subtotal,
        discountAmount: discountAmount,
        discountType: discountType,
        discountValue: discountValue,
        promoName: promoName,
        promoId: promoId,
        taxAmount: taxAmount,
        serviceChargeAmount: serviceChargeAmount,
        total: total,
        itemsPayload: itemsPayload,
        paymentMethodId: paymentMethod.id,
        paymentAmount: paymentAmount,
        changeAmount: changeAmount,
        notes: notes,
      );

      return createdTx;
    });
  }

  /// Sinkronisasi transaksi ke API backend Laravel
  Future<bool> _syncTransactionOnline({
    required String txId,
    required String txNumber,
    String? shiftId,
    String? customerId,
    required double subtotal,
    required double discountAmount,
    String? discountType,
    double? discountValue,
    String? promoName,
    String? promoId,
    required double taxAmount,
    required double serviceChargeAmount,
    required double total,
    required List<Map<String, dynamic>> itemsPayload,
    required String paymentMethodId,
    required double paymentAmount,
    required double changeAmount,
    String? notes,
  }) async {
    try {
      final response = await _dioClient.dio.post('/transactions', data: {
        'offline_id': txId,
        'transaction_number': txNumber,
        'shift_id': shiftId,
        'customer_id': customerId,
        'subtotal': subtotal,
        'discount_amount': discountAmount,
        'discount_type': discountType,
        'discount_value': discountValue,
        'promo_name': promoName,
        'tax_amount': taxAmount,
        'service_charge_amount': serviceChargeAmount,
        'total': total,
        'payment_status': 'paid',
        'status': 'completed',
        'notes': notes,
        'items': itemsPayload,
        'payments': [
          {
            'payment_method_id': paymentMethodId,
            'amount': paymentAmount,
            'change_amount': changeAmount,
          }
        ],
        if (promoName != null)
          'promos': [
            {
              'promo_id': promoId,
              'promo_name': promoName,
              'discount_type': discountType ?? 'fixed',
              'discount_value': discountValue ?? discountAmount,
              'discount_amount': discountAmount,
            }
          ],
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Tandai transaksi lokal sebagai tersinkronisasi
        await (_database.update(_database.transactions)..where((t) => t.id.equals(txId)))
            .write(const TransactionsCompanion(isOffline: Value(false)));
        return true;
      }
      return false;
    } catch (_) {
      // Jika offline, data transaksi tetap aman tersimpan di SQLite lokal
      return false;
    }
  }

  /// Mendapatkan jumlah transaksi yang belum tersinkron
  Future<int> getUnsyncedTransactionsCount() async {
    final countRows = await (_database.select(_database.transactions)
          ..where((t) => t.isOffline.equals(true)))
        .get();
    return countRows.length;
  }

  /// Mendapatkan daftar transaksi yang belum tersinkron
  Future<List<Transaction>> getUnsyncedTransactions() async {
    return await (_database.select(_database.transactions)
          ..where((t) => t.isOffline.equals(true)))
        .get();
  }

  /// Mencoba menyinkronkan seluruh transaksi yang pending
  Future<int> syncPendingTransactions({bool force = false}) async {
    final unsynced = await getUnsyncedTransactions();
    if (unsynced.isEmpty) return 0;
    
    // Syarat sinkronisasi: jika lebih dari 10 atau dipaksa
    if (!force && unsynced.length <= 10) return 0;

    int successCount = 0;
    for (final tx in unsynced) {
      final details = await getTransactionDetails(tx.id);
      if (details == null) continue;

      final itemsPayload = <Map<String, dynamic>>[];
      for (final item in details.items) {
        final mods = details.modifiersByItemId[item.id] ?? [];
        final modPayload = mods.map((m) => {
          'modifier_option_id': null, 
          'modifier_name': m.modifierName,
          'price': m.price,
          'qty': m.qty,
        }).toList();

        itemsPayload.add({
          'product_id': item.productId,
          'inventory_item_id': item.inventoryItemId,
          'variant_group_option_id': item.variantGroupOptionId,
          'product_name': item.productName,
          'price': item.price,
          'qty': item.qty,
          'discount_type': item.discountType,
          'discount_value': item.discountValue,
          'discount_amount': item.discountAmount,
          'subtotal': item.subtotal,
          'modifiers': modPayload,
        });
      }

      final payment = details.payments.isNotEmpty ? details.payments.first : null;
      if (payment == null) continue;

      final success = await _syncTransactionOnline(
        txId: tx.id,
        txNumber: tx.transactionNumber,
        shiftId: tx.shiftId,
        customerId: tx.customerId,
        subtotal: tx.subtotal,
        discountAmount: tx.discountAmount ?? 0.0,
        discountType: tx.discountType,
        discountValue: tx.discountValue,
        promoName: tx.promoName,
        promoId: details.promo?.promoId,
        taxAmount: tx.taxAmount ?? 0.0,
        serviceChargeAmount: tx.serviceChargeAmount ?? 0.0,
        total: tx.total,
        itemsPayload: itemsPayload,
        paymentMethodId: payment.paymentMethodId ?? 'cash',
        paymentAmount: payment.amount,
        changeAmount: payment.changeAmount ?? 0.0,
        notes: tx.notes,
      );

      if (success) {
        successCount++;
      } else {
        // Jika satu gagal, asumsi sedang offline, hentikan antrean
        break;
      }
    }
    return successCount;
  }

  /// Memantau transaksi pada shift yang sedang aktif
  Stream<List<Transaction>> watchCurrentShiftTransactions(String shiftId) {
    return (_database.select(_database.transactions)
          ..where((t) => t.shiftId.equals(shiftId))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  /// Memantau seluruh transaksi lokal (untuk layar Riwayat Transaksi)
  Stream<List<Transaction>> watchAllTransactions({String? searchQuery, DateTime? date, String? channel}) {
    return (_database.select(_database.transactions)
          ..where((t) {
            Expression<bool> predicate = const Constant(true);
            if (searchQuery != null && searchQuery.isNotEmpty) {
              predicate = predicate & t.transactionNumber.like('%$searchQuery%');
            }
            if (date != null) {
              final startOfDay = DateTime(date.year, date.month, date.day);
              final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
              predicate = predicate & t.createdAt.isBiggerOrEqualValue(startOfDay) & t.createdAt.isSmallerOrEqualValue(endOfDay);
            }
            if (channel != null && channel.isNotEmpty) {
              predicate = predicate & t.channel.equals(channel);
            }
            return predicate;
          })
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .watch();
  }

  /// Memantau ringkasan metode pembayaran
  Stream<List<PaymentMethodSummary>> watchPaymentMethodSummary({String? searchQuery, DateTime? date, String? channel}) {
    final t = _database.transactions;
    final p = _database.transactionPayments;
    final m = _database.paymentMethods;
    
    // We can use a custom query to group by payment method
    return _database.customSelect(
      '''
      SELECT 
        COALESCE(m.name, 'Tunai') as method_name,
        SUM(p.amount - p.change_amount) as total_amount,
        COUNT(t.id) as count
      FROM transactions t
      LEFT JOIN transaction_payments p ON p.transaction_id = t.id
      LEFT JOIN payment_methods m ON m.id = p.payment_method_id
      WHERE 1=1
      ${searchQuery != null && searchQuery.isNotEmpty ? "AND t.transaction_number LIKE '%$searchQuery%'" : ""}
      ${date != null ? "AND t.created_at >= '${DateTime(date.year, date.month, date.day).toIso8601String()}' AND t.created_at <= '${DateTime(date.year, date.month, date.day, 23, 59, 59).toIso8601String()}'" : ""}
      ${channel != null && channel.isNotEmpty ? "AND t.channel = '$channel'" : ""}
      GROUP BY m.name
      ''',
      readsFrom: {t, p, m},
    ).watch().map((rows) {
      return rows.map((row) {
        return PaymentMethodSummary(
          row.read<String>('method_name'),
          row.read<double>('total_amount'),
          row.read<int>('count'),
        );
      }).toList();
    });
  }

  /// Mengambil rincian lengkap transaksi
  Future<TransactionDetailData?> getTransactionDetails(String transactionId) async {
    final tx = await (_database.select(_database.transactions)
          ..where((t) => t.id.equals(transactionId)))
        .getSingleOrNull();

    if (tx == null) return null;

    final items = await (_database.select(_database.transactionItems)
          ..where((i) => i.transactionId.equals(transactionId)))
        .get();

    final Map<String, List<TransactionItemModifier>> modifiersByItemId = {};
    for (final item in items) {
      final mods = await (_database.select(_database.transactionItemModifiers)
            ..where((m) => m.transactionItemId.equals(item.id)))
        .get();
      modifiersByItemId[item.id] = mods;
    }

    final payments = await (_database.select(_database.transactionPayments)
          ..where((p) => p.transactionId.equals(transactionId)))
        .get();

    PaymentMethod? paymentMethod;
    if (payments.isNotEmpty && payments.first.paymentMethodId != null) {
      paymentMethod = await (_database.select(_database.paymentMethods)
            ..where((m) => m.id.equals(payments.first.paymentMethodId!)))
          .getSingleOrNull();
    }

    final promo = await (_database.select(_database.transactionPromos)
          ..where((p) => p.transactionId.equals(transactionId)))
        .getSingleOrNull();

    return TransactionDetailData(
      transaction: tx,
      items: items,
      modifiersByItemId: modifiersByItemId,
      payments: payments,
      promo: promo,
      paymentMethod: paymentMethod,
    );
  }

  /// Memantau metode pembayaran aktif dari master data
  Stream<List<PaymentMethod>> watchActivePaymentMethods() {
    return (_database.select(_database.paymentMethods)
          ..where((m) => m.isActive.equals(true))
          ..orderBy([(m) => OrderingTerm(expression: m.name)]))
        .watch();
  }

  /// Memantau promo aktif dari master data
  Stream<List<Promo>> watchActivePromos() {
    final now = DateTime.now();
    return (_database.select(_database.promos)
          ..where((p) => p.status.equals('active'))
          ..orderBy([(p) => OrderingTerm(expression: p.name)]))
        .watch()
        .map((promos) {
          return promos.where((p) {
            if (p.startDate != null && p.startDate!.isAfter(now)) return false;
            if (p.endDate != null) {
              final endOfEndDay = DateTime(p.endDate!.year, p.endDate!.month, p.endDate!.day, 23, 59, 59);
              if (endOfEndDay.isBefore(now)) return false;
            }
            return true;
          }).toList();
        });
  }

  /// Memantau data pelanggan
  Stream<List<Customer>> watchCustomers() {
    return (_database.select(_database.customers)
          ..orderBy([(c) => OrderingTerm(expression: c.name)]))
        .watch();
  }
}

class PaymentMethodSummary {
  final String methodName;
  final double totalAmount;
  final int count;

  PaymentMethodSummary(this.methodName, this.totalAmount, this.count);
}
