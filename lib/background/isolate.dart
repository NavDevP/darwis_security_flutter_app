
import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:cysecurity/background/apk_hash/functions/apk_scan.dart';
import 'package:cysecurity/database/apk_hash/model/model.dart';
import 'package:cysecurity/database/apk_hash/provider.dart';
import 'package:cysecurity/database/link_scan/model/model.dart';
import 'package:cysecurity/database/link_scan/provider.dart';
import 'package:cysecurity/main.dart';
import 'package:cysecurity/utils/telephony_background.dart';
import 'package:flutter/services.dart';

const String _kPortName = 'background_port';
final _receivePort = ReceivePort();

enum IsolateType {HASH,LINK}

void registerBackgroundIsolate() async {
  IsolateNameServer.removePortNameMapping(_kPortName);
  IsolateNameServer.registerPortWithName(_receivePort.sendPort, _kPortName);
  _receivePort.listen((message) async {
    switch(message['type']){
      case 0:
        ApkHashProvider apk = ApkHashProvider();
        await apk.initializationDone;
        switch (message['upload_type']){
          case 0:
            List<ApkHashModel> list = [];
            for (var data in jsonDecode(message['verdict'])){
              List<int> intList = data['icon'].cast<int>().toList();
              list.add(ApkHashModel(verdict: data['verdict'], scannedOn: DateTime.fromMillisecondsSinceEpoch(data['scannedOn']), packageName: data['packageName'],shaKey: data['shaKey'],md5Key: data['md5Key'],malwareName: data['malwareName'], icon: Uint8List.fromList(intList),name: data['name'], ignored: false));
            }
            await apk.addScannedHash(list);
            break;
          case 1:
            ApkHashModel list;
            var data = jsonDecode(message['verdict']);
            List<int> intList = data['icon'].cast<int>().toList();
            list = ApkHashModel(verdict: data['verdict'], scannedOn: DateTime.fromMillisecondsSinceEpoch(data['scannedOn']), packageName: data['packageName'],shaKey: data['shaKey'],md5Key: data['md5Key'],malwareName: data['malwareName'], icon: Uint8List.fromList(intList),name: data['name'], ignored: false);
            await apk.updateFileScanHash(list);
            break;
          case 2:
            await apk.deleteScannedHash(message['packageName']);
            break;
        }
        break;
      case 1:
        LinkScanProvider link = LinkScanProvider();
        await link.initializationDone;
        if(message['update']) {
          List<LinkScanModel> list = [];
          for (var data in jsonDecode(message['verdict'])){
            list.add(LinkScanModel(verdict: data['verdict'], message: data['message'], scannedOn: DateTime.fromMillisecondsSinceEpoch(data['scannedOn']), link: data['link']));
          }
          await link.updateScannedLink(list);
        }else{
          List<LinkScanModel> list = [];
          for (var data in jsonDecode(message['verdict'])){
            list.add(LinkScanModel(verdict: data['verdict'], message: data['message'], scannedOn: DateTime.fromMillisecondsSinceEpoch(data['scannedOn']), link: data['link']));
          }
          await link.addScannedLink(list);
          scanLinksAdded(list, false);
        }
    }
  });
}
