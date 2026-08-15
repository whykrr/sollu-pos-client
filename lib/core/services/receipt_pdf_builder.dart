import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sollu_pos_client/core/models/printer_model.dart';
import 'package:sollu_pos_client/core/utils/currency_formatter.dart';
import 'package:sollu_pos_client/features/pos/data/transaction_repository.dart';

class ReceiptPdfBuilder {
  static PdfPageFormat _getPageFormat(PrinterPaperSize size) {
    final double widthMm = size == PrinterPaperSize.mm58 ? 58 : 80;
    return PdfPageFormat(
      widthMm * PdfPageFormat.mm,
      double.infinity,
      marginAll: 4 * PdfPageFormat.mm,
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
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'UJI COBA CETAK STRUK (DESKTOP)',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
              ),
              pw.Text(
                DateFormat('dd/MM/yyyy HH:mm:ss').format(DateTime.now()),
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.Text('Status: TERHUBUNG KE SISTEM OS', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8)),
              pw.Text('Printer: ${config.name}', style: const pw.TextStyle(fontSize: 8)),
              pw.Text('Tipe: ${config.connectionType.label}', style: const pw.TextStyle(fontSize: 8)),
              pw.Text('Ukuran Kertas: ${config.paperSize.label}', style: const pw.TextStyle(fontSize: 8)),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Item Contoh A x1', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text('Rp 15.000', style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Item Contoh B x2', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text('Rp 20.000', style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                  pw.Text('Rp 35.000', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                ],
              ),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.Text(
                config.footerNote ?? 'Printer Desktop siap digunakan untuk transaksi!',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 8),
              ),
              pw.SizedBox(height: 10),
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
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // 1. Header Toko
              pw.Text(
                outletName ?? config.storeName ?? 'SOLLU POS',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13),
              ),
              if (outletAddress != null && outletAddress.isNotEmpty)
                pw.Text(
                  outletAddress,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 8),
                ),
              if (outletPhone != null && outletPhone.isNotEmpty)
                pw.Text(
                  'Telp: $outletPhone',
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 8),
                ),
              if (config.headerNote != null && config.headerNote!.isNotEmpty)
                pw.Text(
                  config.headerNote!,
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 8),
                ),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // 2. Info Transaksi
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('No: ${tx.transactionNumber}', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(
                    DateFormat('dd/MM/yy HH:mm').format(tx.createdAt),
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
              if (cashierName != null && cashierName.isNotEmpty)
                pw.Text('Kasir: $cashierName', style: const pw.TextStyle(fontSize: 8)),

              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // 3. Item List
              ...detail.items.map((item) {
                final qtyStr = item.qty % 1 == 0 ? item.qty.toInt().toString() : item.qty.toString();
                final priceStr = CurrencyFormatter.format(item.price.toInt());
                final subtotalStr = CurrencyFormatter.format(item.subtotal.toInt());
                final modifiers = detail.modifiersByItemId[item.id] ?? [];

                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        item.productName,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5),
                      ),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('$qtyStr x $priceStr', style: const pw.TextStyle(fontSize: 8)),
                          pw.Text(subtotalStr, style: const pw.TextStyle(fontSize: 8)),
                        ],
                      ),
                      ...modifiers.map((m) {
                        final modPrice = m.price > 0 ? ' (+${CurrencyFormatter.format(m.price.toInt())})' : '';
                        return pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 4),
                          child: pw.Text('+ ${m.modifierName}$modPrice', style: const pw.TextStyle(fontSize: 7.5)),
                        );
                      }),
                      if (item.discountAmount > 0)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 4),
                          child: pw.Row(
                            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text('Diskon Item', style: const pw.TextStyle(fontSize: 7.5)),
                              pw.Text('-${CurrencyFormatter.format(item.discountAmount.toInt())}', style: const pw.TextStyle(fontSize: 7.5)),
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
                  pw.Text('Subtotal', style: const pw.TextStyle(fontSize: 8.5)),
                  pw.Text(CurrencyFormatter.format(tx.subtotal.toInt()), style: const pw.TextStyle(fontSize: 8.5)),
                ],
              ),
              if (tx.discountAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Diskon ${tx.promoName != null ? "(${tx.promoName})" : ""}', style: const pw.TextStyle(fontSize: 8.5)),
                    pw.Text('-${CurrencyFormatter.format(tx.discountAmount.toInt())}', style: const pw.TextStyle(fontSize: 8.5)),
                  ],
                ),
              if (tx.taxAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Pajak (PB1/PPN)', style: const pw.TextStyle(fontSize: 8.5)),
                    pw.Text(CurrencyFormatter.format(tx.taxAmount.toInt()), style: const pw.TextStyle(fontSize: 8.5)),
                  ],
                ),
              if (tx.serviceChargeAmount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Service Charge', style: const pw.TextStyle(fontSize: 8.5)),
                    pw.Text(CurrencyFormatter.format(tx.serviceChargeAmount.toInt()), style: const pw.TextStyle(fontSize: 8.5)),
                  ],
                ),

              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // TOTAL
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  pw.Text(
                    CurrencyFormatter.format(tx.total.toInt()),
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
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
                          pw.Text(methodName, style: const pw.TextStyle(fontSize: 8.5)),
                          pw.Text(CurrencyFormatter.format(p.amount.toInt()), style: const pw.TextStyle(fontSize: 8.5)),
                        ],
                      ),
                      if (p.changeAmount > 0)
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text('Kembalian', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
                            pw.Text(
                              CurrencyFormatter.format(p.changeAmount.toInt()),
                              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5),
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
                config.footerNote ?? 'Terima Kasih Telah Berbelanja!',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5),
              ),
              pw.Text(
                'Simpan struk ini sebagai bukti pembayaran yang sah',
                textAlign: pw.TextAlign.center,
                style: const pw.TextStyle(fontSize: 7.5),
              ),
              pw.SizedBox(height: 10),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
