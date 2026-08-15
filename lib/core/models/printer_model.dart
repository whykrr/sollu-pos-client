import 'dart:convert';

enum PrinterPaperSize {
  mm58,
  mm80;

  int get paperWidth {
    switch (this) {
      case PrinterPaperSize.mm58:
        return 58;
      case PrinterPaperSize.mm80:
        return 80;
    }
  }

  int get maxCharsPerLine {
    switch (this) {
      case PrinterPaperSize.mm58:
        return 32;
      case PrinterPaperSize.mm80:
        return 48;
    }
  }

  String get label {
    switch (this) {
      case PrinterPaperSize.mm58:
        return '58 mm (32 Karakter)';
      case PrinterPaperSize.mm80:
        return '80 mm (48 Karakter)';
    }
  }
}

enum PrinterConnectionType {
  bluetooth,
  system,
  network;

  String get label {
    switch (this) {
      case PrinterConnectionType.bluetooth:
        return 'Bluetooth';
      case PrinterConnectionType.system:
        return 'USB / Driver OS';
      case PrinterConnectionType.network:
        return 'Network / LAN IP';
    }
  }
}

class PrinterConfig {
  final String name;
  final String address; // MAC address, System Printer URL, or IP
  final PrinterConnectionType connectionType;
  final PrinterPaperSize paperSize;
  final bool autoCut;
  final bool openCashDrawer;
  final String? storeName;
  final String? headerNote;
  final String? footerNote;
  final String? systemPrinterUrl;
  final String? ipAddress;
  final int port;

  const PrinterConfig({
    required this.name,
    required this.address,
    this.connectionType = PrinterConnectionType.bluetooth,
    this.paperSize = PrinterPaperSize.mm58,
    this.autoCut = false,
    this.openCashDrawer = false,
    this.storeName,
    this.headerNote,
    this.footerNote,
    this.systemPrinterUrl,
    this.ipAddress,
    this.port = 9100,
  });

  PrinterConfig copyWith({
    String? name,
    String? address,
    PrinterConnectionType? connectionType,
    PrinterPaperSize? paperSize,
    bool? autoCut,
    bool? openCashDrawer,
    String? storeName,
    String? headerNote,
    String? footerNote,
    String? systemPrinterUrl,
    String? ipAddress,
    int? port,
  }) {
    return PrinterConfig(
      name: name ?? this.name,
      address: address ?? this.address,
      connectionType: connectionType ?? this.connectionType,
      paperSize: paperSize ?? this.paperSize,
      autoCut: autoCut ?? this.autoCut,
      openCashDrawer: openCashDrawer ?? this.openCashDrawer,
      storeName: storeName ?? this.storeName,
      headerNote: headerNote ?? this.headerNote,
      footerNote: footerNote ?? this.footerNote,
      systemPrinterUrl: systemPrinterUrl ?? this.systemPrinterUrl,
      ipAddress: ipAddress ?? this.ipAddress,
      port: port ?? this.port,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'connectionType': connectionType.name,
      'paperSize': paperSize.name,
      'autoCut': autoCut,
      'openCashDrawer': openCashDrawer,
      'storeName': storeName,
      'headerNote': headerNote,
      'footerNote': footerNote,
      'systemPrinterUrl': systemPrinterUrl,
      'ipAddress': ipAddress,
      'port': port,
    };
  }

  factory PrinterConfig.fromMap(Map<String, dynamic> map) {
    return PrinterConfig(
      name: map['name'] as String? ?? 'Thermal Printer',
      address: map['address'] as String? ?? '',
      connectionType: PrinterConnectionType.values.firstWhere(
        (e) => e.name == map['connectionType'],
        orElse: () => PrinterConnectionType.bluetooth,
      ),
      paperSize: PrinterPaperSize.values.firstWhere(
        (e) => e.name == map['paperSize'],
        orElse: () => PrinterPaperSize.mm58,
      ),
      autoCut: map['autoCut'] as bool? ?? false,
      openCashDrawer: map['openCashDrawer'] as bool? ?? false,
      storeName: map['storeName'] as String?,
      headerNote: map['headerNote'] as String?,
      footerNote: map['footerNote'] as String?,
      systemPrinterUrl: map['systemPrinterUrl'] as String?,
      ipAddress: map['ipAddress'] as String?,
      port: (map['port'] as num?)?.toInt() ?? 9100,
    );
  }

  String toJson() => json.encode(toMap());

  factory PrinterConfig.fromJson(String source) =>
      PrinterConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PrinterConfig &&
        other.name == name &&
        other.address == address &&
        other.connectionType == connectionType &&
        other.paperSize == paperSize &&
        other.autoCut == autoCut &&
        other.openCashDrawer == openCashDrawer &&
        other.systemPrinterUrl == systemPrinterUrl &&
        other.ipAddress == ipAddress &&
        other.port == port;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        address.hashCode ^
        connectionType.hashCode ^
        paperSize.hashCode ^
        autoCut.hashCode ^
        openCashDrawer.hashCode ^
        systemPrinterUrl.hashCode ^
        ipAddress.hashCode ^
        port.hashCode;
  }
}

class DiscoveredPrinterInfo {
  final String name;
  final String address;
  final PrinterConnectionType connectionType;
  final bool isDefault;
  final String? location;

  const DiscoveredPrinterInfo({
    required this.name,
    required this.address,
    required this.connectionType,
    this.isDefault = false,
    this.location,
  });
}
