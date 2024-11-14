import 'dart:typed_data';

class CalibrationCommand {
  static List<int> generateCommand({
    required int pointIndex,
    required double concentration,
  }) {
    final packet = [0x04, 0x07, pointIndex];
    final concentrationBytes = ByteData(4)
      ..setFloat32(0, concentration, Endian.big);
    packet.addAll(concentrationBytes.buffer.asUint8List());
    final int checksum = calculateChecksum(packet);
    packet.add(checksum);
    return packet;
  }

  static int calculateChecksum(List<int> packet) {
    final sum = packet.fold(0, (prev, element) => prev + element);
    return (~sum + 1) & 0xFF;
  }

  static bool validateResponse(List<int> response) {
    if (response.isEmpty || response[0] != 0x04) return false;
    final responsePacket = response.sublist(0, response.length - 1);
    final expectedChecksum = calculateChecksum(responsePacket);
    return expectedChecksum == response.last;
  }

  // Request validation
  static bool validateCommand(List<int> commandData) {
    return commandData.length == 8 && commandData[0] == 0x04;
  }
}
