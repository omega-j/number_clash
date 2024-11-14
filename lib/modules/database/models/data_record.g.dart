// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DataRecordAdapter extends TypeAdapter<DataRecord> {
  @override
  final int typeId = 0;

  @override
  DataRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DataRecord(
      id: fields[0] as String,
      fileName: fields[1] as String,
      filePath: fields[2] as String,
      measurementType: fields[3] as MeasurementType,
      fileType: fields[4] as DataFileType,
      creationDate: fields[5] as DateTime,
      metadata: (fields[6] as Map).cast<String, dynamic>(),
      data: (fields[7] as Map?)?.cast<String, dynamic>(),
      isMarkedForDeletion: fields[8] as bool,
      binaryData: fields[9] as Uint8List?,
    );
  }

  @override
  void write(BinaryWriter writer, DataRecord obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.fileName)
      ..writeByte(2)
      ..write(obj.filePath)
      ..writeByte(3)
      ..write(obj.measurementType)
      ..writeByte(4)
      ..write(obj.fileType)
      ..writeByte(5)
      ..write(obj.creationDate)
      ..writeByte(6)
      ..write(obj.metadata)
      ..writeByte(7)
      ..write(obj.data)
      ..writeByte(8)
      ..write(obj.isMarkedForDeletion)
      ..writeByte(9)
      ..write(obj.binaryData);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DataRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
