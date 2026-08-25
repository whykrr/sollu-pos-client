import 'dart:convert';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

// --- Win32 Spooler Types and Structs ---
final class DocInfo1W extends ffi.Struct {
  external ffi.Pointer<Utf16> pDocName;
  external ffi.Pointer<Utf16> pOutputFile;
  external ffi.Pointer<Utf16> pDatatype;
}

typedef _OpenPrinterWNative = ffi.Int32 Function(
  ffi.Pointer<Utf16> pPrinterName,
  ffi.Pointer<ffi.IntPtr> phPrinter,
  ffi.Pointer<ffi.Void> pDefault,
);
typedef _OpenPrinterWDart = int Function(
  ffi.Pointer<Utf16> pPrinterName,
  ffi.Pointer<ffi.IntPtr> phPrinter,
  ffi.Pointer<ffi.Void> pDefault,
);

typedef _StartDocPrinterWNative = ffi.Uint32 Function(
  ffi.IntPtr hPrinter,
  ffi.Uint32 level,
  ffi.Pointer<DocInfo1W> pDocInfo,
);
typedef _StartDocPrinterWDart = int Function(
  int hPrinter,
  int level,
  ffi.Pointer<DocInfo1W> pDocInfo,
);

typedef _StartPagePrinterNative = ffi.Int32 Function(ffi.IntPtr hPrinter);
typedef _StartPagePrinterDart = int Function(int hPrinter);

typedef _WritePrinterNative = ffi.Int32 Function(
  ffi.IntPtr hPrinter,
  ffi.Pointer<ffi.Uint8> pBuf,
  ffi.Uint32 cbBuf,
  ffi.Pointer<ffi.Uint32> pcWritten,
);
typedef _WritePrinterDart = int Function(
  int hPrinter,
  ffi.Pointer<ffi.Uint8> pBuf,
  int cbBuf,
  ffi.Pointer<ffi.Uint32> pcWritten,
);

typedef _EndPagePrinterNative = ffi.Int32 Function(ffi.IntPtr hPrinter);
typedef _EndPagePrinterDart = int Function(int hPrinter);

typedef _EndDocPrinterNative = ffi.Int32 Function(ffi.IntPtr hPrinter);
typedef _EndDocPrinterDart = int Function(int hPrinter);

typedef _ClosePrinterNative = ffi.Int32 Function(ffi.IntPtr hPrinter);
typedef _ClosePrinterDart = int Function(int hPrinter);

/// Layanan untuk mengirimkan byte mentah (raw ESC/POS) langsung ke printer Desktop (Windows / macOS / Linux)
/// tanpa melalui proses render grafis/PDF OS Spooler.
class DesktopRawPrinter {
  /// Mengirim raw ESC/POS bytes ke printer lokal/USB sesuai sistem operasi
  static Future<({bool success, String message})> printRawBytes({
    required String printerName,
    required List<int> bytes,
    String docName = 'Struk_Sollu_POS',
  }) async {
    if (bytes.isEmpty) {
      return (success: false, message: 'Data cetak kosong!');
    }

    if (Platform.isMacOS || Platform.isLinux) {
      return _printMacOsOrLinux(printerName: printerName, bytes: bytes);
    } else if (Platform.isWindows) {
      return _printWindows(
        printerName: printerName,
        bytes: bytes,
        docName: docName,
      );
    } else {
      return (
        success: false,
        message:
            'Platform ${Platform.operatingSystem} tidak mendukung Desktop Raw Printer',
      );
    }
  }

  /// Eksekusi cetak raw bytes pada macOS & Linux via antrean CUPS
  static Future<({bool success, String message})> _printMacOsOrLinux({
    required String printerName,
    required List<int> bytes,
  }) async {
    // 1. Coba piping langsung ke lpr via stdin (Zero disk file I/O, aman dari kendala folder cache sandbox)
    try {
      final process = await Process.start('lpr', [
        '-P',
        printerName,
        '-l',
      ]);

      final errorFuture = process.stderr.transform(utf8.decoder).join();
      final outputFuture = process.stdout.transform(utf8.decoder).join();

      process.stdin.add(bytes);
      await process.stdin.flush();
      await process.stdin.close();

      final exitCode = await process.exitCode;
      if (exitCode == 0) {
        return (
          success: true,
          message: 'Berhasil mengirim perintah cetak ESC/POS ke $printerName',
        );
      }

      final errText = (await errorFuture).trim();
      final outText = (await outputFuture).trim();
      debugPrint('lpr via stdin returned exitCode $exitCode: $errText $outText');
    } catch (e) {
      debugPrint('Process.start lpr failed: $e');
    }

    // 2. Fallback 1: Coba piping langsung ke lp via stdin
    try {
      final process = await Process.start('lp', [
        '-d',
        printerName,
        '-o',
        'raw',
      ]);

      final errorFuture = process.stderr.transform(utf8.decoder).join();
      final outputFuture = process.stdout.transform(utf8.decoder).join();

      process.stdin.add(bytes);
      await process.stdin.flush();
      await process.stdin.close();

      final exitCode = await process.exitCode;
      if (exitCode == 0) {
        return (
          success: true,
          message: 'Berhasil mengirim perintah cetak ESC/POS ke $printerName',
        );
      }

      final errText = (await errorFuture).trim();
      final outText = (await outputFuture).trim();
      debugPrint('lp via stdin returned exitCode $exitCode: $errText $outText');
    } catch (e) {
      debugPrint('Process.start lp failed: $e');
    }

    // 3. Fallback 2: Menggunakan file sementara dengan pembuatan folder eksplisit
    File? tempFile;
    try {
      final tempDir = await getTemporaryDirectory();
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      tempFile = File('${tempDir.path}/raw_spool_$timestamp.bin');
      await tempFile.writeAsBytes(bytes, flush: true);

      ProcessResult result = await Process.run('lpr', [
        '-P',
        printerName,
        '-l',
        tempFile.path,
      ]);

      if (result.exitCode != 0) {
        result = await Process.run('lp', [
          '-d',
          printerName,
          '-o',
          'raw',
          tempFile.path,
        ]);
      }

      if (result.exitCode == 0) {
        return (
          success: true,
          message: 'Berhasil mengirim perintah cetak ESC/POS ke $printerName',
        );
      } else {
        final errText = result.stderr.toString().trim();
        final outText = result.stdout.toString().trim();
        final detail = errText.isNotEmpty ? errText : outText;
        debugPrint('CUPS Spool error ($printerName): $detail');
        return (
          success: false,
          message: 'Gagal mengirim ke printer $printerName: $detail',
        );
      }
    } catch (e) {
      debugPrint('Error writing raw bytes to CUPS printer ($printerName): $e');
      return (
        success: false,
        message: 'Gagal mengirim data cetak ke printer: $e',
      );
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }
  }

  /// Eksekusi cetak raw bytes pada Windows via Win32 Spooler API (RAW Datatype)
  static Future<({bool success, String message})> _printWindows({
    required String printerName,
    required List<int> bytes,
    required String docName,
  }) async {
    try {
      // 1. Coba gunakan Win32 Spooler API via FFI untuk performa cepat dan murni binary
      final ffiResult = _printWindowsViaWin32(
        printerName: printerName,
        bytes: bytes,
        docName: docName,
      );

      if (ffiResult.success) {
        return ffiResult;
      }

      debugPrint(
        'Win32 FFI raw spooling failed, mencoba fallback script: ${ffiResult.message}',
      );

      // 2. Fallback: Menggunakan PowerShell Raw Spooling
      return await _printWindowsViaPowerShell(
        printerName: printerName,
        bytes: bytes,
      );
    } catch (e) {
      debugPrint('Error printing raw bytes on Windows ($printerName): $e');
      return (
        success: false,
        message: 'Gagal mengirim data ke printer Windows: $e',
      );
    }
  }

  /// Menulis langsung ke Windows Print Spooler menggunakan winspool.drv API
  static ({bool success, String message}) _printWindowsViaWin32({
    required String printerName,
    required List<int> bytes,
    required String docName,
  }) {
    ffi.DynamicLibrary? winspool;
    try {
      winspool = ffi.DynamicLibrary.open('winspool.drv');
    } catch (e) {
      return (
        success: false,
        message: 'Tidak dapat memuat winspool.drv: $e',
      );
    }

    final openPrinter = winspool.lookupFunction<
      _OpenPrinterWNative,
      _OpenPrinterWDart
    >('OpenPrinterW');
    final startDocPrinter = winspool.lookupFunction<
      _StartDocPrinterWNative,
      _StartDocPrinterWDart
    >('StartDocPrinterW');
    final startPagePrinter = winspool.lookupFunction<
      _StartPagePrinterNative,
      _StartPagePrinterDart
    >('StartPagePrinter');
    final writePrinter = winspool.lookupFunction<
      _WritePrinterNative,
      _WritePrinterDart
    >('WritePrinter');
    final endPagePrinter = winspool.lookupFunction<
      _EndPagePrinterNative,
      _EndPagePrinterDart
    >('EndPagePrinter');
    final endDocPrinter = winspool.lookupFunction<
      _EndDocPrinterNative,
      _EndDocPrinterDart
    >('EndDocPrinter');
    final closePrinter = winspool.lookupFunction<
      _ClosePrinterNative,
      _ClosePrinterDart
    >('ClosePrinter');

    final pPrinterName = printerName.toNativeUtf16();
    final phPrinter = calloc<ffi.IntPtr>();

    try {
      final openRes = openPrinter(pPrinterName, phPrinter, ffi.Pointer.fromAddress(0));
      if (openRes == 0 || phPrinter.value == 0) {
        return (
          success: false,
          message: 'Gagal membuka printer "$printerName" di Windows Spooler',
        );
      }

      final hPrinter = phPrinter.value;

      final pDocInfo = calloc<DocInfo1W>();
      pDocInfo.ref.pDocName = docName.toNativeUtf16();
      pDocInfo.ref.pOutputFile = ffi.Pointer.fromAddress(0);
      pDocInfo.ref.pDatatype = 'RAW'.toNativeUtf16();

      try {
        final job = startDocPrinter(hPrinter, 1, pDocInfo);
        if (job == 0) {
          closePrinter(hPrinter);
          return (
            success: false,
            message: 'Gagal memulai dokumen RAW pada printer "$printerName"',
          );
        }

        startPagePrinter(hPrinter);

        final uint8Bytes = Uint8List.fromList(bytes);
        final pData = calloc<ffi.Uint8>(uint8Bytes.length);
        pData.asTypedList(uint8Bytes.length).setAll(0, uint8Bytes);

        final pcWritten = calloc<ffi.Uint32>();

        try {
          final writeRes = writePrinter(
            hPrinter,
            pData,
            uint8Bytes.length,
            pcWritten,
          );

          endPagePrinter(hPrinter);
          endDocPrinter(hPrinter);
          closePrinter(hPrinter);

          if (writeRes != 0 && pcWritten.value == uint8Bytes.length) {
            return (
              success: true,
              message: 'Struk ESC/POS berhasil dikirim ke printer "$printerName"',
            );
          } else {
            return (
              success: false,
              message:
                  'Hanya tertulis ${pcWritten.value} dari ${uint8Bytes.length} bytes ke printer "$printerName"',
            );
          }
        } finally {
          calloc.free(pData);
          calloc.free(pcWritten);
        }
      } finally {
        if (pDocInfo.ref.pDocName.address != 0) calloc.free(pDocInfo.ref.pDocName);
        if (pDocInfo.ref.pDatatype.address != 0) calloc.free(pDocInfo.ref.pDatatype);
        calloc.free(pDocInfo);
      }
    } finally {
      calloc.free(pPrinterName);
      calloc.free(phPrinter);
    }
  }

  /// Fallback eksekusi PowerShell untuk mengirim binary raw data ke antrean printer Windows
  static Future<({bool success, String message})> _printWindowsViaPowerShell({
    required String printerName,
    required List<int> bytes,
  }) async {
    File? tempFile;
    try {
      final tempDir = await getTemporaryDirectory();
      if (!await tempDir.exists()) {
        await tempDir.create(recursive: true);
      }
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      tempFile = File('${tempDir.path}/raw_win_$timestamp.bin');
      await tempFile.writeAsBytes(bytes, flush: true);

      final escapedPrinter = printerName.replaceAll('"', '`"');
      final escapedPath = tempFile.path.replaceAll('"', '`"');

      // Membaca file binary dan mengirimkannya via Out-Printer atau Raw Print
      final script = '''
\$printer = "$escapedPrinter"
\$file = "$escapedPath"
if (Get-Printer -Name \$printer -ErrorAction SilentlyContinue) {
    Get-Content -Path \$file -Encoding Byte -Raw | Out-Printer -Name \$printer
    exit 0
} else {
    Write-Error "Printer '\$printer' tidak ditemukan"
    exit 1
}
''';

      final result = await Process.run('powershell', [
        '-NoProfile',
        '-ExecutionPolicy',
        'Bypass',
        '-Command',
        script,
      ]);

      if (result.exitCode == 0) {
        return (
          success: true,
          message: 'Berhasil mengirim data cetak ke printer "$printerName"',
        );
      } else {
        final err = result.stderr.toString().trim();
        return (
          success: false,
          message: 'Fallback spooling Windows gagal: $err',
        );
      }
    } catch (e) {
      return (
        success: false,
        message: 'Gagal fallback cetak Windows: $e',
      );
    } finally {
      if (tempFile != null && await tempFile.exists()) {
        try {
          await tempFile.delete();
        } catch (_) {}
      }
    }
  }
}
