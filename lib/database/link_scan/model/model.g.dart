// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LinkScanModelAdapter extends TypeAdapter<LinkScanModel> {
  @override
  final int typeId = 3;

  @override
  LinkScanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LinkScanModel(
      verdict: fields[0] as int,
      message: fields[1] as String,
      scannedOn: fields[3] as DateTime,
      link: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, LinkScanModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.verdict)
      ..writeByte(1)
      ..write(obj.message)
      ..writeByte(2)
      ..write(obj.link)
      ..writeByte(3)
      ..write(obj.scannedOn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LinkScanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
