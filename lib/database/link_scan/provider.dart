import 'package:cysecurity/database/link_scan/model/model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LinkScanProvider {

  static const String dataBoxName = "link_scan";
  late Box<LinkScanModel> dataBox;
  Future _doneFuture = Future.value(false);

  LinkScanProvider() {
    _doneFuture = _init();
  }

  Future _init() async {
    dataBox = await Hive.openBox<LinkScanModel>(dataBoxName);
    // dataBox = Hive.box<ApkHashModel>(dataBoxName);
    return true;
  }

  Future get initializationDone => _doneFuture;

  Box<LinkScanModel> getBox(){
    return Hive.box<LinkScanModel>(dataBoxName);
  }

  Future getData() async{
    print(dataBox.length);
  }

  Future addScannedLink(List<LinkScanModel> data) async{
    await dataBox.addAll(data);
    return true;
  }

  Future updateScannedLink(List<LinkScanModel> data) async{
    for(LinkScanModel l in data) {
      int index = dataBox.values.toList().indexWhere((element) => element.link == l.link);
      await dataBox.putAt(index,l);
    }
    return true;
  }
}