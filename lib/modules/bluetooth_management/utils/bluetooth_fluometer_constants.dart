import 'dart:typed_data';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothFluorometerConstants {
  // Base UUID format with "xxxx" placeholder, where "xxxx" will be replaced with specific service IDs
  static const String baseUUID = "0000xxxx-0000-1000-8000-00805F9B34FB";

  // UUID section to replace "xxxx" for the Bluetooth fluorometer service
  static const String serialOverBleServiceUUID =
      "FFE0"; // Replace with actual service ID
  static const String writeCharacteristicUUID =
      "FFE1"; // Example prefix, replace as needed

  // Full Service UUID, with "xxxx" in baseUUID replaced by serialOverBleServiceUUID
  static Guid get serviceUUID {
    String prefix = baseUUID.substring(0, 4);
    String suffix = baseUUID.substring(8);
    return Guid('$prefix$serialOverBleServiceUUID$suffix');
  }

  static Guid get characteristicUUID {
    String prefix = baseUUID.substring(0, 4);
    String suffix = baseUUID.substring(8);
    return Guid('$prefix$writeCharacteristicUUID$suffix');
  }

  // Utility for checksum calculation as a static method
  static int calculateChecksum(List<int> packet) {
    final sum =
        packet.fold(0, (previousValue, element) => previousValue + element);
    return (~sum + 1) & 0xFF; // 8-bit two's complement checksum
  }

  static double parseFloat(List<int> bytes) {
    if (bytes.length != 4) {
      throw ArgumentError("Invalid byte length for parsing float");
    }

    // Create a ByteData view with 4 bytes in big-endian order
    final byteData = ByteData.sublistView(Uint8List.fromList(bytes));
    return byteData.getFloat32(0, Endian.big);
  }

  // Add any other constants or identifiers needed for Bluetooth operations here
  // static const String otherCharacteristicUUID = "00001234-0000-1000-8000-00805F9B34FB";
  // ... add more as needed
}
