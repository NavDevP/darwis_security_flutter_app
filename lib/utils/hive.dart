import 'package:cysecurity/database/apk_hash/model/model.dart';
import 'package:cysecurity/database/apk_hash/provider.dart';
import 'package:cysecurity/database/link_scan/model/model.dart';
import 'package:cysecurity/database/link_scan/provider.dart';
import 'package:cysecurity/database/otp_scan/model/model.dart';
import 'package:cysecurity/database/user_auth/model/model.dart';
import 'package:cysecurity/database/user_auth/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../database/otp_scan/provider.dart';

Future initializeHive() async{
  await Hive.initFlutter();
  if(!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter<ApkHashModel>(ApkHashModelAdapter());
  }
  if(!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter<UserAuthModel>(UserAuthModelAdapter());
  }
  if(!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter<OtpScanModel>(OtpScanModelAdapter());
  }
  if(!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter<LinkScanModel>(LinkScanModelAdapter());
  }
  ApkHashProvider apk = ApkHashProvider();
  UserAuthProvider user = UserAuthProvider();
  OtpScanProvider otp = OtpScanProvider();
  LinkScanProvider link = LinkScanProvider();
  await apk.initializationDone;
  await user.initializationDone;
  await otp.initializationDone;
  await link.initializationDone;
}