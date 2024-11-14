class InfoResponse {
  final String serialNumber;
  final int firmwareMajor;
  final int firmwareMinor;
  final double hardwareVersion;
  final String outputType;
  final bool autoNotifyEnabled;
  final int interval;
  final String productID; // Updated to string to hold descriptive name

  InfoResponse({
    required this.serialNumber,
    required this.firmwareMajor,
    required this.firmwareMinor,
    required this.hardwareVersion,
    required this.outputType,
    required this.autoNotifyEnabled,
    required this.interval,
    required this.productID, // Include productID in constructor
  });

  // Factory constructor to parse data and create an InfoResponse instance
  factory InfoResponse.fromData(List<int> data) {
    if (data.length < 19) {
      throw ArgumentError("Invalid data length for InfoResponse");
    }

    // Parse product ID (Byte #3, which is data[2])
    final productID = _decodeProductID(data[2]);

    // Parse serial number (Bytes 4 to 10)
    final serialNumber = String.fromCharCodes(data.sublist(3, 10));

    // Parse firmware version (Bytes 11 and 12)
    final firmwareMajor = data[10];
    final firmwareMinor = data[11];

    // Parse hardware version (Byte 14, in x100 format)
    final hardwareVersion = data[13] / 100.0;

    // Parse output type (Byte 15)
    final outputType = _decodeOutputType(data[14]);

    // Parse auto notify enable/disable (Byte 16)
    final autoNotifyEnabled = data[15] == 0x01;

    // Parse interval (Bytes 17 and 18)
    final interval =
        (data[16] << 8) | data[17]; // Combine two bytes for interval

    return InfoResponse(
      productID: productID,
      serialNumber: serialNumber,
      firmwareMajor: firmwareMajor,
      firmwareMinor: firmwareMinor,
      hardwareVersion: hardwareVersion,
      outputType: outputType,
      autoNotifyEnabled: autoNotifyEnabled,
      interval: interval,
    );
  }

  // Helper method to interpret output type
  static String _decodeOutputType(int value) {
    switch (value) {
      case 0x00:
        return "Digital Output";
      case 0x01:
        return "0-5V Output";
      case 0x02:
        return "4-20mA Output";
      default:
        return "Unknown Output Type";
    }
  }

  // Helper method to map product ID to a human-readable name
  static String _decodeProductID(int value) {
    switch (value) {
      case 0x40:
        return "Fluorometer, Chlorophyll";
      case 0x41:
        return "Fluorometer, PTSA";
      case 0x42:
        return "Fluorometer, CDOM";
      case 0x43:
        return "Fluorometer, BGA";
      case 0x44:
        return "Fluorometer, BGM";
      case 0x45:
        return "Fluorometer, TRYP";
      case 0x46:
        return "Fluorometer, OB";
      case 0x47:
        return "Fluorometer, Rhod";
      case 0x48:
        return "Fluorometer, pAH";
      case 0x49:
        return "Fluorometer, BTEX";
      case 0x50:
        return "Fluorometer, Cust";
      default:
        return "Unknown Product ID";
    }
  }

  @override
  String toString() {
    return 'Product ID: $productID, ' // Product ID now shows descriptive name
        'Serial Number: $serialNumber, '
        'Firmware Version: $firmwareMajor.$firmwareMinor, '
        'Hardware Version: $hardwareVersion, '
        'Output Type: $outputType, '
        'Auto Notify Enabled: $autoNotifyEnabled, '
        'Interval: $interval seconds';
  }
}
