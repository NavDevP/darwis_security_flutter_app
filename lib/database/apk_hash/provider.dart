import 'dart:collection';

import 'package:cysecurity/database/apk_hash/model/model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum STATUS {COMPLETE,SCANNING,ERROR,LIMIT_EXCEEDED}
class ApkHashProvider {

  static const String dataBoxName = "apk_hash";
  late Box<ApkHashModel> dataBox;
  Future _doneFuture = Future.value(false);

  ApkHashProvider() {
    _doneFuture = _init();
  }

  Future _init() async {
    dataBox = await Hive.openBox<ApkHashModel>(dataBoxName);
    // dataBox = Hive.box<ApkHashModel>(dataBoxName);
    return true;
  }

  Future get initializationDone => _doneFuture;

  String getBoxName() {
    return dataBoxName;
  }

  Box<ApkHashModel> getBox() {
    return Hive.box<ApkHashModel>(dataBoxName);
  }
  Future getData() async{
    print(dataBox.length);
  }

  Future addScannedHash(List<ApkHashModel> hashes) async{
    for (var data in hashes){
      await dataBox.put(data.packageName,data);
    }
    return true;
  }

  Future updateFileScanHash(ApkHashModel apk) async{
    await dataBox.put(apk.packageName, apk);
  }

  // Future<bool> checkScanned(package) async{
  //   bool? data = dataBox.containsKey(package);
  //   return data;
  // }

  bool hasMalware() {
    return dataBox.values.where((element) => element.verdict == 3).isNotEmpty;
  }

  bool hasMalwareSingle(String packageName) {
    return dataBox.values.where((element) => element.packageName == packageName && element.verdict == 3).isNotEmpty;
  }

  bool hasSafe() {
    return dataBox.values.where((element) => element.verdict == 2).isNotEmpty;
  }

  // Future<List> getChunkedData() async {
  //   List hashes = [];
  //   if (dataBox.isNotEmpty) {
  //     for (var index in dataBox.keys) {
  //       ApkHashModel? apk = dataBox.getAt(index);
  //       hashes.add(apk?.hashKey);
  //     }
  //     print(chunk(hashes, 20));
  //     return chunk(hashes, 20);
  //   }
  //   return hashes;
  // }

  List chunk(List list, int chunkSize) {
    List chunks = [];
    int len = list.length;
    for (var i = 0; i < len; i += chunkSize) {
      int size = i+chunkSize;
      chunks.add(list.sublist(i, size > len ? len : size));
    }
    return chunks;
  }

}