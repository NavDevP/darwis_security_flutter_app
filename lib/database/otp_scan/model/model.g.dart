// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OtpScanModelAdapter extends TypeAdapter<OtpScanModel> {
  @override
  final int typeId = 2;

  @override
  OtpScanModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OtpScanModel(
      sender: fields[0] as String,
      notifiedOn: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, OtpScanModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.sender)
      ..writeByte(1)
      ..write(obj.notifiedOn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OtpScanModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
