class RequestMeasurementCommand {
  static List<int> generateCommand() {
    final packet = [0x03, 0x02];
    final int checksum = calculateChecksum(packet);
    packet.add(checksum);
    return packet;
  }

  static int calculateChecksum(List<int> packet) {
    final sum = packet.fold(0, (prev, element) => prev + element);
    return (~sum + 1) & 0xFF;
  }

  static bool validateResponse(List<int> response) {
    if (response.isEmpty || response[0] != 0x03) return false;
    final responsePacket = response.sublist(0, response.length - 1);
    final expectedChecksum = calculateChecksum(responsePacket);
    return expectedChecksum == response.last;
  }

  // Request validation
  static bool validateCommand(List<int> commandData) {
    return commandData.length == 3 && commandData[0] == 0x03;
  }
}
