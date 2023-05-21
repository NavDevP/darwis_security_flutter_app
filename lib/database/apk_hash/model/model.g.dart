// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ApkHashModelAdapter extends TypeAdapter<ApkHashModel> {
  @override
  final int typeId = 0;

  @override
  ApkHashModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ApkHashModel(
      packageName: fields[0] as String,
      shaKey: fields[1] as String,
      md5Key: fields[2] as String,
      scannedOn: fields[3] as DateTime,
      verdict: fields[5] as int,
      icon: fields[4] as Uint8List,
      name: fields[6] as String,
      malwareName: fields[7] as String,
      ignored: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ApkHashModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.packageName)
      ..writeByte(1)
      ..write(obj.shaKey)
      ..writeByte(2)
      ..write(obj.md5Key)
      ..writeByte(3)
      ..write(obj.scannedOn)
      ..writeByte(4)
      ..write(obj.icon)
      ..writeByte(5)
      ..write(obj.verdict)
      ..writeByte(6)
      ..write(obj.name)
      ..writeByte(7)
      ..write(obj.malwareName)
      ..writeByte(8)
      ..write(obj.ignored);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ApkHashModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
