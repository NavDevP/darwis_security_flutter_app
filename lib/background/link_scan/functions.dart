import 'dart:convert';
import 'dart:io';

import 'package:cysecurity/background/other_functions.dart';
import 'package:cysecurity/const/api_urls.dart';
import 'package:cysecurity/database/apk_hash/model/model.dart';
import 'package:cysecurity/database/apk_hash/provider.dart';
import 'package:cysecurity/database/link_scan/model/model.dart';
import 'package:cysecurity/database/link_scan/provider.dart';
import 'package:cysecurity/database/user_auth/provider.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:http/http.dart' as http;

class LinksScanFunctions {


  List<String> getUrls(List<LinkScanModel> list) {
      return list.map((e) => e.link).toList();
  }

  Future scanLinks() async {
    LinkScanProvider link = LinkScanProvider();
    await link.initializationDone;
    List<LinkScanModel> links = link.dataBox.values.where((element) => element.verdict == 0).toList();
    if(links.isNotEmpty) {
      print("Scanning links");
      List data = chunk(links, 20);

      for (List<LinkScanModel> val in data) {
        // print(val);
        var verdict = await getLinkScanResponse(val);
        if(verdict == STATUS.LIMIT_EXCEEDED){
          return false;
        }
        if (verdict != STATUS.ERROR) {
          await link.updateScannedLink(verdict);
        }
      }
      return true;
    }
    return false;
  }

  Future scanLinksOneTime(List<LinkScanModel> links) async {
    LinkScanProvider link = LinkScanProvider();
    await link.initializationDone;
    List data = chunk(links, 20);

    for(List<LinkScanModel> val in data) {
      var verdict = await getLinkScanResponse(val);

      if (verdict != STATUS.ERROR) {
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
    }), headers: {
      HttpHeaders.contentTypeHeader: "application/json",
      HttpHeaders.authorizationHeader: "Bearer ${provider.dataBox.values.first.access_token}"
    });
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
      // TODO: Handle this case.
        break;
      case ResponseStatus.invalidInput:
        return STATUS.ERROR;
      case ResponseStatus.rateLimit:
        // setNewBackgroundTask(scanBack(links), 1, const Duration(hours:24));
        return STATUS.LIMIT_EXCEEDED;
      case ResponseStatus.internalError:
        return STATUS.ERROR;
    }
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
    await FlutterOverlayOtpWindow.showOverlay(height: 1130,width: WindowSize.matchParent,alignment: OverlayAlignment.topCenter,enableDrag: false);
    //
    // FlutterOverlayWindow.overlayListener.listen((_) async{
    //   FlutterOverlayWindow.disposeOverlayListener();
    //   await FlutterOverlayWindow.closeOverlay();
    // });
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