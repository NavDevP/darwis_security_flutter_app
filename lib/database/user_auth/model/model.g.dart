// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAuthModelAdapter extends TypeAdapter<UserAuthModel> {
  @override
  final int typeId = 1;

  @override
  UserAuthModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAuthModel(
      access_token: fields[0] as String,
      refresh_token: fields[1] as String,
      signedOn: fields[2] as DateTime,
      access_token_expiry_minutes: fields[3] as int,
      name: fields[5] as String,
      email: fields[6] as String,
      refresh_token_expiry_days: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, UserAuthModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.access_token)
      ..writeByte(1)
      ..write(obj.refresh_token)
      ..writeByte(2)
      ..write(obj.signedOn)
      ..writeByte(3)
      ..write(obj.access_token_expiry_minutes)
      ..writeByte(4)
      ..write(obj.refresh_token_expiry_days)
      ..writeByte(5)
      ..write(obj.name)
      ..writeByte(6)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAuthModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
