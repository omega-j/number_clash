enum ProductID {
  fluorometerChlorophyll(0x40),
  fluorometerPTSA(0x41),
  fluorometerCDOM(0x42),
  fluorometerBGA(0x43),
  fluorometerBGM(0x44),
  fluorometerTRYP(0x45),
  fluorometerOB(0x46),
  fluorometerRhod(0x47),
  fluorometerPAH(0x48),
  fluorometerBTEX(0x49),
  fluorometerCust(0x50);

  final int value;

  const ProductID(this.value);

  static ProductID? fromValue(int value) {
    return ProductID.values.firstWhere(
      (product) => product.value == value,
      orElse: () => ProductID.fluorometerCust, // Default case, choose a default enum value
    );
  }
}

enum CommandType {
  getInfo,
  updateDate,
  requestMeasurement,
  calibration,
  autoNotify,
}

enum ResponseType {
  info,
  dateUpdate,
  measurement,
  calibration,
  autoNotify,
}

// Connection status codes:
enum BleConnectionStatusCode {
  idle, // Initial state or after disconnection.
  scanning, // Actively scanning for devices.
  scanCompleted, // Scan finished, ready to connect.
  connecting, // Attempting to connect to a selected device.
  connected, // Successfully connected.
  disconnected, // Successfully disconnected.
  reconnecting, // Trying to re-establish connection after loss.
  connectionFailed, // Connection attempt failed.
  connectionLost, // Connection lost unexpectedly.
}
