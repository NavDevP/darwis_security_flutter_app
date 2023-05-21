import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 0)
class ApkHashModel{
  @HiveField(0)
  final String packageName;
  @HiveField(1)
  final String shaKey;
  @HiveField(2)
  final String md5Key;
  @HiveField(3)
  final DateTime scannedOn;
  @HiveField(4)
  final Uint8List icon;
  @HiveField(5)
  final int verdict;
  @HiveField(6)
  final String name;
  @HiveField(7)
  final String malwareName;
  @HiveField(8)
  final bool ignored;

  ApkHashModel({required this.packageName, required this.shaKey, required this.md5Key, required this.scannedOn,required this.verdict,required this.icon, required this.name,required this.malwareName,required this.ignored});

  Map<String, dynamic> toJson(){
    return {
      "verdict": verdict,
      "shaKey": shaKey,
      "md5Key": md5Key,
      "scannedOn": scannedOn.millisecondsSinceEpoch,
      "icon": icon,
      "name": name,
      "malwareName": malwareName,
      "packageName": packageName,
      "ignored": ignored,
    };
  }

}

