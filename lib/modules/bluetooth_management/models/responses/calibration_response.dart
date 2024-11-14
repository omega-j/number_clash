class CalibrationResponse {
  final bool isSuccessful;
  final int status;
  final int checksum;

  CalibrationResponse({
    required this.isSuccessful,
    required this.status,
    required this.checksum,
  });

  factory CalibrationResponse.fromData(List<int> data) {
    if (data.length != 4 || data[0] != 0x04) {
      throw ArgumentError("Invalid data for CalibrationResponse");
    }

    final status = data[2];
    final checksum = data[3];
    final isSuccessful = (status == 0x00); // Success if status is 0x00

    return CalibrationResponse(
      isSuccessful: isSuccessful,
      status: status,
      checksum: checksum,
    );
  }

  @override
  String toString() {
    return 'Calibration Response - Success: $isSuccessful, Status: $status, Checksum: $checksum';
  }
}
