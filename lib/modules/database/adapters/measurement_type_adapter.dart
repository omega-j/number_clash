import 'package:hive/hive.dart';
import '../../../../../enums/common_enums.dart';

class MeasurementTypeAdapter extends TypeAdapter<MeasurementType> {
  @override
  final int typeId = 1; // Unique ID for the adapter

  @override
  MeasurementType read(BinaryReader reader) {
    return MeasurementType.values[reader.readInt()];
  }

  @override
  void write(BinaryWriter writer, MeasurementType obj) {
    writer.writeInt(obj.index);
  }
}