import 'package:cysecurity/database/apk_hash/model/model.dart';
import 'package:cysecurity/database/user_auth/model/model.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum AUTH_STATUS {AUTHENTICATED,UNAUTHENTICATED,EXPIRED}
class UserAuthProvider {

  static const String dataBoxName = "user_auth";
  late Box<UserAuthModel> dataBox;
  Future _doneFuture = Future.value(false);

  UserAuthProvider() {
    _doneFuture = _init();
  }

  Future _init() async {
    dataBox = await Hive.openBox<UserAuthModel>(dataBoxName);
    return true;
  }

  Future get initializationDone => _doneFuture;


  Box<UserAuthModel> getBox() {
    return Hive.box<UserAuthModel>(dataBoxName);
  }

  Future<bool> insertToken(UserAuthModel data) async{
    await dataBox.add(data);
    return true;
  }

  Future<bool> deleteUser() async{
    await dataBox.clear();
    return true;
  }

  Future<bool> updateToken(UserAuthModel data) async{
    await dataBox.putAt(0,data);
    return true;
  }

  Future<bool> checkScanned(package) async{
    bool? data = dataBox.containsKey(package);
    print(data);
    return data;
  }

}