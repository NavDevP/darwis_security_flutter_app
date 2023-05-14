import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 2)
class OtpScanModel{
  @HiveField(0)
  final String sender;
  @HiveField(1)
  final DateTime notifiedOn;

  OtpScanModel({required this.sender, required this.notifiedOn});

}

