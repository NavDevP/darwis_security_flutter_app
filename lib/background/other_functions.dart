import 'dart:io';
import 'dart:math';

import 'package:workmanager/workmanager.dart';

Future setBackgroundHashScan24Hours() async{
  if (Platform.isAndroid) {
    print("Alarm Starting");
    // One off task registration
    await Workmanager().registerOneOffTask(
      "oneoff-hash-scan",
      "hashScan",
      initialDelay: const Duration(seconds: 10),
      existingWorkPolicy: ExistingWorkPolicy.append
    );
    print("Alarm Started");
  }
}

Future setBackgroundFileHashScan24Hours() async{
  if (Platform.isAndroid) {
    // One off task registration
    await Workmanager().registerOneOffTask(
        "oneoff-file-hash-scan",
        "hashScanFile",
        initialDelay: const Duration(minutes: 15),
        existingWorkPolicy: ExistingWorkPolicy.append
    );
  }
}