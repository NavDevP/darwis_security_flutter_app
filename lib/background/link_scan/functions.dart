import 'dart:convert';
import 'dart:isolate';
import 'dart:ui';

import 'package:cysecurity/background/link_scan/api_response.dart';
import 'package:cysecurity/background/other_functions.dart';
import 'package:cysecurity/const/api_urls.dart';
import 'package:cysecurity/const/constants.dart';
import 'package:cysecurity/database/apk_hash/provider.dart';
import 'package:cysecurity/database/link_scan/model/model.dart';
import 'package:cysecurity/database/link_scan/provider.dart';
import 'package:cysecurity/database/user_auth/model/model.dart';
import 'package:cysecurity/database/user_auth/provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class LinksScanFunctions {

  static const String _kPortName = 'background_port';
  SendPort? homePort;


  List<String> getUrls(List<LinkScanModel> list) {
      return list.map((e) => e.link).toList();
  }

  Future scanLinks() async {
    LinkScanProvider link = LinkScanProvider();
    await link.initializationDone;
    List<LinkScanModel> links = link.dataBox.values.where((element) => element.verdict == LinkVerdict.SCAN_REQUIRED.value).toList();
    if(links.isNotEmpty) {
      List data = chunk(links, 20);

      for (List<LinkScanModel> val in data) {
        var verdict = await getLinkScanResponse(val);
        if(verdict == STATUS.LIMIT_EXCEEDED){
          return false;
        }
        if (verdict != STATUS.ERROR) {
          updateLinkScanResponse(verdict);
        }
      }
      return true;
    }
    return false;
  }

  void updateLinkScanResponse(List verdict) {
    SendPort? sendPort = IsolateNameServer.lookupPortByName(_kPortName);
    sendPort?.send({"verdict":jsonEncode(verdict.map((e) => e.toJson()).toList()),"update":true,"type": 1});
  }

  void addLinkScanResponse(List<LinkScanModel> verdict) {
    SendPort? sendPort = IsolateNameServer.lookupPortByName(_kPortName);
    sendPort?.send({"verdict":jsonEncode(verdict.map((e) => e.toJson()).toList()),"update":false,"type": 1});
  }

  Future scanLinksOneTime(List<LinkScanModel> links) async {
    LinkScanProvider link = LinkScanProvider();
    await link.initializationDone;
    List data = chunk(links, 20);

    for(List<LinkScanModel> val in data) {
      var verdict = await getLinkScanResponse(val);

      if (verdict != STATUS.ERROR) {
        addLinkScanResponse(verdict);
        await link.addScannedLink(verdict);
      }

    }
    return true;
  }


  Future getLinkScanResponse(List<LinkScanModel> links) async{
    UserAuthProvider provider = UserAuthProvider();
    await provider.initializationDone;

    final response = await http.post(Api.linkScan,body: jsonEncode({
      "urls": getUrls(links)
    }), headers: headers(provider.dataBox.values.first.access_token));
    if(response.statusCode == 200){
      return responseStatus(response, links);
    }
  }

  Future responseStatus(http.Response response,List<LinkScanModel> links) async {
    switch(ResponseStatus.fromStatus(response.statusCode)) {
      case ResponseStatus.success:
        var verdict = jsonDecode(response.body);
        return await getVerdict(links,verdict);
      case ResponseStatus.unAuthorized:
        bool check = await refreshAndStartHashScan();
        if(check) scanLinks();
        return STATUS.ERROR;
      case ResponseStatus.invalidInput:
        return STATUS.ERROR;
      case ResponseStatus.rateLimit:
        setBackgroundFileLinkScan24Hours();
        return STATUS.LIMIT_EXCEEDED;
      case ResponseStatus.internalError:
        return STATUS.ERROR;
    }
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

  Future getVerdict(List<LinkScanModel> links, Map verdict) async{
    List<LinkScanModel> linksList = [];

    for (var element in links) {
      if(verdict.entries.where((el) => el.key == Uri.encodeFull(element.link)).isNotEmpty) {
        linksList.add(LinkScanModel(verdict: verdict.entries
            .where((el) => el.key == Uri.encodeFull(element.link))
            .first
            .value,
            message: '',
            link: element.link,
            scannedOn: DateTime.now()));
      }
    }

    return linksList;
  }


  Future openLinkOverLay() async{
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.show(
      notificationId+2,
      'Spam Link (Darwis)',
      'Spam links detected, click to check',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "${notificationChannelId}Link",
          'Darwis',
          ongoing: false,
        ),
      ),
    );
  }

  List chunk(List<LinkScanModel> data, int length) {
    List chunks = [];
    int len = data.length;
    for (var i = 0; i < len; i += length) {
      int size = i+length;
      chunks.add(data.sublist(i, size > len ? len : size));
    }
    return chunks;
  }
}