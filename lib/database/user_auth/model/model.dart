import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 1)
class UserAuthModel{
  @HiveField(0)
  final String access_token;
  @HiveField(1)
  final String refresh_token;
  @HiveField(2)
  final DateTime signedOn;
  @HiveField(3)
  final int access_token_expiry_minutes;
  @HiveField(4)
  final int refresh_token_expiry_days;
  @HiveField(5)
  final String name;
  @HiveField(6)
  final String email;

  UserAuthModel({required this.access_token, required this.refresh_token, required this.signedOn, required this.access_token_expiry_minutes, required this.name, required this.email, required this.refresh_token_expiry_days});

}
