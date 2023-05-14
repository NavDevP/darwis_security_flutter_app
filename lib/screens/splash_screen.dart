import 'package:cysecurity/const/colors.dart';
import 'package:cysecurity/screens/auth/login_register.dart';
import 'package:cysecurity/screens/dashboard/dashboard.dart';
import 'package:cysecurity/screens/onboarding/index.dart';
import 'package:cysecurity/screens/onboarding/permission_page.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../database/onboarding_permission.dart';
import '../database/user_auth/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SplashScreen();

}

 class _SplashScreen extends State<SplashScreen>{

   OnBoardingPermissionProvider permissionProvider = OnBoardingPermissionProvider();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(seconds: 2),(){
      checkData();
    });

  }

  Future checkData() async{
    await permissionProvider.open();
    var data = await permissionProvider.getData();
    await permissionProvider.close();
    if(data != null) {
      if(!await checkUserLogin()){
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GoogleSignin()));
        return;
      }
      if(data.onBoarding == 1){
        if(await getPermissions()){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Dashboard()));
          return;
        }
      }else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PermissionPage()));
        return;
      }
    }
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PermissionPage()));
  }

   Future<bool> checkUserLogin() async{
     UserAuthProvider user = UserAuthProvider();
     await user.initializationDone;
     if(user.dataBox.length > 0){
       return true;
     }
     return false;
   }

   Future<bool> getPermissions() async{
     var systemAlert = Permission.systemAlertWindow;
     if (await systemAlert.isGranted) {
       return getSmsPermission();
     }else {
       await permissionProvider.open();
       var check = await Permission.systemAlertWindow.request();
       if (check.isDenied) {
         return false;
       }
       if (check.isGranted) {
        return getSmsPermission();
       }
     }
     return false;
   }

   Future<bool> getSmsPermission() async{
     var systemAlert = Permission.sms;
     if (await systemAlert.isGranted) {
       return true;
     }else {
       await permissionProvider.open();
       var check = await Permission.sms.request();
       if (check.isDenied) {
         return false;
       }
       if (check.isGranted) {
         return true;
       }
     }
     return false;
   }


   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            // gradient: RadialGradient(
            //   stops: [0.8,0.2],
            //   colors: [
            //     Colors.white,
            //     AppColor.primary
            //   ]
            // )
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo/darwis.png",width: 300,),
              // Text("DARWIS AF",
              //     style: TextStyle(
              //         color: AppColor.primary,
              //         fontSize: 30,
              //         fontWeight: FontWeight.bold)),
              // SizedBox(height: 20),
              // Text("Next Level Security for you ;)")
            ],
          )),
    );
  }
}
