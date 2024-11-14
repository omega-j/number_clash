import 'package:hive_flutter/hive_flutter.dart';

import '../../../enums/common_enums.dart';

class DataFileTypeAdapter extends TypeAdapter<DataFileType> {
  @override
  final int typeId = 2; // Unique ID for this adapter

  @override
  DataFileType read(BinaryReader reader) {
    return DataFileType.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, DataFileType obj) {
    writer.writeInt(obj.index);
  }
}