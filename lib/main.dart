import 'dart:async';
import 'dart:isolate';
import 'dart:ui';

import 'package:cysecurity/background/apk_hash/utils/hash_bloc.dart';
import 'package:cysecurity/background/apk_hash/utils/repository/hash_repository.dart';
import 'package:cysecurity/const/theme.dart';
import 'package:cysecurity/background/apk_hash/functions/apk_scan.dart';
import 'package:cysecurity/const/variables.dart';
import 'package:cysecurity/screens/auth/utils/auth_bloc.dart';
import 'package:cysecurity/screens/auth/utils/repository/auth_repository.dart';
import 'package:cysecurity/screens/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  // Required to ensure everything is up and running before background service
  WidgetsFlutterBinding.ensureInitialized();
  //Start the flutter background service.
  await initializeService();
  await getPermissions();
  runApp(const MyApp());
}

@pragma("vm:entry-point")
void overlayMain() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
      ExcludeSemantics(
        excluding: true,
        child: MultiRepositoryProvider(
            providers: [
              RepositoryProvider<HashRepository>(create: (context) => HashRepository()),
            ],
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                    create: (context) => HashBloc(
                      hashRepository: RepositoryProvider.of<HashRepository>(context),
                    )),
              ],
              child: MaterialApp(
              debugShowCheckedModeBanner: false,
              home: Material(
                color: Colors.transparent,
                child: BlocBuilder<HashBloc, HashState>(
                    builder: (context, state) {
                      SendPort? port;
                      if(state is Nothing){
                        context.read<HashBloc>().add(IsolateRegisterRequested());
                      }
                      if(state is IsolateRegistered){
                        port = state.port;
                        print("REgi");
                        context.read<HashBloc>().add(HashScanRequested());
                      }
                      if(state is HashListEmpty){
                        print("emp");
                        context.read<HashBloc>().add(ApkScanRequested());
                      }
                      if(state is HashScanComplete){
                        print("c");
                        // context.read<HashBloc>().add(ApkScanRequested());
                      }
                      if(state is ApkScanComplete){
                        print("appc");
                        context.read<HashBloc>().add(HashScanRequested());
                      }
                      if(state is IsolateError){
                        print(state.error);
                      }
                      if(state is HashScanError){
                        print(state.error);
                      }
                      if(state is ApkScanError){
                        print(state.error);
                      }
                      if(state is LoadingHash){
                        print("Loading");
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                                "https://cdn-icons-png.flaticon.com/512/556/556261.png",
                                width: 100),
                            const SizedBox(height: 20),
                            const Text("MALWARE DETECTED", style: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                MaterialButton(onPressed: () => print("Click"),
                                    color: Colors.red,
                                    child: const Text("Check",
                                      style: TextStyle(color: Colors.white),)),
                                MaterialButton(onPressed: () => port!.send("texto"),
                                    color: Colors.white,
                                    child: const Text("Close",
                                      style: TextStyle(color: Colors.black),)),
                              ],
                            )
                          ],
                        ),
                      );
                    })
              ),
        )
            )
        ))
    );
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
      androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,

      isForegroundMode: true,

      initialNotificationTitle: 'DARWIS SECURITY',
      initialNotificationContent: "You're protected",
  ), iosConfiguration: IosConfiguration()
  );
}

Future<void> onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  //Apk scan Class calling apk list function to scan apk hashes.
  // SchedulerBinding.instance.addPostFrameCallback((_) {
  //   BlocProvider.of<HashBloc>(NavigationService.navigatorKey.currentContext!).add(IsolateRegisterRequested());
  // });

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AuthRepository>(create: (context) => AuthRepository()),
          // RepositoryProvider<HashRepository>(create: (context) => HashRepository()),
        ],
        child: MultiBlocProvider(
                providers: [
                    BlocProvider(
                    create: (context) => AuthBloc(
                      authRepository:
                      RepositoryProvider.of<AuthRepository>(context),
                    )),
                    // BlocProvider(
                    //   create: (context) => HashBloc(
                    //     hashRepository: RepositoryProvider.of<HashRepository>(context),
                    //   )),
                ],
                child: MaterialApp(
                  debugShowCheckedModeBanner: false,
                  navigatorKey: NavigationService.navigatorKey,
                  title: Variables.appName,
                  theme: MyThemes.getTheme(),
                  // home: const SignInDemo(),
                  // home: GoogleSignin(),
                  home: Dashboard(),
            )
        )
    );
  }
}

Future getPermissions() async{
  var permission = Permission.systemAlertWindow;
  if (await permission.isGranted) {
  }else {
      await Permission.systemAlertWindow.request();
  }
}

class NavigationService {
  static GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();
}