import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sollu_pos_client/core/models/printer_model.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/core/database/app_database.dart';
import 'package:sollu_pos_client/features/pos/data/transaction_repository.dart';
import 'package:sollu_pos_client/features/shift/data/shift_repository.dart';

class ReceiptPdfBuilder {
  /// Mengambil format dimensi kertas PDF berdasarkan lebar area cetak fisik (Printable Area):
  /// - Roll 58mm -> Lebar print head efektif 48mm (384 dots)
  /// - Roll 80mm -> Lebar print head efektif 72mm (576 dots)
  /// Margin diset 0 karena printer fisik & driver OS sudah memiliki margin bawaan.
  static PdfPageFormat _getPageFormat(PrinterPaperSize size) {
    final double widthMm = size == PrinterPaperSize.mm58 ? 48 : 72;
    final double heightMm = size == PrinterPaperSize.mm58 ? 200 : 297;
    return PdfPageFormat(
      widthMm * PdfPageFormat.mm,
      heightMm * PdfPageFormat.mm,
      marginAll: 0 * PdfPageFormat.mm,
    );
  }

  static Future<Uint8List> buildTestReceiptPdf(PrinterConfig config) async {
    final pdf = pw.Document();
    final format = _getPageFormat(config.paperSize);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                config.storeName ?? 'SOLLU POS',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'UJI COBA CETAK STRUK (DESKTOP)',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 8.5,
                ),
              ),
              pw.Text(
                DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 7.5),
              ),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.Text(
                'Status: TERHUBUNG KE SISTEM OS',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 7.5,
                ),
              ),
              pw.Text(
                'Printer: ${config.name}',
                style: const pw.TextStyle(fontSize: 7.5),
              ),
              pw.Text(
                'Tipe: ${config.connectionType.label}',
                style: const pw.TextStyle(fontSize: 7.5),
              ),
              pw.Text(
                'Ukuran Kertas: ${config.paperSize.label}',
                style: const pw.TextStyle(fontSize: 7.5),
              ),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Item Contoh A x1',
                      style: const pw.TextStyle(fontSize: 7.5),
                    ),
                  ),
                  pw.Text('Rp 15.000', style: const pw.TextStyle(fontSize: 7.5)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Item Contoh B x2',
                      style: const pw.TextStyle(fontSize: 7.5),
                    ),
                  ),
                  pw.Text('Rp 20.000', style: const pw.TextStyle(fontSize: 7.5)),
                ],
              ),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8.5,
                      ),
                    ),
                  ),
                  pw.Text(
                    'Rp 35.000',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.Text(
                config.footerNote ??
                    'Printer Desktop siap digunakan untuk transaksi!',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 7.5),
              ),
              pw.SizedBox(height: 8),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> buildTransactionReceiptPdf({
    required TransactionDetailData detail,
    required PrinterConfig config,
    OutletSetting? outletSetting,
    Uint8List? logoBytes,
    String? cashierName,
    String? outletName,
    String? outletAddress,
    String? outletPhone,
  }) async {
    final pdf = pw.Document();
    final format = _getPageFormat(config.paperSize);
    final tx = detail.transaction;

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          final storeTitle = (outletSetting?.customHeaderTitle != null && outletSetting!.customHeaderTitle!.isNotEmpty)
              ? outletSetting.customHeaderTitle!
              : (outletName ?? config.storeName ?? 'SOLLU POS');
          final headerNote = outletSetting?.headerNotes ?? config.headerNote;
          final footerNote = outletSetting?.footerNotes ?? config.footerNote ?? 'Terima Kasih Telah Berbelanja!';

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 1. Logo Toko
              if ((outletSetting?.showLogo ?? true) && logoBytes != null)
                pw.Center(
                  child: pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 6),
                    child: pw.Image(
                      pw.MemoryImage(logoBytes),
                      width: 50,
                      height: 50,
                      fit: pw.BoxFit.contain,
                    ),
                  ),
                ),

              // 2. Header Toko
              pw.Text(
                storeTitle,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if ((outletSetting?.showAddress ?? true) && outletAddress != null && outletAddress.isNotEmpty)
                pw.Text(
                  outletAddress,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 7.5),
                ),
              if ((outletSetting?.showPhone ?? true) && outletPhone != null && outletPhone.isNotEmpty)
                pw.Text(
                  'Telp: $outletPhone',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 7.5),
                ),
              if (headerNote != null && headerNote.isNotEmpty)
                pw.Text(
                  headerNote,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 7.5),
                ),
              if (outletSetting?.wifiInfo != null && outletSetting!.wifiInfo!.isNotEmpty)
                pw.Text(
                  'WiFi: ${outletSetting.wifiInfo}',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 7.5),
                ),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // 2. Info Transaksi
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'No: ${tx.transactionNumber}',
                      style: const pw.TextStyle(fontSize: 7.5),
                    ),
                  ),
                  pw.Text(
                    DateFormat('dd/MM/yy HH:mm').format(tx.createdAt),
                    style: const pw.TextStyle(fontSize: 7.5),
                  ),
                ],
              ),
              if ((outletSetting?.showCashierName ?? true) && cashierName != null && cashierName.isNotEmpty)
                pw.Text(
                  'Kasir: $cashierName',
                  style: const pw.TextStyle(fontSize: 7.5),
                ),
              if ((outletSetting?.showCustomerName ?? true) && detail.customer != null)
                pw.Text(
                  'Pelanggan: ${detail.customer!.name}',
                  style: const pw.TextStyle(fontSize: 7.5),
                ),

              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // 3. Item List
              ...detail.items.map((item) {
                final qtyStr = item.qty % 1 == 0
                    ? item.qty.toInt().toString()
                    : item.qty.toString();
                final priceStr = CurrencyFormatter.format(item.price.toInt());
                final subtotalStr = CurrencyFormatter.format(
                  item.subtotal.toInt(),
                );
                final modifiers = detail.modifiersByItemId[item.id] ?? [];

                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        item.productName,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 8,
                        ),
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              '$qtyStr x $priceStr',
                              style: const pw.TextStyle(fontSize: 7.5),
                            ),
                          ),
                          pw.Text(
                            subtotalStr,
                            style: const pw.TextStyle(fontSize: 7.5),
                          ),
                        ],
                      ),
                      if (outletSetting?.showModifiers ?? true)
                        ...modifiers.map((m) {
                          final modPrice = m.price > 0
                              ? ' (+${CurrencyFormatter.format(m.price.toInt())})'
                              : '';
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 4),
                            child: pw.Text(
                              '+ ${m.modifierName}$modPrice',
                              style: const pw.TextStyle(fontSize: 7),
                            ),
                          );
                        }),
                      if ((outletSetting?.showItemNotes ?? true) && item.notes != null && item.notes!.isNotEmpty)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 4),
                          child: pw.Text(
                            'Catatan: ${item.notes}',
                            style: pw.TextStyle(fontSize: 7, fontStyle: pw.FontStyle.italic),
                          ),
                        ),
                      if (item.discountAmount > 0)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 4),
                          child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Expanded(
                                child: pw.Text(
                                  'Diskon Item',
                                  style: const pw.TextStyle(fontSize: 7),
                                ),
                              ),
                              pw.Text(
                                '-${CurrencyFormatter.format(item.discountAmount.toInt())}',
                                style: const pw.TextStyle(fontSize: 7),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );
              }),

              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // 4. Financial Summary
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text('Subtotal', style: const pw.TextStyle(fontSize: 7.5)),
                  ),
                  pw.Text(
                    CurrencyFormatter.format(tx.subtotal.toInt()),
                    style: const pw.TextStyle(fontSize: 7.5),
                  ),
                ],
              ),
              if (tx.discountAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Diskon ${tx.promoName != null ? "(${tx.promoName})" : ""}',
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                    ),
                    pw.Text(
                      '-${CurrencyFormatter.format(tx.discountAmount.toInt())}',
                      style: const pw.TextStyle(fontSize: 7.5),
                    ),
                  ],
                ),
              if ((outletSetting?.showTaxDetail ?? true) && tx.taxAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Pajak (PB1/PPN)',
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                    ),
                    pw.Text(
                      CurrencyFormatter.format(tx.taxAmount.toInt()),
                      style: const pw.TextStyle(fontSize: 7.5),
                    ),
                  ],
                ),
              if ((outletSetting?.showServiceCharge ?? true) && tx.serviceChargeAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        'Service Charge',
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                    ),
                    pw.Text(
                      CurrencyFormatter.format(tx.serviceChargeAmount.toInt()),
                      style: const pw.TextStyle(fontSize: 7.5),
                    ),
                  ],
                ),

              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // TOTAL
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'TOTAL',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                  ),
                  pw.Text(
                    CurrencyFormatter.format(tx.total.toInt()),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),

              // 5. Pembayaran
              if (detail.payments.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                ...detail.payments.map((p) {
                  final methodName = detail.paymentMethod?.name ?? 'Pembayaran';
                  return pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Text(
                              methodName,
                              style: const pw.TextStyle(fontSize: 7.5),
                            ),
                          ),
                          pw.Text(
                            CurrencyFormatter.format(p.amount.toInt()),
                            style: const pw.TextStyle(fontSize: 7.5),
                          ),
                        ],
                      ),
                      if (p.changeAmount > 0)
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Kembalian',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 7.5,
                                ),
                              ),
                            ),
                            pw.Text(
                              CurrencyFormatter.format(p.changeAmount.toInt()),
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 7.5,
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                }),
              ],

              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // 6. Footer
              pw.Text(
                footerNote,
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 7.5,
                ),
              ),
              if (outletSetting?.socialMediaInfo != null && outletSetting!.socialMediaInfo!.isNotEmpty)
                pw.Text(
                  outletSetting.socialMediaInfo!,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 7),
                ),
              pw.Text(
                'Simpan struk ini sebagai bukti pembayaran yang sah',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 6.5),
              ),
              if (outletSetting?.showQrCode ?? false) ...[
                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: tx.transactionNumber,
                    width: 45,
                    height: 45,
                  ),
                ),
              ],
              pw.SizedBox(height: 8),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> buildShiftReportPdf({
    required ShiftSummary summary,
    required PrinterConfig config,
    String? cashierName,
    String? outletName,
    String? outletAddress,
    String? outletPhone,
  }) async {
    final pdf = pw.Document();
    final format = _getPageFormat(config.paperSize);

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header
              pw.Text(
                outletName ?? config.storeName ?? 'SOLLU POS',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (outletAddress != null && outletAddress.isNotEmpty)
                pw.Text(
                  outletAddress,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 7.5),
                ),
              if (outletPhone != null && outletPhone.isNotEmpty)
                pw.Text(
                  'Telp: $outletPhone',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 7.5),
                ),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.Text(
                'LAPORAN TUTUP SHIFT',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9.5,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Waktu Cetak:',
                      style: const pw.TextStyle(fontSize: 7.5),
                    ),
                  ),
                  pw.Text(
                    DateFormat('dd/MM/yy HH:mm').format(DateTime.now()),
                    style: const pw.TextStyle(fontSize: 7.5),
                  ),
                ],
              ),
              if (cashierName != null && cashierName.isNotEmpty)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text('Kasir:', style: const pw.TextStyle(fontSize: 7.5)),
                    ),
                    pw.Text(
                      cashierName,
                      style: const pw.TextStyle(fontSize: 7.5),
                    ),
                  ],
                ),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // Rincian Modal & Pendapatan
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Modal Awal',
                      style: const pw.TextStyle(fontSize: 7.5),
                    ),
                  ),
                  pw.Text(
                    CurrencyFormatter.format(summary.openingCash.toInt()),
                    style: const pw.TextStyle(fontSize: 7.5),
                  ),
                ],
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Pemasukan per Metode:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 7.5,
                ),
              ),
              ...summary.salesByPaymentMethod.entries.map((entry) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(
                      child: pw.Text(
                        '- ${entry.key}',
                        style: const pw.TextStyle(fontSize: 7.5),
                      ),
                    ),
                    pw.Text(
                      CurrencyFormatter.format(entry.value.toInt()),
                      style: const pw.TextStyle(fontSize: 7.5),
                    ),
                  ],
                );
              }),
              pw.SizedBox(height: 3),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Kas Masuk/Keluar',
                      style: const pw.TextStyle(fontSize: 7.5),
                    ),
                  ),
                  pw.Text(
                    CurrencyFormatter.format(
                      (summary.cashIn - summary.cashOut).toInt(),
                    ),
                    style: const pw.TextStyle(fontSize: 7.5),
                  ),
                ],
              ),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      'Ekspektasi Kas di Laci',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 8.5,
                      ),
                    ),
                  ),
                  pw.Text(
                    CurrencyFormatter.format(summary.expectedCash.toInt()),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 8.5,
                    ),
                  ),
                ],
              ),

              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.Text(
                'Laporan ini dicetak secara otomatis\ndari sistem Sollu POS.',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 6.5),
              ),
              pw.SizedBox(height: 8),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
