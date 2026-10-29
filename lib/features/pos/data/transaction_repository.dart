import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/enums/transaction_enums.dart';
import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/outlet_settings_service.dart';
import '../../shift/data/shift_repository.dart';
import '../presentation/providers/cart_provider.dart';

enum SyncOutcome {
  success,
  networkOffline,
  serverError,
}

class SyncResult {
  final SyncOutcome outcome;
  final String? errorMessage;
  final int? statusCode;

  const SyncResult.success()
      : outcome = SyncOutcome.success,
        errorMessage = null,
        statusCode = 200;

  const SyncResult.networkOffline([this.errorMessage])
      : outcome = SyncOutcome.networkOffline,
        statusCode = null;

  const SyncResult.serverError(this.statusCode, this.errorMessage)
      : outcome = SyncOutcome.serverError;
}

class TransactionDetailData {
  final Transaction transaction;
  final List<TransactionItem> items;
  final Map<String, List<TransactionItemModifier>> modifiersByItemId;
  final List<TransactionPayment> payments;
  final TransactionPromo? promo;
  final PaymentMethod? paymentMethod;
  final Customer? customer;

  TransactionDetailData({
    required this.transaction,
    required this.items,
    required this.modifiersByItemId,
    required this.payments,
    this.promo,
    this.paymentMethod,
    this.customer,
  });
}

class TransactionRepository {
  final AppDatabase _database;
  final DioClient _dioClient;
  final OutletSettingsService? _outletSettingsService;
  final ShiftRepository? _shiftRepository;
  final Uuid _uuid = const Uuid();

  bool _isSyncQueueRunning = false;
  bool get isSyncQueueRunning => _isSyncQueueRunning;
  Completer<int>? _activeSyncCompleter;

  TransactionRepository(
    this._database,
    this._dioClient, [
    this._outletSettingsService,
    this._shiftRepository,
  ]);

  /// Helper untuk mendapatkan inisial outlet
  String resolveOutletInitial(String outletName) {
    final clean = outletName.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) return 'POS';
    final words = clean.split(' ');
    if (words.length >= 2) {
      return words.map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
    }
    return clean.length >= 3
        ? clean.substring(0, 3).toUpperCase()
        : clean.toUpperCase().padRight(3, 'X');
  }

  /// Menghasilkan nomor transaksi unik TRX/YYYY.MM.DD/{Inisial Outlet}.POS/XXXX
  Future<String> generateTransactionNumber({String? outletName}) async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy.MM.dd').format(now);

    String outletInit = 'POS';
    if (_outletSettingsService != null) {
      final profile = _outletSettingsService.getOutletProfile();
      if (profile != null && profile['initial'] != null && profile['initial'].toString().isNotEmpty) {
        outletInit = profile['initial'].toString().toUpperCase();
      } else if (profile != null && profile['name'] != null) {
        outletInit = resolveOutletInitial(profile['name'].toString());
      } else if (outletName != null) {
        outletInit = resolveOutletInitial(outletName);
      }
    } else if (outletName != null) {
      outletInit = resolveOutletInitial(outletName);
    }

    final channelInit = 'POS';
    final prefix = 'TRX/$dateStr/$outletInit.$channelInit/';

    final countRows = await (_database.select(
      _database.transactions,
    )..where((t) => t.transactionNumber.like('$prefix%'))).get();

    final nextNumber = countRows.length + 1;
    return '$prefix${nextNumber.toString().padLeft(4, '0')}';
  }

  /// Membuat transaksi lengkap secara offline-first dan potong stok
  Future<({Transaction transaction, TransactionDetailData detail})>
  createTransaction({
    String? shiftId,
    String? cashierId,
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
    String type = 'walk_in',
  }) async {
    final txId = _uuid.v4();
    final txNumber = await generateTransactionNumber();
    final now = DateTime.now();
    final result = await _database.transaction(() async {
      // 1. Simpan Transaksi Utama
      await _database
          .into(_database.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: txId,
              outletId: outletId,
              shiftId: Value(shiftId),
              customerId: Value(customerId),
              channel: const Value('pos'),
              type: Value(type),
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
              paymentStatus: TransactionPaymentStatus.paid.value,
              status: TransactionStatus.completed.value,
              notes: Value(notes),
              isOffline: const Value(true),
              offlineId: Value(txId),
              syncStatus: const Value('pending'),
              syncAttempts: const Value(0),
              createdAt: Value(now),
            ),
          );

      // 2. Simpan Item Transaksi & Potong Stok Lokal
      final List<TransactionItem> createdItems = [];
      final Map<String, List<TransactionItemModifier>>
      createdModifiersByItemId = {};

      for (final cartItem in items) {
        final itemId = _uuid.v4();

        String? resolvedProductId = cartItem.productId.isNotEmpty
            ? cartItem.productId
            : null;
        String? resolvedProductItemId = (cartItem.productItemId != null &&
                cartItem.productItemId!.isNotEmpty)
            ? cartItem.productItemId
            : null;
        String? resolvedInventoryItemId = cartItem.inventoryItemId.isNotEmpty
            ? cartItem.inventoryItemId
            : null;
        String? resolvedVariantGroupOptionId = cartItem.variantGroupOptionId;

        // Jika variantGroupOptionId belum terpasang langsung tapi ada selectedVariants
        if (resolvedVariantGroupOptionId == null &&
            cartItem.selectedVariants.isNotEmpty) {
          resolvedVariantGroupOptionId =
              cartItem.selectedVariants.values.firstOrNull;
        }

        // Resolusi productItemId jika belum ada di cartItem
        if (resolvedProductItemId == null && resolvedProductId != null) {
          final variantOptionIds = cartItem.selectedVariants.values.toList();
          if (resolvedVariantGroupOptionId != null &&
              !variantOptionIds.contains(resolvedVariantGroupOptionId)) {
            variantOptionIds.add(resolvedVariantGroupOptionId);
          }
          if (variantOptionIds.isNotEmpty) {
            final inClause =
                List.filled(variantOptionIds.length, '?').join(',');
            final row = await _database.customSelect(
              '''
              SELECT piv.product_item_id
              FROM product_item_variant_group_options piv
              INNER JOIN product_items pi ON pi.id = piv.product_item_id
              WHERE pi.product_id = ? AND piv.variant_group_option_id IN ($inClause)
              GROUP BY piv.product_item_id
              HAVING COUNT(DISTINCT piv.variant_group_option_id) = ?
                AND (SELECT COUNT(*) FROM product_item_variant_group_options WHERE product_item_id = piv.product_item_id) = ?
              LIMIT 1
              ''',
              variables: [
                Variable.withString(resolvedProductId),
                ...variantOptionIds.map((id) => Variable.withString(id)),
                Variable.withInt(variantOptionIds.length),
                Variable.withInt(variantOptionIds.length),
              ],
            ).getSingleOrNull();
            resolvedProductItemId = row?.read<String>('product_item_id');
          }

          if (resolvedProductItemId == null) {
            final pi = await (_database.select(_database.productItems)
                  ..where((p) => p.productId.equals(resolvedProductId))
                  ..limit(1))
                .getSingleOrNull();
            resolvedProductItemId = pi?.id;
          }
        }

        // Jika inventoryItemId belum ada dan trackInventory aktif, cari dari database
        if (resolvedInventoryItemId == null &&
            resolvedProductItemId != null &&
            cartItem.trackInventory) {
          final inv = await (_database.select(_database.inventories)
                ..where((i) => i.productItemId.equals(resolvedProductItemId!))
                ..limit(1))
              .getSingleOrNull();
          resolvedInventoryItemId = inv?.id;
        }

        if (cartItem.trackInventory &&
            resolvedInventoryItemId == null &&
            resolvedProductId != null) {
          if (resolvedVariantGroupOptionId != null) {
            final row = await _database
                .customSelect(
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
                )
                .getSingleOrNull();

            if (row != null) {
              resolvedInventoryItemId = row.read<String>('id');
            }
          }

          if (resolvedInventoryItemId == null) {
            final inv = await (_database.select(_database.inventories)
                  ..where((i) => i.productId.equals(resolvedProductId)))
                .getSingleOrNull();
            if (inv != null) {
              resolvedInventoryItemId = inv.id;
            }
          }
        }

        if (resolvedVariantGroupOptionId == null &&
            resolvedInventoryItemId != null) {
          final piv = await (_database.select(
                _database.inventoryItemVariantGroupOptions,
              )..where(
                (p) => p.inventoryItemId.equals(resolvedInventoryItemId!),
              ))
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
          itemDiscountAmount =
              (cartItem.price * (itemDiscountValue ?? 0) / 100) * cartItem.qty;
        } else if (itemDiscountType == 'fixed') {
          itemDiscountAmount = (itemDiscountValue ?? 0) * cartItem.qty;
        }

        final itemSubtotal =
            (cartItem.price * cartItem.qty) - itemDiscountAmount;

        await _database
            .into(_database.transactionItems)
            .insert(
              TransactionItemsCompanion.insert(
                id: itemId,
                transactionId: txId,
                productId: Value(resolvedProductId),
                productItemId: Value(resolvedProductItemId),
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

        createdItems.add(
          TransactionItem(
            id: itemId,
            transactionId: txId,
            productId: resolvedProductId,
            productItemId: resolvedProductItemId,
            inventoryItemId: resolvedInventoryItemId,
            variantGroupOptionId: resolvedVariantGroupOptionId,
            productName: cartItem.name,
            price: cartItem.price,
            qty: cartItem.qty.toDouble(),
            discountType: itemDiscountType,
            discountValue: itemDiscountValue,
            discountAmount: itemDiscountAmount,
            subtotal: itemSubtotal,
            notes: cartItem.notes,
            createdAt: now,
          ),
        );

        // Potong stok dari database lokal HANYA jika produk melacak stok
        if (cartItem.trackInventory && resolvedInventoryItemId != null) {
          final inventory =
              await (_database.select(_database.inventories)
                    ..where((i) => i.id.equals(resolvedInventoryItemId!)))
                    .getSingleOrNull();

          if (inventory != null && inventory.trackInventory) {
            final newStock = inventory.stock - cartItem.qty;
            await (_database.update(_database.inventories)
                  ..where((i) => i.id.equals(resolvedInventoryItemId!)))
                .write(InventoriesCompanion(stock: Value(newStock)));
          }
        }

        final List<TransactionItemModifier> itemMods = [];
        if (cartItem.selectedModifiers.isNotEmpty) {
          for (final entry in cartItem.selectedModifiers.entries) {
            for (final modOptionIdOrName in entry.value) {
              final modId = _uuid.v4();
              final modOption =
                  await (_database.select(_database.modifierOptions)
                        ..where((m) => m.id.equals(modOptionIdOrName)))
                      .getSingleOrNull();

              final modName = modOption?.name ?? modOptionIdOrName;
              final modPrice = modOption?.price ?? 0.0;
              final modOptionId =
                  modOption?.id ??
                  (modOptionIdOrName.contains('-') ? modOptionIdOrName : null);

              await _database
                  .into(_database.transactionItemModifiers)
                  .insert(
                    TransactionItemModifiersCompanion.insert(
                      id: modId,
                      transactionItemId: itemId,
                      modifierOptionId: Value(modOptionId),
                      modifierName: modName,
                      price: Value(modPrice),
                      qty: const Value(1.0),
                    ),
                  );

              itemMods.add(
                TransactionItemModifier(
                  id: modId,
                  transactionItemId: itemId,
                  modifierOptionId: modOptionId,
                  modifierName: modName,
                  price: modPrice,
                  qty: 1.0,
                ),
              );
            }
          }
        }
        createdModifiersByItemId[itemId] = itemMods;
      }

      // 3. Simpan Pembayaran Transaksi
      final paymentId = _uuid.v4();
      final paymentAmount = paymentMethod.type == 'cash' ? cashReceived : total;

      await _database
          .into(_database.transactionPayments)
          .insert(
            TransactionPaymentsCompanion.insert(
              id: paymentId,
              transactionId: txId,
              paymentMethodId: Value(paymentMethod.id),
              amount: paymentAmount,
              changeAmount: Value(changeAmount),
              paidAt: Value(now),
            ),
          );

      final createdPayment = TransactionPayment(
        id: paymentId,
        transactionId: txId,
        paymentMethodId: paymentMethod.id,
        amount: paymentAmount,
        changeAmount: changeAmount,
        paidAt: now,
      );

      // 4. Simpan Promo Transaksi jika ada
      TransactionPromo? createdPromo;
      if (promoName != null && promoName.isNotEmpty) {
        final txPromoId = _uuid.v4();
        await _database
            .into(_database.transactionPromos)
            .insert(
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

        createdPromo = TransactionPromo(
          id: txPromoId,
          transactionId: txId,
          promoId: promoId,
          promoName: promoName,
          discountType: discountType ?? 'fixed',
          discountValue: discountValue ?? discountAmount,
          discountAmount: discountAmount,
          createdAt: now,
        );
      }

      // Ambil objek transaksi yang tersimpan
      final createdTx = await (_database.select(
        _database.transactions,
      )..where((t) => t.id.equals(txId))).getSingle();

      Customer? resolvedCustomer;
      if (customerId != null) {
        resolvedCustomer = await (_database.select(
          _database.customers,
        )..where((c) => c.id.equals(customerId))).getSingleOrNull();
      }

      final detailData = TransactionDetailData(
        transaction: createdTx,
        items: createdItems,
        modifiersByItemId: createdModifiersByItemId,
        payments: [createdPayment],
        promo: createdPromo,
        paymentMethod: paymentMethod,
        customer: resolvedCustomer,
      );

      return (transaction: createdTx, detail: detailData);
    });

    // 5. Trigger pemrosesan antrean sinkronisasi latar belakang (FIFO) secara non-blocking
    enqueueSyncQueue();

    return result;
  }

  /// Sinkronisasi transaksi ke API backend Laravel dengan deteksi status & fallback
  Future<SyncResult> _syncTransactionOnline({
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
    String channel = 'pos',
    String type = 'walk_in',
  }) async {
    final now = DateTime.now();
    await (_database.update(_database.transactions)
          ..where((t) => t.id.equals(txId)))
        .write(TransactionsCompanion(
          syncStatus: const Value('syncing'),
          lastSyncAttemptAt: Value(now),
        ));

    try {
      final response = await _dioClient.dio.post(
        ApiEndpoints.transactions,
        data: {
          'offline_id': txId,
          'transaction_number': txNumber,
          'channel': channel,
          'type': type,
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
          'payment_status': TransactionPaymentStatus.paid.value,
          'status': TransactionStatus.completed.value,
          'notes': notes,
          'items': itemsPayload,
          'payments': [
            {
              'payment_method_id': paymentMethodId,
              'amount': paymentAmount,
              'change_amount': changeAmount,
            },
          ],
          if (promoName != null)
            'promos': [
              {
                'promo_id': promoId,
                'promo_name': promoName,
                'discount_type': discountType ?? 'fixed',
                'discount_value': discountValue ?? discountAmount,
                'discount_amount': discountAmount,
              },
            ],
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Tandai transaksi lokal sebagai tersinkronisasi
        await (_database.update(_database.transactions)
              ..where((t) => t.id.equals(txId)))
            .write(const TransactionsCompanion(
              isOffline: Value(false),
              syncStatus: Value('synced'),
              lastSyncError: Value(null),
            ));
        return const SyncResult.success();
      }

      final err = 'Server mengembalikan status ${response.statusCode}';
      await _recordSyncFailure(txId: txId, error: err, statusCode: response.statusCode);
      return SyncResult.serverError(response.statusCode, err);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        // Transient network offline: jangan jadikan failed permanen
        await (_database.update(_database.transactions)
              ..where((t) => t.id.equals(txId)))
            .write(const TransactionsCompanion(syncStatus: Value('pending')));
        return SyncResult.networkOffline(e.message);
      }

      final statusCode = e.response?.statusCode ?? 500;
      String errorMessage = 'Error $statusCode';
      if (e.response?.data is Map) {
        final data = e.response!.data as Map;
        errorMessage = data['message']?.toString() ??
            data['error']?.toString() ??
            'Error $statusCode: ${e.response?.statusMessage}';
      } else if (e.response?.statusMessage != null) {
        errorMessage = 'Error $statusCode: ${e.response?.statusMessage}';
      } else {
        errorMessage = e.message ?? 'Unknown server error';
      }

      await _recordSyncFailure(txId: txId, error: errorMessage, statusCode: statusCode);
      _logErrorToBackend(txNumber: txNumber, error: errorMessage, statusCode: statusCode);
      return SyncResult.serverError(statusCode, errorMessage);
    } catch (e) {
      final err = e.toString();
      await _recordSyncFailure(txId: txId, error: err, statusCode: 500);
      return SyncResult.serverError(500, err);
    }
  }

  Future<void> _recordSyncFailure({
    required String txId,
    required String error,
    int? statusCode,
  }) async {
    final tx = await (_database.select(_database.transactions)
          ..where((t) => t.id.equals(txId)))
        .getSingleOrNull();
    final currentAttempts = (tx?.syncAttempts ?? 0) + 1;
    final isPermanentFailure = statusCode == 422 || currentAttempts >= 3;

    await (_database.update(_database.transactions)
          ..where((t) => t.id.equals(txId)))
        .write(TransactionsCompanion(
          syncStatus: Value(isPermanentFailure ? 'failed' : 'pending'),
          syncAttempts: Value(currentAttempts),
          lastSyncError: Value(error),
          lastSyncAttemptAt: Value(DateTime.now()),
        ));
  }

  Future<void> _logErrorToBackend({
    required String txNumber,
    required String error,
    int? statusCode,
  }) async {
    try {
      await _dioClient.dio.post(
        ApiEndpoints.logsError,
        data: {
          'error': 'Gagal sinkronisasi transaksi $txNumber (HTTP $statusCode): $error',
          'app_version': '1.0.0',
          'device_info': {'transaction_number': txNumber, 'status_code': statusCode},
        },
      );
    } catch (_) {
      // Ignore background diagnostic logging failure
    }
  }

  /// Mendapatkan jumlah transaksi yang belum tersinkron
  Future<String?> getLastTransactionId() async {
    final tx =
        await (_database.select(_database.transactions)
              ..orderBy([
                (t) => OrderingTerm(
                  expression: t.createdAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    return tx?.id;
  }

  Future<int> getUnsyncedTransactionsCount() async {
    final countRows = await (_database.select(
      _database.transactions,
    )..where((t) => t.isOffline.equals(true))).get();
    return countRows.length;
  }

  /// Mendapatkan daftar transaksi yang belum tersinkron
  Future<List<Transaction>> getUnsyncedTransactions() async {
    return await (_database.select(
      _database.transactions,
    )..where((t) => t.isOffline.equals(true))).get();
  }

  /// Mendapatkan daftar transaksi yang gagal sinkron (Dead-Letter Queue)
  Future<List<Transaction>> getFailedTransactions() async {
    return await (_database.select(
      _database.transactions,
    )..where((t) => t.isOffline.equals(true) & t.syncStatus.equals('failed'))).get();
  }

  /// Memantau jumlah transaksi yang gagal sinkron secara realtime
  Stream<int> watchFailedTransactionsCount() {
    return (_database.select(_database.transactions)
          ..where((t) => t.isOffline.equals(true) & t.syncStatus.equals('failed')))
        .watch()
        .map((rows) => rows.length);
  }

  /// Memantau jumlah transaksi yang belum tersinkron (pending / syncing) secara realtime
  Stream<int> watchUnsyncedTransactionsCount() {
    return (_database.select(_database.transactions)
          ..where((t) => t.isOffline.equals(true) & t.syncStatus.isNotValue('synced')))
        .watch()
        .map((rows) => rows.length);
  }

  /// Memasukkan pemrosesan antrean transaksi ke latar belakang secara non-blocking (FIFO).
  /// Memastikan UI kasir tetap responsif (< 20 ms commit SQLite) untuk mendukung kasir cepat.
  void enqueueSyncQueue() {
    if (_isSyncQueueRunning) {
      debugPrint('[TransactionQueue] Antrean sinkronisasi sudah sedang berjalan di background.');
      return;
    }
    unawaited(syncPendingTransactions());
  }

  /// Mendapatkan jumlah transaksi yang berstatus pending (antrean aktif yang siap dikirim)
  Future<int> getUnsyncedPendingCount({bool includeFailed = false}) async {
    final rows = await (_database.select(_database.transactions)
          ..where((t) {
            final isOfflineMatch = t.isOffline.equals(true);
            if (includeFailed) {
              return isOfflineMatch;
            }
            return isOfflineMatch & t.syncStatus.isNotValue('failed');
          }))
        .get();
    return rows.length;
  }

  /// Sinkronisasi seluruh antrean transaksi lokal pending secara berurutan (FIFO).
  /// Dilindungi mutex (_isSyncQueueRunning & _activeSyncCompleter) untuk mencegah
  /// pemrosesan ganda / race condition saat banyak transaksi terjadi cepat.
  Future<int> syncPendingTransactions({bool force = false}) async {
    if (_isSyncQueueRunning) {
      if (_activeSyncCompleter != null) {
        return await _activeSyncCompleter!.future;
      }
      return 0;
    }

    _isSyncQueueRunning = true;
    final completer = Completer<int>();
    _activeSyncCompleter = completer;

    int totalSynced = 0;
    try {
      // 1. Sinkronkan antrean shift & cash log terlebih dahulu jika ShiftRepository tersedia
      if (_shiftRepository != null) {
        try {
          await _shiftRepository.syncPendingShifts();
          await _shiftRepository.syncPendingCashLogs();
        } catch (e) {
          debugPrint('[TransactionQueue] Gagal menyinkronkan shift/cash log: $e');
        }
      }

      // 2. Loop memproses antrean transaksi pending secara berurutan (FIFO: ORDER BY createdAt ASC).
      // Jika saat proses ada transaksi baru yang masuk ke database SQLite lokal,
      // loop ini akan otomatis memprosesnya hingga antrean pending habis atau jaringan offline.
      while (true) {
        final syncedCount = await _executePendingTransactionsBatch(force: force);
        totalSynced += syncedCount;

        final remainingPending = await getUnsyncedPendingCount(includeFailed: force);
        if (remainingPending == 0 || syncedCount == 0) {
          break;
        }
      }

      completer.complete(totalSynced);
      return totalSynced;
    } catch (e, stack) {
      completer.completeError(e, stack);
      rethrow;
    } finally {
      _isSyncQueueRunning = false;
      _activeSyncCompleter = null;
    }
  }

  /// Eksekusi satu batch transaksi pending terurut createdAt ASC (FIFO)
  Future<int> _executePendingTransactionsBatch({bool force = false}) async {
    final unsynced = await (_database.select(_database.transactions)
          ..where((t) {
            final isOfflineMatch = t.isOffline.equals(true);
            if (force) {
              return isOfflineMatch;
            }
            return isOfflineMatch & t.syncStatus.isNotValue('failed');
          })
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc),
          ]))
        .get();

    if (unsynced.isEmpty) return 0;

    int successCount = 0;
    for (final tx in unsynced) {
      final details = await getTransactionDetails(tx.id);
      if (details == null) continue;

      final itemsPayload = <Map<String, dynamic>>[];
      for (final item in details.items) {
        final mods = details.modifiersByItemId[item.id] ?? [];
        final modPayload = mods
            .map(
              (m) => {
                'modifier_option_id': null,
                'modifier_name': m.modifierName,
                'price': m.price,
                'qty': m.qty,
              },
            )
            .toList();

        bool isTrackInventory = false;
        if (item.inventoryItemId != null) {
          final inv = await (_database.select(_database.inventories)
                ..where((i) => i.id.equals(item.inventoryItemId!)))
              .getSingleOrNull();
          isTrackInventory = inv?.trackInventory ?? false;
        }

        itemsPayload.add({
          'product_id': item.productId,
          'product_item_id': item.productItemId,
          'inventory_item_id': isTrackInventory ? item.inventoryItemId : null,
          'track_inventory': isTrackInventory,
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

      final payment = details.payments.isNotEmpty
          ? details.payments.first
          : null;
      if (payment == null) continue;

      final result = await _syncTransactionOnline(
        txId: tx.id,
        txNumber: tx.transactionNumber,
        shiftId: tx.shiftId,
        customerId: tx.customerId,
        subtotal: tx.subtotal,
        discountAmount: tx.discountAmount,
        discountType: tx.discountType,
        discountValue: tx.discountValue,
        promoName: tx.promoName,
        promoId: details.promo?.promoId,
        taxAmount: tx.taxAmount,
        serviceChargeAmount: tx.serviceChargeAmount,
        total: tx.total,
        itemsPayload: itemsPayload,
        paymentMethodId: payment.paymentMethodId ?? 'cash',
        paymentAmount: payment.amount,
        changeAmount: payment.changeAmount,
        notes: tx.notes,
        channel: tx.channel,
        type: tx.type,
      );

      if (result.outcome == SyncOutcome.success) {
        successCount++;
      } else if (result.outcome == SyncOutcome.networkOffline) {
        // Hentikan pemrosesan batch saat jaringan offline
        break;
      } else {
        // Anti Head-of-Line Blocking:
        // Jika server menolak transaksi ini (422/500), lanjutkan ke transaksi berikutnya!
        continue;
      }
    }
    return successCount;
  }

  /// Manual retry untuk transaksi tertentu yang sebelumnya gagal sinkron
  Future<bool> retryTransaction(String transactionId) async {
    await (_database.update(_database.transactions)
          ..where((t) => t.id.equals(transactionId)))
        .write(const TransactionsCompanion(
          syncStatus: Value('pending'),
          syncAttempts: Value(0),
        ));

    final details = await getTransactionDetails(transactionId);
    if (details == null) return false;

    final tx = details.transaction;
    final itemsPayload = <Map<String, dynamic>>[];
    for (final item in details.items) {
      final mods = details.modifiersByItemId[item.id] ?? [];
      final modPayload = mods
          .map(
            (m) => {
              'modifier_option_id': null,
              'modifier_name': m.modifierName,
              'price': m.price,
              'qty': m.qty,
            },
          )
          .toList();

      bool isTrackInventory = false;
      if (item.inventoryItemId != null) {
        final inv = await (_database.select(_database.inventories)
              ..where((i) => i.id.equals(item.inventoryItemId!)))
            .getSingleOrNull();
        isTrackInventory = inv?.trackInventory ?? false;
      }

      itemsPayload.add({
        'product_id': item.productId,
        'product_item_id': item.productItemId,
        'inventory_item_id': isTrackInventory ? item.inventoryItemId : null,
        'track_inventory': isTrackInventory,
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
    if (payment == null) return false;

    final result = await _syncTransactionOnline(
      txId: tx.id,
      txNumber: tx.transactionNumber,
      shiftId: tx.shiftId,
      customerId: tx.customerId,
      subtotal: tx.subtotal,
      discountAmount: tx.discountAmount,
      discountType: tx.discountType,
      discountValue: tx.discountValue,
      promoName: tx.promoName,
      promoId: details.promo?.promoId,
      taxAmount: tx.taxAmount,
      serviceChargeAmount: tx.serviceChargeAmount,
      total: tx.total,
      itemsPayload: itemsPayload,
      paymentMethodId: payment.paymentMethodId ?? 'cash',
      paymentAmount: payment.amount,
      changeAmount: payment.changeAmount,
      notes: tx.notes,
    );

    return result.outcome == SyncOutcome.success;
  }

  /// Memantau transaksi pada shift yang sedang aktif
  Stream<List<Transaction>> watchCurrentShiftTransactions(String shiftId) {
    return (_database.select(_database.transactions)
          ..where((t) => t.shiftId.equals(shiftId))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Memantau seluruh transaksi lokal (untuk layar Riwayat Transaksi)
  Stream<List<Transaction>> watchAllTransactions({
    String? searchQuery,
    DateTime? date,
    String? channel,
    String? syncStatus,
  }) {
    return (_database.select(_database.transactions)
          ..where((t) {
            Expression<bool> predicate = const Constant(true);
            if (searchQuery != null && searchQuery.isNotEmpty) {
              predicate =
                  predicate & t.transactionNumber.like('%$searchQuery%');
            }
            if (date != null) {
              final startOfDay = DateTime(date.year, date.month, date.day);
              final endOfDay = DateTime(
                date.year,
                date.month,
                date.day,
                23,
                59,
                59,
              );
              predicate =
                  predicate &
                  t.createdAt.isBiggerOrEqualValue(startOfDay) &
                  t.createdAt.isSmallerOrEqualValue(endOfDay);
            }
            if (channel != null && channel.isNotEmpty) {
              predicate = predicate & t.channel.equals(channel);
            }
            if (syncStatus != null && syncStatus.isNotEmpty) {
              if (syncStatus == 'synced') {
                predicate = predicate & t.isOffline.equals(false);
              } else if (syncStatus == 'failed') {
                predicate = predicate & t.syncStatus.equals('failed');
              } else if (syncStatus == 'pending') {
                predicate = predicate & t.isOffline.equals(true) & t.syncStatus.isNotValue('failed');
              }
            }
            return predicate;
          })
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ]))
        .watch();
  }

  /// Memantau ringkasan metode pembayaran
  Stream<List<PaymentMethodSummary>> watchPaymentMethodSummary({
    String? searchQuery,
    DateTime? date,
    String? channel,
  }) {
    final t = _database.transactions;
    final p = _database.transactionPayments;
    final m = _database.paymentMethods;

    // We can use a custom query to group by payment method
    return _database
        .customSelect(
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
        )
        .watch()
        .map((rows) {
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
  Future<TransactionDetailData?> getTransactionDetails(
    String transactionId,
  ) async {
    final tx = await (_database.select(
      _database.transactions,
    )..where((t) => t.id.equals(transactionId))).getSingleOrNull();

    if (tx == null) return null;

    final items = await (_database.select(
      _database.transactionItems,
    )..where((i) => i.transactionId.equals(transactionId))).get();

    final Map<String, List<TransactionItemModifier>> modifiersByItemId = {};
    for (final item in items) {
      final mods = await (_database.select(
        _database.transactionItemModifiers,
      )..where((m) => m.transactionItemId.equals(item.id))).get();
      modifiersByItemId[item.id] = mods;
    }

    final payments = await (_database.select(
      _database.transactionPayments,
    )..where((p) => p.transactionId.equals(transactionId))).get();

    PaymentMethod? paymentMethod;
    if (payments.isNotEmpty && payments.first.paymentMethodId != null) {
      paymentMethod =
          await (_database.select(_database.paymentMethods)
                ..where((m) => m.id.equals(payments.first.paymentMethodId!)))
              .getSingleOrNull();
    }

    final promo = await (_database.select(
      _database.transactionPromos,
    )..where((p) => p.transactionId.equals(transactionId))).getSingleOrNull();

    Customer? customer;
    if (tx.customerId != null) {
      customer = await (_database.select(
        _database.customers,
      )..where((c) => c.id.equals(tx.customerId!))).getSingleOrNull();
    }

    return TransactionDetailData(
      transaction: tx,
      items: items,
      modifiersByItemId: modifiersByItemId,
      payments: payments,
      promo: promo,
      paymentMethod: paymentMethod,
      customer: customer,
    );
  }

  /// Memantau metode pembayaran aktif dari master data (prioritas localSortOrder lalu sortOrder pusat)
  Stream<List<PaymentMethod>> watchActivePaymentMethods() {
    return (_database.select(_database.paymentMethods)
          ..where((m) => m.isActive.equals(true))
          ..orderBy([
            (m) => OrderingTerm(
              expression: coalesce([m.localSortOrder, m.sortOrder]),
              mode: OrderingMode.asc,
            ),
            (m) => OrderingTerm(expression: m.name, mode: OrderingMode.asc),
          ]))
        .watch();
  }

  /// Memperbarui urutan lokal metode pembayaran di database SQLite
  Future<void> updatePaymentMethodsLocalOrder(List<String> orderedIds) async {
    await _database.transaction(() async {
      for (int i = 0; i < orderedIds.length; i++) {
        await (_database.update(_database.paymentMethods)
              ..where((m) => m.id.equals(orderedIds[i])))
            .write(PaymentMethodsCompanion(localSortOrder: Value(i)));
      }
    });
  }

  /// Mereset urutan lokal metode pembayaran kembali ke aturan pusat
  Future<void> resetPaymentMethodsLocalOrder() async {
    await (_database.update(
      _database.paymentMethods,
    )).write(const PaymentMethodsCompanion(localSortOrder: Value(null)));
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
              final endOfEndDay = DateTime(
                p.endDate!.year,
                p.endDate!.month,
                p.endDate!.day,
                23,
                59,
                59,
              );
              if (endOfEndDay.isBefore(now)) return false;
            }
            return true;
          }).toList();
        });
  }

  /// Memantau data pelanggan
  Stream<List<Customer>> watchCustomers() {
    return (_database.select(
      _database.customers,
    )..orderBy([(c) => OrderingTerm(expression: c.name)])).watch();
  }
}

class PaymentMethodSummary {
  final String methodName;
  final double totalAmount;
  final int count;

  PaymentMethodSummary(this.methodName, this.totalAmount, this.count);
}
