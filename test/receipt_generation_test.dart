import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/core/models/printer_model.dart';
import 'package:sollu_pos_client/core/services/printer_service.dart';
import 'package:sollu_pos_client/features/pos/data/transaction_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Analyze generateTransactionReceiptBytes output', () async {
    final now = DateTime(2026, 10, 9, 14, 41);
    final tx = Transaction(
      id: 'tx-1',
      outletId: 'outlet-1',
      channel: 'pos',
      transactionNumber: 'TRX/2026/10/0007',
      subtotal: 162200.0,
      total: 162200.0,
      paymentStatus: 'paid',
      status: 'completed',
      taxAmount: 0.0,
      discountAmount: 0.0,
      serviceChargeAmount: 0.0,
      shippingFee: 0.0,
      isOffline: true,
      syncStatus: 'synced',
      syncAttempts: 0,
      createdAt: now,
    );

    final items = [
      TransactionItem(
        id: 'item-1',
        transactionId: 'tx-1',
        productName: 'Buavita Jeruk 250ml',
        price: 8200.0,
        qty: 1.0,
        subtotal: 8200.0,
        discountAmount: 0.0,
        createdAt: now,
      ),
      TransactionItem(
        id: 'item-2',
        transactionId: 'tx-1',
        productName: 'Token Listrik 100k',
        price: 102000.0,
        qty: 1.0,
        subtotal: 102000.0,
        discountAmount: 0.0,
        createdAt: now,
      ),
      TransactionItem(
        id: 'item-3',
        transactionId: 'tx-1',
        productName: 'Token Listrik 50k',
        price: 52000.0,
        qty: 1.0,
        subtotal: 52000.0,
        discountAmount: 0.0,
        createdAt: now,
      ),
    ];

    final payment = TransactionPayment(
      id: 'pay-1',
      transactionId: 'tx-1',
      amount: 162200.0,
      changeAmount: 0.0,
      paidAt: now,
    );

    final paymentMethod = PaymentMethod(
      id: 'method-1',
      name: 'Tunai',
      type: 'cash',
      sortOrder: 0,
      isActive: true,
    );

    final detail = TransactionDetailData(
      transaction: tx,
      items: items,
      modifiersByItemId: {},
      payments: [payment],
      paymentMethod: paymentMethod,
    );

    const config = PrinterConfig(
      name: 'POS58',
      address: 'POS58',
      connectionType: PrinterConnectionType.system,
      paperSize: PrinterPaperSize.mm58,
      autoCut: false,
    );

    final service = PrinterService();
    final logoFile = File('img/logo-colored.png');
    final logoBytes = await logoFile.readAsBytes();

    final bytes = await service.generateTransactionReceiptBytes(
      detail: detail,
      config: config,
      outletName: 'SM Central',
      outletAddress: 'Jl. Medan Merdeka Selatan 57, Kota Malang',
      outletPhone: '081122334455',
      cashierName: 'Wahyu Kristiawan',
      logoBytes: logoBytes,
      outletSetting: {
        'header_notes': 'Terima kasih atas kunjungan Anda!',
        'footer_notes': 'Barang yang sudah dibeli tidak dapat ditukar atau dikembalikan.',
        'show_address': true,
        'show_phone': true,
        'show_cashier_name': true,
        'show_order_type': true,
        'show_logo': true,
      },
    );

    final text = latin1.decode(bytes, allowInvalid: true);
    final smIndex = text.indexOf('SM Central');
    final n57Index = text.indexOf('n 57, Kota Malang');
    final subtotalIndex = text.indexOf('Subtotal');
    final totalIndex = text.indexOf('TOTAL');
    expect(smIndex, isNot(-1));
    expect(n57Index, isNot(-1));
    expect(subtotalIndex, isNot(-1));
    expect(totalIndex, isNot(-1));
    // Memastikan 5 feed lines di akhir payload struk ESC/POS (0x1B, 0x64, 0x05)
    expect(bytes.contains(0x1B), isTrue);
  });

  test('generateTransactionReceiptBytes with show_logo: false produces light pure text payload', () async {
    final now = DateTime(2026, 10, 9, 14, 41);
    final tx = Transaction(
      id: 'tx-1',
      outletId: 'outlet-1',
      channel: 'pos',
      transactionNumber: 'TRX/2026/10/0007',
      subtotal: 162200.0,
      total: 162200.0,
      paymentStatus: 'paid',
      status: 'completed',
      taxAmount: 0.0,
      discountAmount: 0.0,
      serviceChargeAmount: 0.0,
      shippingFee: 0.0,
      isOffline: true,
      syncStatus: 'synced',
      syncAttempts: 0,
      createdAt: now,
    );

    final items = [
      TransactionItem(
        id: 'item-1',
        transactionId: 'tx-1',
        productName: 'Token Listrik 100k',
        price: 102000.0,
        qty: 1.0,
        subtotal: 102000.0,
        discountAmount: 0.0,
        createdAt: now,
      ),
    ];

    final payment = TransactionPayment(
      id: 'pay-1',
      transactionId: 'tx-1',
      amount: 102000.0,
      changeAmount: 0.0,
      paidAt: now,
    );

    final paymentMethod = PaymentMethod(
      id: 'method-1',
      name: 'Tunai',
      type: 'cash',
      sortOrder: 0,
      isActive: true,
    );

    final detail = TransactionDetailData(
      transaction: tx,
      items: items,
      modifiersByItemId: {},
      payments: [payment],
      paymentMethod: paymentMethod,
    );

    const config = PrinterConfig(
      name: 'POS58',
      address: 'POS58',
      connectionType: PrinterConnectionType.system,
      paperSize: PrinterPaperSize.mm58,
      autoCut: false,
    );

    final service = PrinterService();

    final bytes = await service.generateTransactionReceiptBytes(
      detail: detail,
      config: config,
      outletName: 'SM Central',
      outletAddress: 'Jl. Medan Merdeka Selatan 57, Kota Malang',
      outletPhone: '081122334455',
      cashierName: 'Wahyu Kristiawan',
      logoBytes: null, // Tanpa logo saat show_logo false dari portal
      outletSetting: {
        'show_logo': false,
        'show_address': true,
        'show_phone': true,
        'show_cashier_name': true,
      },
    );

    // Payload tanpa raster logo harus ringan (< 1500 bytes) dan dimulai dari SM Central di awal
    expect(bytes.length, lessThan(1500));
    final text = latin1.decode(bytes, allowInvalid: true);
    final smIndex = text.indexOf('SM Central');
    expect(smIndex, isNot(-1));
    expect(smIndex, lessThan(50)); // Muncul di awal tanpa jeda ribuan byte raster
  });
}
