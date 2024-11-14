class UpdateDateTimeCommand {
  static List<int> generateCommand({
    required int year,
    required int month,
    required int day,
    required int hour,
    required int minute,
    required int second,
  }) {
    final packet = [0x02, 0x08, year, month, day, hour, minute, second];
    final int checksum = calculateChecksum(packet);
    packet.add(checksum);
    return packet;
  }

  static int calculateChecksum(List<int> packet) {
    final sum = packet.fold(0, (prev, element) => prev + element);
    return (~sum + 1) & 0xFF;
  }

  static bool validateResponse(List<int> response) {
    if (response.isEmpty || response[0] != 0x02) return false;
    final responsePacket = response.sublist(0, response.length - 1);
    final expectedChecksum = calculateChecksum(responsePacket);
    return expectedChecksum == response.last;
  }

  // Request validation
  static bool validateCommand(List<int> commandData) {
    return commandData.length == 9 &&
           commandData[0] == 0x02;
  }
}