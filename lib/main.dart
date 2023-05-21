import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:bg_launcher/bg_launcher.dart';
import 'package:cysecurity/background/apk_hash/api_reponse.dart';
import 'package:cysecurity/background/apk_hash/functions/apk_scan.dart';
import 'package:cysecurity/background/isolate.dart';
import 'package:cysecurity/background/link_scan/api_response.dart';
import 'package:cysecurity/background/link_scan/functions.dart';
import 'package:cysecurity/background/otp_notification/functions.dart';
import 'package:cysecurity/const/constants.dart';
import 'package:cysecurity/const/theme.dart';
import 'package:cysecurity/const/variables.dart';
import 'package:cysecurity/database/apk_hash/provider.dart';
import 'package:cysecurity/database/link_scan/model/model.dart';
import 'package:cysecurity/database/link_scan/provider.dart';
import 'package:cysecurity/database/otp_scan/model/model.dart';
import 'package:cysecurity/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_broadcasts/flutter_broadcasts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:flutter_overlay_window_apk/flutter_overlay_window.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';
import 'package:workmanager/workmanager.dart';

import 'utils/hive.dart';
import 'utils/telephony_background.dart';

void main() async {
  // Required to ensure everything is up and running before background service
  WidgetsFlutterBinding.ensureInitialized();
  //Start the flutter background service.
  await initializeHive();
  initializeFlutterNotification();
  await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false
  );
  registerBackgroundIsolate();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            debugShowCheckedModeBanner: false,
            navigatorKey: NavigationService.navigatorKey,
            title: Variables.appName,
            theme: MyThemes.getTheme(),
            home: const SplashScreen(),
        );
  }
}


@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  //Initialize Hive to access database
  await initializeHive();

  //Register broadcast for App installed detect service
  registerBroadcastReceiver();

  //Initial App Hash Scan function
  ApkScan hash = ApkScan();
  hash.checkHash();
  // hash.checkFileHash();

  startTelephony();

  await Workmanager().registerPeriodicTask(
      checkAllVerdict,
      checkAllVerdict,
      initialDelay: const Duration(hours: 24),
  );
}

void registerBroadcastReceiver() async {
  BroadcastReceiver receiver = BroadcastReceiver(
    names: <String>[apkInstallReceiver,apkUninstallInstallReceiver],
  );
  receiver.messages.listen((value) async{
    if(value.name == apkUninstallInstallReceiver){
      ApkScan hash = ApkScan();
      hash.deleteScanApk(value.data!['package']);
    }else if(value.name == apkInstallReceiver){
      ApkScan hash = ApkScan();
      var completed = await hash.checkHashSingle(value.data!['package']);
      if(completed){
        checkScanStatusSingle(value.data!['package']);
      }
    }
  });
  receiver.start();

}

@pragma('vm:entry-point') // Mandatory if the App is obfuscated or using Flutter 3.1+
void callbackDispatcher() async{
  await initializeHive();
  Workmanager().executeTask((task, inputData) {
    switch (task) {
      case hashScan:
        ApkScan().checkHash();
        break;
      case hashScanFile:
        ApkScan().checkFileHash();
        break;
      case checkAllVerdict:
        ApkScan().checkHash();
        ApkScan().checkFileHash();
        LinksScanFunctions().scanLinks();
        break;
    }
    return Future.value(true);
  });
}

Future checkScanStatus() async{
  var provider = ApkHashProvider();
  await provider.initializationDone;
  if(provider.hasMalware()){
    int count = provider.dataBox.values.where((element) => element.verdict == HashVerdict.MALWARE.value).length;
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.show(
      notificationId+1,
      'Malware Detected',
      "Malware detected in $count app's!!. Click to take action",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "${notificationChannelId}Apk",
          'Darwis',
          ongoing: false,
          priority: Priority.max,
          enableVibration: true,
        ),
      ),
    );
    flutterLocalNotificationsPlugin.show(
      notificationId,
      'DARWIS SECURITY',
      "Malware detected in $count app's!!. Click to take action",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          notificationChannelId,
          'Darwis',
        ),
      ),
    );
    await FlutterOverlayApkWindow.showOverlay(height: 1130,width: WindowSizeApk.matchParent,alignment: OverlayAlignmentApk.topCenter,enableDrag: false);
  }
  if(provider.hasNeedUpload()){
    ApkScan scan = ApkScan();
    scan.checkFileHash();
  }
}

Future checkScanStatusSingle(String packageName) async{
  var provider = ApkHashProvider();
  await provider.initializationDone;
  if(provider.hasMalwareSingle(packageName)){
    // print("Overlay window");
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

    flutterLocalNotificationsPlugin.show(
      notificationId+1,
      'Malware Detected (Darwis Security)',
      "$packageName has malware, click to review",
      const NotificationDetails(
        android: AndroidNotificationDetails(
          "${notificationChannelId}singleApk",
          'Darwis',
          ongoing: false,
        ),
      ),
    );
    await FlutterOverlayApkWindow.showOverlay(height: 1130,width: WindowSizeApk.matchParent,alignment: OverlayAlignmentApk.topCenter,enableDrag: false);
  }
  if(provider.hasNeedUpload()){
    ApkScan scan = ApkScan();
    scan.checkFileHash();
  }
}

void initializeFlutterNotification() async {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidInitializationSettings initializationSettingsAndroid =  AndroidInitializationSettings('splash');

  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    notificationChannelId, // id
    'MY FOREGROUND SERVICE', // title
    description:
    'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        // auto start service
        autoStart: true,
        autoStartOnBoot: true,

        isForegroundMode: true,

        initialNotificationTitle: 'DARWIS SECURITY',
        initialNotificationContent: "You're protected",
        notificationChannelId: notificationChannelId,
        foregroundServiceNotificationId: notificationId
      ), iosConfiguration: IosConfiguration()
  );
}


class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
}

@pragma("vm:entry-point")
void overlayMain() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: MyThemes.getTheme(),
    home: Material(
      color: Colors.transparent,
      child:  Container(
          margin: const EdgeInsets.only(left: 10,right: 10,top: 100),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.transparent
          ),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
              ),
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10)),
                    color: Colors.black12
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                child: Row(
                  children: [
                    Image.asset("assets/images/logo/darwis_logo.png",width: 23),
                    const SizedBox(width: 10),
                    const Text("Darwis",style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle
                  ),
                  child: Image.asset(
                      "assets/images/sheild.png",
                      width: 50)),
              const SizedBox(height: 20),
              const Text("OTP ALERT!", style: TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: const Text("Do not share OTP with anyone until you really know", style: TextStyle(
                      color: Colors.red,
                      fontSize: 15,fontWeight: FontWeight.bold),textAlign: TextAlign.center)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: GestureDetector(child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
                          color: Colors.black87
                      ),
                      child: const Text("Close",
                          style: TextStyle(color: Colors.white))),onTap: () async { await FlutterOverlayOtpWindow.closeOverlay();})),
                  Expanded(child: GestureDetector(child: Container(
                      height: 40,
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(10))
                      ),
                      alignment: Alignment.center,
                      child: const Text("Okay",
                          style: TextStyle(color: Colors.white))),onTap: () async { await FlutterOverlayOtpWindow.closeOverlay();})),
                ],
              )
            ],
          )
          )
      ),
    ),
  ));
}

@pragma("vm:entry-point")
void overlayMainApk() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: MyThemes.getTheme(),
    home: Material(
      color: Colors.transparent,
      child:  Container(
          margin: const EdgeInsets.only(left: 10,right: 10,top: 100),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.transparent
          ),
          child: Container(
              color: Colors.white,
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10)),
                    color: Colors.black12
                ),
                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                child: Row(
                  children: [
                    Image.asset("assets/images/logo/darwis_logo.png",width: 23),
                    const SizedBox(width: 10),
                    const Text("Darwis",style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                      color: Colors.redAccent,
                      shape: BoxShape.circle
                  ),
                  child: Image.asset(
                      "assets/images/sheild.png",
                      width: 50)),
              const SizedBox(height: 20),
              const Text("Malware App's Detected!!", style: TextStyle(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Container(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: const Text("We've found malware app's on your device, click check tot review...", style: TextStyle(
                      color: Colors.red,
                      fontSize: 15,fontWeight: FontWeight.bold),textAlign: TextAlign.center)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: GestureDetector(child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
                          color: Colors.black87
                      ),
                      child: const Text("Close",
                          style: TextStyle(color: Colors.white))),onTap: () async { await FlutterOverlayApkWindow.closeOverlay();})),
                  Expanded(child: GestureDetector(child: Container(
                      height: 40,
                      decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(10))
                      ),
                      alignment: Alignment.center,
                      child: const Text("Check",
                          style: TextStyle(color: Colors.white))),onTap: () async {
                    await FlutterOverlayApkWindow.closeOverlay();
                    BgLauncher.bringAppToForeground();
                  })),
                ],
              )
            ],
          ))
      ),
    ),
  ));
}

RegExp linkRegExp = new RegExp(r'([a-z0-9_\-]{1,5}:\/\/)?(([a-z0-9_\-]{1,}):([a-z0-9_\-]{1,})\@)?((www\.)|([a-z0-9_\-]{1,}\.)+)?([a-z0-9_\-]{3,})(\.[a-z]{2,4})(\/([a-z0-9_\-]{1,}\/)+)?([a-z0-9_\-]{1,})?(\.[a-z]{2,})?(\?)?(((\&)?[a-z0-9_\-]{1,}(\=[a-z0-9_\-]{1,})?)+)?');

@pragma('vm:entry-point')
void startTelephony() async{
  if(Platform.isAndroid && await Permission.sms.isGranted) {
    print("Telephony Started");
    Telephony telephony = Telephony.instance;
    print("Listening");
    telephony.listenIncomingSms(
        onNewMessage: onBackgroundMessage,
        listenInBackground: true,
        onBackgroundMessage: onBackgroundMessage
    );
    print("Listening started");
    print("Inbox started");
    List<SmsMessage> messages = await telephony.getInboxSms();
    if (messages.isNotEmpty) {
      List<LinkScanModel> links = [];
      LinkScanProvider provider = LinkScanProvider();
      await provider.initializationDone;
      if (provider.dataBox.values.isEmpty) {
        for (SmsMessage message in messages) {
          Iterable<RegExpMatch> matches = linkRegExp.allMatches(message.body!);
          if (matches.isNotEmpty) {
            Iterable<RegExpMatch> matchesFiltered = matches.toSet().toList();
            for (var match in matchesFiltered) {
              links.add(LinkScanModel(verdict: LinkVerdict.SCAN_REQUIRED.value,
                  message: "",
                  scannedOn: DateTime.now(),
                  link: message.body!.substring(match.start, match.end)));
            }
          }
        }
        if (links.isNotEmpty) {
          LinksScanFunctions().addLinkScanResponse(uniqueArray(links).toList());
          // await provider.addScannedLink(uniqueArray(links));
          // scanLinksAdded(links, false);
          // print("Links Added");
        }
      } else {
        scanLinksAdded(links, false);
      }
    }
    print("Inbox End");
  }
}

@pragma('vm:entry-point')
void onBackgroundMessage(SmsMessage message) async{
  DartPluginRegistrant.ensureInitialized();
  // print(message.body);
  await initializeHive();
  if(message.body != null && message.body!.isNotEmpty) {
    if (message.body!.contains("OTP") || message.body!.contains("otp") || message.body!.contains("Otp")) {
      OtpFunctions otp = OtpFunctions();
      // Check if the device can vibrate
      CallState state = await Telephony.backgroundInstance.callState;
      if(state == CallState.OFFHOOK) {
        bool canVibrate = await Vibrate.canVibrate;
        if (canVibrate) {
          // Vibrate
          Vibrate.vibrate();
        }
        await FlutterOverlayOtpWindow.showOverlay(height: 1130,
            width: WindowSize.matchParent,
            alignment: OverlayAlignment.topCenter,
            enableDrag: false);
        otp.addOtp(OtpScanModel(sender: message.address!,
            notifiedOn: DateTime.fromMillisecondsSinceEpoch(message.date!)));
      }
    }

    Iterable<RegExpMatch> matches = linkRegExp.allMatches(message.body!);

    List<LinkScanModel> links = [];

    for (var match in matches) {
      links.add(LinkScanModel(verdict: LinkVerdict.SCAN_REQUIRED.value, message: "", scannedOn: DateTime.now(), link: message.body!.substring(match.start, match.end)));
    }
    scanLinksAdded(links,true);
  }
}
