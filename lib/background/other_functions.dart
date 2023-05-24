import 'dart:io';

import 'package:cysecurity/const/constants.dart';
import 'package:workmanager/workmanager.dart';

Future setBackgroundHashScan24Hours() async{
  if (Platform.isAndroid) {
    // One off task registration
    await Workmanager().registerOneOffTask(
      "oneoff-hash-scan",
      hashScan,
      initialDelay: const Duration(hours: 24),
      existingWorkPolicy: ExistingWorkPolicy.append
    );
  }
}

Future setBackgroundFileHashScan24Hours() async{
  if (Platform.isAndroid) {
    // One off task registration
    await Workmanager().registerOneOffTask(
        "oneoff-file-hash-scan",
        hashScanFile,
        initialDelay: const Duration(hours: 24),
        existingWorkPolicy: ExistingWorkPolicy.append
    );
  }
}

Future setBackgroundFileLinkScan24Hours() async{
  if (Platform.isAndroid) {
    // One off task registration
    await Workmanager().registerOneOffTask(
        "oneoff-file-link-scan",
        checkAllVerdict,
        initialDelay: const Duration(hours: 24),
        existingWorkPolicy: ExistingWorkPolicy.append
    );
  }
}

Map<String, String> headers(token) {
  return {
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.authorizationHeader: "Bearer $token"
  };
}