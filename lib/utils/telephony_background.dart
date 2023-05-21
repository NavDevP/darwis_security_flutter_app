import 'package:cysecurity/background/link_scan/api_response.dart';
import 'package:cysecurity/background/link_scan/functions.dart';
import 'package:cysecurity/database/link_scan/model/model.dart';
import 'package:cysecurity/database/link_scan/provider.dart';

List<LinkScanModel> uniqueArray(List<LinkScanModel> arr) {
  List<LinkScanModel> newArr = [];
  for (var obj in arr) {
    if (newArr.where((element) => element.link == obj.link).isNotEmpty) {
      continue;
    }
    newArr.add(obj);
  }
  return newArr;
}

Future scanLinksAdded(List<LinkScanModel> links, bool liveScan) async {
  if(links.isNotEmpty) {
    LinksScanFunctions link = LinksScanFunctions();
    var status = liveScan ? await link.scanLinksOneTime(links): await link.scanLinks();
    if(status) {
      LinkScanProvider provider = LinkScanProvider();
      await provider.initializationDone;
      if(provider.dataBox.values.where((element) => element.verdict == LinkVerdict.SPAM.value).isNotEmpty) {
        link.openLinkOverLay();
      }
    }
  }
}