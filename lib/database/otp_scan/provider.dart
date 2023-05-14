import 'package:cysecurity/database/apk_hash/model/model.dart';
import 'package:cysecurity/database/otp_scan/model/model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum STATUS {COMPLETE,SCANNING,ERROR}
class OtpScanProvider {

  static const String dataBoxName = "otp_scan";
  late Box<OtpScanModel> dataBox;
  Future _doneFuture = Future.value(false);

  OtpScanProvider() {
    _doneFuture = _init();
  }

  Future _init() async {
    dataBox = await Hive.openBox<OtpScanModel>(dataBoxName);
    // dataBox = Hive.box<ApkHashModel>(dataBoxName);
    return true;
  }

  Future get initializationDone => _doneFuture;


  Box<OtpScanModel> getBox(){
    return Hive.box<OtpScanModel>(dataBoxName);
  }
  Future getData() async{
    print(dataBox.length);
  }

  Future addNotifiedOtp(OtpScanModel otp) async{
    await dataBox.add(otp);
    return true;
  }
}