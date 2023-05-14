import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cysecurity/background/other_functions.dart';
import 'package:cysecurity/const/api_urls.dart';
import 'package:cysecurity/database/apk_hash/model/model.dart';
import 'package:cysecurity/database/apk_hash/provider.dart';
import 'package:cysecurity/database/user_auth/model/model.dart';
import 'package:cysecurity/database/user_auth/provider.dart';
import 'package:cysecurity/main.dart';
import 'package:fingerprint/app_info.dart';
import 'package:fingerprint/installed_apps.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ChunkPara{
  final List list;
  final int size;
  ChunkPara(this.list, this.size);
}

class IsolateModel{
  final List<AppInfo> list;
  IsolateModel(this.list);
}


// void computeHashList(List apps) async{
//   List<AppInfo> appsData = apps[0];
//   SendPort sendPort = apps[1];
//   List<ApkHashModel> result = await  getApkHash(appsData);
//   sendPort.send(result);
// }
//
// Future<List<ApkHashModel>> getApkHash(List<AppInfo> apps) async{
//   List<ApkHashModel> history = [];
//   for (var element in apps) {
//     await getKey(element).then((value) async{
//       history.add(ApkHashModel(name:value['name'],shaKey: value['sha'],md5Key: value['md5'], packageName: value['package'],scannedOn: DateTime.now().toLocal(),icon: value['icon'],verdict: 0));
//     });
//   }
//   return history;
// }
//
Future getKey(AppInfo app) async {
  var shaData = await InstalledApps.getSha(app.packageName!,"SHA-256");
  var md5Data = await InstalledApps.getSha(app.packageName!,"MD5");
  return {
    'package': app.packageName!,
    'sha': shaData,
    'md5': md5Data,
    'name': app.name,
    'icon': app.icon
  };
}

class ApkScan {

  static const String _kPortName = 'overlay_port';
  final _receivePort = ReceivePort();
  static const String _kPortNameHome = 'home_port';
  SendPort? homePort;
  int count = 0;

  late Timer timer;

  Future register() async {
    bool check = IsolateNameServer.registerPortWithName(_receivePort.sendPort, _kPortName);
    _receivePort.listen((message) async {
      // await FlutterOverlayWindow.closeOverlay();
      //Aqui se recibe los mensajes del enviados del home al overlay
      print("message overlay: $message");
    });
    return registerPort();
  }

  Future<bool> apkList() async {
    ApkHashProvider apk = ApkHashProvider();
    await apk.initializationDone;
    List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true,"",true,true);
    List<ApkHashModel> history = [];

    print("Scanning");
    // print(apps.first.packageName);
    // print(apps.first.sha256);


    // final _receivePort = ReceivePort();
    //
    // Isolate.spawn(computeHashList, [apps, _receivePort.sendPort]);
    //
    // _receivePort.listen((message) {
    //   print(message.toString());
    // });

    for (var element in apps) {
        history.add(ApkHashModel(name: element.name!,shaKey: element.sha256!,md5Key: element.md5!, packageName: element.packageName!,scannedOn: DateTime.now().toLocal(),icon: element.icon!,verdict: 0, malwareName: ''));
      // });
    }
    bool done = await apk.addScannedHash(history);

    if(done) return true;
    return false;
    // print("DONE");
    // return chunk(ChunkPara(history.toList(), 20));
  }

  @pragma('vm:entry-point')
  static runCheckHash() async{
   ApkScan().checkHash();
  }

  void checkHash() async {
    ApkHashProvider apk = ApkHashProvider();
    await apk.initializationDone;

    // List<ApkHashModel> hashes = [];
    print("Scanning Started");
    bool isEmpty = apk.dataBox.values.isEmpty;
    if(isEmpty) {
      bool data = await apkList();
      if(data) {
        var completed = await scanHash();
        if(completed){
          //Open Overlay if any malware is found
          checkScanStatus();
        }
      }
    }
    var completed = await scanHash();
    if(completed){
      //Open Overlay if any malware is found
      checkScanStatus();
    }
  }

  Future scanHash() async {
    ApkHashProvider apk = ApkHashProvider();
    await apk.initializationDone;

    List<ApkHashModel> hashes = [];
    var hashData = apk.dataBox.values.where((element) => element.verdict == 0);
    print("Length");
    print(hashData.length);
    if(hashData.isNotEmpty) {
      List data = chunk(ChunkPara(hashData.toList(), 20));
      for(List<ApkHashModel> hashes in data) {
          if (hashes.isNotEmpty) {
            var verdict = await getHashApiResponse(hashes);
            if (verdict == STATUS.LIMIT_EXCEEDED) {
              count = 0;
              return false;
            }
            if (verdict != STATUS.ERROR) {
              await apk.addScannedHash(verdict);
            }
            hashes = [];
          }
      }
      return true;
    }
    return false;
  }

  Future checkHashSingle(String packageName) async {
    ApkHashProvider apk = ApkHashProvider();
    await apk.initializationDone;

    ApkHashModel hash = ApkHashModel(packageName: "", shaKey: "", md5Key: "", scannedOn: DateTime.now(), verdict: 0, icon: Uint8List(0), name: "",malwareName: "");
    // bool check = apk.dataBox.values.where((element) => element.packageName == packageName).isEmpty;
    // if(check) {
      AppInfo data = await InstalledApps.getAppInfo(packageName);
      if (data.packageName != "") {
        await getKey(data).then((value) async {
          hash = ApkHashModel(name: value['name'],
              shaKey: value['sha'],
              md5Key: value['md5'],
              packageName: value['package'],
              scannedOn: DateTime.now().toLocal(),
              icon: value['icon'],
              malwareName: "",
              verdict: 0);
        });
        if (hash.packageName != "") {
          var verdict = await getHashApiResponse([hash]);
          if (verdict != STATUS.ERROR) {
            await apk.addScannedHash(verdict);
          }
        }
        return true;
      }
    // }
    return false;
  }

  Future getHashApiResponse(List<ApkHashModel> hashes) async {

    UserAuthProvider provider = UserAuthProvider();
    await provider.initializationDone;

    final hashesList = toKeyValue(hashes);
    final response = await http.post(Uri.parse(Api.hashQuery),
        body: jsonEncode(hashesList),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer ${provider.dataBox.values.first.access_token}"
        }
    );
    // if(count == 2){
    //   return responseStatus(http.Response("", 429), []);
    // }
    // count = count + 1;
    return responseStatus(response,hashes);
  }

  Future responseStatus(http.Response response,List<ApkHashModel> hashes) async {
    switch(ResponseStatus.fromStatus(response.statusCode)) {
      case ResponseStatus.success:
        var verdict = jsonDecode(response.body);
        return await getVerdict(hashes,verdict);
      case ResponseStatus.unAuthorized:
        bool check = await refreshAndStartHashScan();
        if(check) checkHash();
        return STATUS.ERROR;
      case ResponseStatus.invalidInput:
        return STATUS.ERROR;
      case ResponseStatus.rateLimit:
        setBackgroundHashScan24Hours();
        // setNewBackgroundTask(runCheckHash, 3, const Duration(minutes: 1));
        return STATUS.LIMIT_EXCEEDED;
      case ResponseStatus.internalError:
        setBackgroundHashScan24Hours();
        return STATUS.ERROR;
    }
  }

  Future checkResponseStatus(http.Response response) async {
    switch(ResponseStatus.fromStatus(response.statusCode)) {
      case ResponseStatus.success:
        return STATUS.COMPLETE;
      case ResponseStatus.unAuthorized:
        bool check = await refreshAndStartHashScan();
        if(check) checkFileHash();
        return STATUS.ERROR;
      case ResponseStatus.invalidInput:
        return STATUS.ERROR;
      case ResponseStatus.rateLimit:
        setBackgroundFileHashScan24Hours();
        // setNewBackgroundTask(runCheckHash, 3, const Duration(minutes: 1));
        return STATUS.LIMIT_EXCEEDED;
      case ResponseStatus.internalError:
        setBackgroundFileHashScan24Hours();
        return STATUS.ERROR;
    }
  }

  Future getVerdict(List<ApkHashModel> hashes, Map verdict) async{
    List<ApkHashModel> newHash = [];

    // final length = verdict.length;

    for (var element in hashes) {
    //   // if(verdict['data'].containsKey(element.hashKey)){
        newHash.add(ApkHashModel(name:element.name, packageName: element.packageName, md5Key: element.md5Key, shaKey: element.shaKey, scannedOn: element.scannedOn, verdict: verdict['hash_list']["${hashes.indexOf(element) + 1}"]['verdict'], icon: element.icon, malwareName: verdict['hash_list']["${hashes.indexOf(element) + 1}"]['malware_name']));
      }
    // }
    return newHash;
  }


  Future<bool> refreshAndStartHashScan() async {
    UserAuthProvider provider = UserAuthProvider();
    await provider.initializationDone;
    final response = await http.get(Api.refreshToken,
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer ${provider.dataBox.values.first.refresh_token}"
        }
    );
    if(ResponseStatus.fromStatus(response.statusCode) == ResponseStatus.success){
      var data = jsonDecode(response.body);
      await provider.updateToken(UserAuthModel(access_token: data['access_token'], refresh_token: data['refresh_token'], signedOn: DateTime.now(), access_token_expiry_minutes: data['access_token_expiry_minutes'],refresh_token_expiry_days: data['refresh_token_expiry_days'], name: provider.dataBox.values.first.name,email: provider.dataBox.values.first.email));
      return true;
    }
    return false;
  }

  Future checkFileHash() async {
    ApkHashProvider apk = ApkHashProvider();
    await apk.initializationDone;

    var hashData = apk.dataBox.values.where((element) => element.verdict == 2);
    print("Safe Length");
    print(hashData.length);
    if(hashData.isNotEmpty) {
      // for(ApkHashModel hash in hashData) {
          var jobId = await getHashJobId(hashData.toList()[0]);
          if(jobId == true && jobId != false) {
            checkFileHash();
          }
          if(jobId != true && jobId != false){
            var verdict = await getFileHashApiResponse(hashData.toList()[0],jobId.toString());
            if (verdict == STATUS.LIMIT_EXCEEDED) {
              count = 0;
              return false;
            }
            if (verdict != STATUS.ERROR) {
              timer = Timer.periodic(const Duration(seconds: 20), (timer) async{
                bool data = await checkFileHashStatus(hashData.toList()[0],jobId.toString());
                print(data);
                if(data){
                  checkFileHash();
                  cancelTimer();
                }
              });
              // await apk.updateFileScanHash(verdict);
            }
          }
      // }
      return true;
    }
    return false;
  }

  void cancelTimer() {
    timer.cancel();
  }

  Future getHashJobId(ApkHashModel modal) async {
    ApkHashProvider apk = ApkHashProvider();
    await apk.initializationDone;

    UserAuthProvider provider = UserAuthProvider();
    await provider.initializationDone;

    final response = await http.get(Uri.parse("${Api.hashQuery}/${modal.shaKey}"),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer ${provider.dataBox.values.first.access_token}"
        }
    );

    print(response.body);
    if(response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);
      if(data['verdict'] == 1){
        ApkHashModel newData = ApkHashModel(verdict: data['verdict'],packageName: modal.packageName,shaKey: modal.shaKey,md5Key: modal.md5Key,icon: modal.icon,name: modal.name,malwareName: modal.malwareName, scannedOn: DateTime.now());
        await apk.updateFileScanHash(newData);
        return true;
      }
      return "aweg${data['job_id']}alseghioefaWFGSBLABLA";
    }
    return false;
  }

  Future checkFileHashStatus(ApkHashModel modal,String jobId) async {
    ApkHashProvider apk = ApkHashProvider();
    await apk.initializationDone;

    UserAuthProvider provider = UserAuthProvider();
    await provider.initializationDone;

    final response = await http.get(Uri.parse("https://conventional-eating-application-leave.trycloudflare.com/status/$jobId"),
        headers: {
          HttpHeaders.contentTypeHeader: "application/json",
          HttpHeaders.authorizationHeader: "Bearer ${provider.dataBox.values.first.access_token}"
        }
    );

    // print(response.body);
    var status = await checkResponseStatus(response);
    if(status == STATUS.COMPLETE) {
      var data = jsonDecode(response.body);
      print(data);
      if(JobStatus.fromStatus(data['job_status']) == JobStatus.FILE_ANALYSIS_YET_TO_START){
        ApkHashModel newData = ApkHashModel(verdict: data['verdict'],packageName: modal.packageName,shaKey: modal.shaKey,md5Key: modal.md5Key,icon: modal.icon,name: modal.name,malwareName: modal.malwareName, scannedOn: DateTime.now());
        await apk.updateFileScanHash(newData);
        return true;
      }
      return false;
    }
    return false;
  }

  Future getFileHashApiResponse(ApkHashModel apk,String jobId) async {

    UserAuthProvider provider = UserAuthProvider();
    await provider.initializationDone;

    String file = await InstalledApps.getAppFile(apk.packageName);
    File app = File(file);

    print("FIle Send Started");

    final multipartFile = http.MultipartFile.fromBytes('input_file', app.readAsBytesSync(), filename: apk.packageName);
    final request = http.MultipartRequest("POST",Uri.parse("https://conventional-eating-application-leave.trycloudflare.com/files/"))
    ..files.add(multipartFile)..fields['job_id'] = jobId;

    final responseStream = await request.send();
    print("send");
    final response = await http.Response.fromStream(responseStream);

    print(response.statusCode);
    print(response.body);

    return response;
  }

  SendPort? registerPort() {
    homePort = IsolateNameServer.lookupPortByName(_kPortName);
    return homePort;
  }

  Future showAlert() async{
    // await FlutterOverlayWindow.showOverlay(
    //     height: 700,
    //     enableDrag: true,
    //     alignment: OverlayAlignment.topCenter
    // );
    // Timer(const Duration(seconds: 5), () async{
    //   await FlutterOverlayWindow.closeOverlay();
    // });
  }

  List chunk(ChunkPara data) {
    List chunks = [];
    int len = data.list.length;
    for (var i = 0; i < len; i += data.size) {
      int size = i+data.size;
      chunks.add(data.list.sublist(i, size > len ? len : size));
    }
    return chunks;
  }

  Map<String, dynamic> toKeyValue(List<ApkHashModel> array) {
    Map<String, dynamic> object = {
      "hash_list": { for (var entry in array.asMap().entries) (entry.key + 1).toString() : {"md5": entry.value.md5Key,"sha256": entry.value.shaKey} },
    };
    return object;
  }

}