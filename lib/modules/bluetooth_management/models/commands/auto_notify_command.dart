class AutoNotifyCommand {
  static List<int> createAutoNotifyCommand({
    required bool enable,
    required int interval,
  }) {
    final packet = [0x05, 0x05];
    packet.add(enable ? 0x01 : 0x00);

    if (interval < 1 || interval > 3600) {
      throw ArgumentError('Interval must be between 1 and 3600 seconds.');
    }
    packet.addAll([
      (interval >> 8) & 0xFF,
      interval & 0xFF,
    ]);

    final int checksum = calculateChecksum(packet);
    packet.add(checksum);

    return packet;
  }

  static int calculateChecksum(List<int> packet) {
    final sum = packet.fold(0, (prev, element) => prev + element);
    return (~sum + 1) & 0xFF;
  }

  static bool validateResponse(List<int> response) {
    if (response.isEmpty || response[0] != 0x05) return false;
    final responsePacket = response.sublist(0, response.length - 1);
    final expectedChecksum = calculateChecksum(responsePacket);
    return expectedChecksum == response.last;
  }

  // Request validation
  static bool validateCommand(List<int> commandData) {
    return commandData.length == 6 &&
        commandData[0] == 0x05 &&
        (commandData[3] >= 0x00 && commandData[3] <= 0xFF);
  }
}
