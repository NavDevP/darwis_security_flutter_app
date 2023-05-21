import 'dart:typed_data';

import 'package:hive/hive.dart';

part 'model.g.dart';

@HiveType(typeId: 3)
class LinkScanModel{
  @HiveField(0)
  final int verdict;
  @HiveField(1)
  final String message;
  @HiveField(2)
  final String link;
  @HiveField(3)
  final DateTime scannedOn;

  LinkScanModel({required this.verdict, required this.message,required this.scannedOn, required this.link});

  Map<String, dynamic> toJson(){
    return {
      "verdict": verdict,
      "message": message,
      "scannedOn": scannedOn.millisecondsSinceEpoch,
      "link": link
    };
  }

}

