import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cysecurity/const/api_urls.dart';
import 'package:fingerprint/app_info.dart';
import 'package:fingerprint/installed_apps.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:http/http.dart' as http;

import '../../../../database/apk_history.dart';

class HashRepository {

  ApkHistoryProvider apk = ApkHistoryProvider();

  static const String _kPortName = 'overlay_port';
  final _receivePort = ReceivePort();
  static const String _kPortNameHome = 'home_port';
  SendPort? homePort;

  Future register() async {
    bool check = IsolateNameServer.registerPortWithName(_receivePort.sendPort, _kPortName);
    _receivePort.listen((message) async {
      await FlutterOverlayWindow.closeOverlay();
      //Aqui se recibe los mensajes del enviados del home al overlay
      print("message overlay: $message");
    });
    return registerPort();
  }

  Future apkList() async {
    await apk.open();
    List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true);
    List<ApkHistory> history = [];
    if(await checkHash()){
      return true;
    }
    print("Scanning");
    for (var element in apps) {
      // await apk.getApp(element.packageName!).then((val) => print(val!.hashKey));
      // await getKey(element).then((value) async{
      //   history.add(ApkHistory.fromMap({"package_name": value['package'],"hash_key": value['value'],"scanned": DateTime.now().toLocal().toString()}));
      // });
    }
    // print("DONE");
    // await apk.insertAll(history);
    await apk.close();
    return true;
  }

  Future checkHash() async {
    await apk.open();
    List hashes = [];
    List<dynamic>? data = await apk.getChunkedData();
    if(data != null) {
      for (List<ApkHistory> d in data) {
        for(ApkHistory apk in d){
          // print(apk.hashKey);
          hashes.add(apk.hashKey);
        }
        if(!await getHashApiResponse(hashes)){
          break;
        }
        hashes = [];
      }
    }
    return true;
    //     .then((value) =>{
    //   if(value != null && value.isNotEmpty){
    //     value.forEach((element) =>
    //     {
    //       hashes.addAll(element.map((ApkHistory val) {
    //         return val.hashKey.toString();
    //       }).toList())
    //     })
    //   }
    // });
    // var [list,chunkSize] = [[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15], 6];
    // list = [...Array(Math.ceil(list.length / chunkSize))].map(_ => list.splice(0,chunkSize))
    // console.log(list);
    // var response = await getHashApiResponse(hashes);
    // return response;
  }

  Future getHashApiResponse(List hashes) async {
    final response = await http.post(Api.hashQuery,
        body: jsonEncode({
          "hash_list": hashes,
        }),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer TOKEN"
        }
    );
    if(response.statusCode == 200) {
      print(jsonDecode(response.body));
      return true;
    }
    return false;
    // showAlert();

  }

  Future getKey(AppInfo app) async {
    var data = await InstalledApps.getSha(app.packageName!);
    return {
      'package': app.packageName!,
      'value': data,
    };
  }

  SendPort? registerPort() {
    homePort = IsolateNameServer.lookupPortByName(_kPortName);
    return homePort;
  }

  Future showAlert() async{
    await FlutterOverlayWindow.showOverlay(
        height: 700,
        enableDrag: true,
        alignment: OverlayAlignment.topCenter
    );
    // Timer(const Duration(seconds: 5), () async{
    //   await FlutterOverlayWindow.closeOverlay();
    // });
  }
}