import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:cysecurity/background/apk_hash/api_reponse.dart';
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

enum HashScanType {HASH_SCAN, APK_UPLOAD}

class ApkScan {

  static const String _kPortName = 'background_port';
  SendPort? homePort;
  int count = 0;

  Timer? timer;

  Future<bool> apkList() async {
    ApkHashProvider apk = ApkHashProvider();
    await apk.initializationDone;
    List<AppInfo> apps = await InstalledApps.getInstalledApps(true, true,"",true,true);
    List<ApkHashModel> history = [];

    for (var element in apps) {
        history.add(ApkHashModel(name: element.name!,shaKey: element.sha256!,md5Key: element.md5!, packageName: element.packageName!,scannedOn: DateTime.now().toLocal(),icon: element.icon!,verdict: HashVerdict.SCAN_REQUIRED.value, malwareName: '', ignored: false));
    }
    bool done = await apk.addScannedHash(history);

    if(done) return true;
    return false;
  }


  void checkHash() async {
    ApkHashProvider apk = ApkHashProvider();
    await apk.initializationDone;
    bool isEmpty = apk.dataBox.values.isEmpty;
    if(isEmpty) {
      bool data = await apkList();
      if(data) {
        var completed = await scanHash();
        if(completed){
          //Open Overlay if any malware is found
          checkScanStatus();
        }
        return;
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

    var hashData = apk.dataBox.values.where((element) => element.verdict == HashVerdict.SCAN_REQUIRED.value);
    if(hashData.isNotEmpty) {
      List data = chunk(ChunkPara(hashData.toList(), 20));
      List<ApkHashModel> allVerdict = [];
      for(List<ApkHashModel> hashes in data) {
          if (hashes.isNotEmpty) {
            var verdict = await getHashApiResponse(hashes);
            if (verdict == STATUS.LIMIT_EXCEEDED) {
              count = 0;
              return false;
            }
            if (verdict != STATUS.ERROR) {
              allVerdict.addAll(verdict);
            }
            hashes = [];
          }
      }
      if(allVerdict.isNotEmpty) {
        await apk.addScannedHash(allVerdict);
        updateApkScanResponse(allVerdict,0);
      }
      return true;
    }
    return false;
  }

  Future checkHashSingle(String packageName) async {
    ApkHashProvider apk = ApkHashProvider();
    await apk.initializationDone;
    var exists = apk.dataBox.values.where((element) => element.packageName == packageName);
    if(exists.isNotEmpty && !exists.first.ignored){
      var verdict = await getHashApiResponse([exists.first]);
      if (verdict != STATUS.ERROR) {
        updateApkScanResponse(verdict,0);
      }
      return true;
    }

    ApkHashModel hash = ApkHashModel(packageName: "", shaKey: "", md5Key: "", scannedOn: DateTime.now(), verdict: HashVerdict.SCAN_REQUIRED.value, icon: Uint8List(0), name: "",malwareName: "", ignored: false);
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
              verdict: 0, ignored: false);
        });
        if (hash.packageName != "") {
          var verdict = await getHashApiResponse([hash]);
          if (verdict != STATUS.ERROR) {
            updateApkScanResponse(verdict,0);
          }
        }
        return true;
      }
    return false;
  }

  Future getHashApiResponse(List<ApkHashModel> hashes) async {

    UserAuthProvider provider = UserAuthProvider();
    await provider.initializationDone;

    final hashesList = toKeyValue(hashes);
    final response = await http.post(Uri.parse(Api.hashQuery),
        body: jsonEncode(hashesList),
        headers: headers(provider.dataBox.values.first.access_token)
    );
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
        return STATUS.LIMIT_EXCEEDED;
      case ResponseStatus.internalError:
        setBackgroundFileHashScan24Hours();
        return STATUS.ERROR;
    }
  }

  Future<List<ApkHashModel>> getVerdict(List<ApkHashModel> hashes, Map verdict) async{
    List<ApkHashModel> newHash = [];

    for (var element in hashes) {
      newHash.add(ApkHashModel(name:element.name, packageName: element.packageName, md5Key: element.md5Key, shaKey: element.shaKey, scannedOn: element.scannedOn, verdict: verdict['hash_list']["${hashes.indexOf(element) + 1}"]['verdict'], icon: element.icon, malwareName: verdict['hash_list']["${hashes.indexOf(element) + 1}"]['malware_name'], ignored: false));
    }
    return newHash;
  }


  void updateApkScanResponse(verdict,int type) async {
    ApkHashProvider apk = ApkHashProvider();
    await apk.initializationDone;
    SendPort? sendPort = IsolateNameServer.lookupPortByName(_kPortName);
    if(sendPort != null) {
      var data;
      if(verdict is List<ApkHashModel>){
        data = jsonEncode(verdict.map((e) => e.toJson()).toList());
      }
      if(verdict is ApkHashModel){
        data = jsonEncode(verdict.toJson());
      }
      sendPort.send({"verdict": data, "upload_type": type,"type": 0});
    }
    switch (type){
      case 1:
        await apk.updateFileScanHash(verdict);
        break;
      case 0:
        await apk.addScannedHash(verdict);
        break;
    }
  }


  void deleteScanApk(packageName) async {
    ApkHashProvider apk = ApkHashProvider();
    await apk.initializationDone;
    SendPort? sendPort = IsolateNameServer.lookupPortByName(_kPortName);
    if(sendPort != null) {
      sendPort.send({"packageName": packageName, "upload_type": 2,"type": 0});
    }
    await apk.deleteScannedHash(packageName);
  }


  Future<bool> refreshAndStartHashScan() async {
    UserAuthProvider provider = UserAuthProvider();
    await provider.initializationDone;
    final response = await http.get(Api.refreshToken,
        headers: headers(provider.dataBox.values.first.refresh_token)
    );
    if(ResponseStatus.fromStatus(response.statusCode) == ResponseStatus.success){
      var data = jsonDecode(response.body);
      await provider.updateToken(UserAuthModel(access_token: data['access_token'], refresh_token: data['refresh_token'], signedOn: DateTime.now(), access_token_expiry_minutes: data['access_token_expiry_minutes'],refresh_token_expiry_days: data['refresh_token_expiry_days'], name: provider.dataBox.values.first.name,email: provider.dataBox.values.first.email, avatar: provider.dataBox.values.first.avatar));
      return true;
    }
    return false;
  }

  Future checkFileHash() async {
    ApkHashProvider apk = ApkHashProvider();
    await apk.initializationDone;
    List<ApkHashModel> hashData = [];
    hashData = apk.dataBox.values.where((element) => element.verdict == HashVerdict.NEED_UPLOAD.value).toList();
    if(hashData.isNotEmpty) {
      var jobId = await getHashJobId(hashData.toList()[0]);
      if(jobId is bool) {
        checkFileHash();
      }
      if(jobId is String){
        var verdict = await getFileHashApiResponse(hashData.toList()[0],jobId.toString());
        if (verdict == STATUS.LIMIT_EXCEEDED) {
          return false;
        }
        if (verdict != STATUS.ERROR) {
          if(timer == null) {
            runTimer(hashData.toList()[0], jobId.toString());
          }else {
            if (!timer!.isActive) {
              runTimer(hashData.toList()[0], jobId.toString());
            }
          }
        }
      }
      return true;
    }
    return false;
  }

  void runTimer(hashData,jobId) {
    timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      bool data = await checkFileHashStatus(hashData,jobId);
      print(data);
      if(data){
        checkFileHash();
        cancelTimer();
      }
    });
  }

  void cancelTimer() {
    timer?.cancel();
  }

  Future getHashJobId(ApkHashModel modal) async {
    ApkHashProvider apk = ApkHashProvider();
    await apk.initializationDone;

    UserAuthProvider provider = UserAuthProvider();
    await provider.initializationDone;

    final response = await http.get(Uri.parse("${Api.hashQuery}/${modal.shaKey}"),
        headers: headers(provider.dataBox.values.first.access_token)
    );

    print(response.body);
    if(response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(data);
      if(data['verdict'] != HashVerdict.NEED_UPLOAD.value){
        ApkHashModel newData = ApkHashModel(verdict: data['verdict'],packageName: modal.packageName,shaKey: modal.shaKey,md5Key: modal.md5Key,icon: modal.icon,name: modal.name,malwareName: modal.malwareName, scannedOn: DateTime.now(), ignored: false);
        await apk.updateFileScanHash(newData);
        return true;
      }
      return "QWET${data['job_id']}WE5TGG";
    }
    return false;
  }

  Future checkFileHashStatus(ApkHashModel modal,String jobId) async {
    ApkHashProvider apk = ApkHashProvider();
    await apk.initializationDone;

    UserAuthProvider provider = UserAuthProvider();
    await provider.initializationDone;

    final response = await http.get(Uri.parse("${Api.checkJobStatus}$jobId"),
        headers: headers(provider.dataBox.values.first.access_token)
    );

    // print(response.body);
    var status = await checkResponseStatus(response);
    if(status == STATUS.COMPLETE) {
      var data = jsonDecode(response.body);
      print(data);
      if(JobStatus.fromStatus(data['job_status']) == JobStatus.FILE_ANALYSIS_COMPLETED){
        ApkHashModel newData = ApkHashModel(verdict: data['verdict'],packageName: modal.packageName,shaKey: modal.shaKey,md5Key: modal.md5Key,icon: modal.icon,name: modal.name,malwareName: modal.malwareName, scannedOn: DateTime.now(), ignored: false);
        updateApkScanResponse(newData,1);
        // await apk.updateFileScanHash(newData);
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

    final multipartFile = http.MultipartFile.fromBytes('input_file', app.readAsBytesSync(), filename: apk.packageName);
    final request = http.MultipartRequest("POST",Api.uploadJobFile)
    ..files.add(multipartFile)..fields['job_id'] = jobId;

    final responseStream = await request.send();
    final response = await http.Response.fromStream(responseStream);

    return response;
  }

  SendPort? registerPort() {
    homePort = IsolateNameServer.lookupPortByName(_kPortName);
    return homePort;
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