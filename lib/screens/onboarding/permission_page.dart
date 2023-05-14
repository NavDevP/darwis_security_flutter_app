import 'dart:async';

import 'package:cysecurity/const/colors.dart';
import 'package:cysecurity/database/onboarding_permission.dart';
import 'package:cysecurity/screens/auth/login_register.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>_PermissionPageState();

}

class _PermissionPageState extends State<PermissionPage> {

  bool smsRequested=false,systemRequested = false;

  OnBoardingPermissionProvider permissionProvider = OnBoardingPermissionProvider();

  Future getPermissions(context) async{
    var sms = Permission.sms;
    if (await sms.isGranted) {
      await systemPermission(context);
    }else {
      await permissionProvider.open();
      var check = await Permission.sms.request();
      if (check.isDenied) {
        _showMyDialog(context);
      }
      if (check.isGranted) {
        smsRequested = true;
        setState(() {});
        Timer(const Duration(seconds: 1),() async => await systemPermission(context));
      }
    }
  }

  Future systemPermission(context) async {
    var systemAlert = Permission.systemAlertWindow;
    if (await systemAlert.isGranted) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => GoogleSignin()));
    }else{
      await permissionProvider.open();
      var check = await Permission.systemAlertWindow.request();
      if (check.isDenied) {
        _showMyDialog(context);
      }
      if (check.isGranted) {
        await permissionProvider.insert(OnBoardingPermission.fromMap({'onboarding_done': 1,'system_alert_permission':1}));
        await permissionProvider.close();
        systemRequested = true;
        setState(() {});
        // Navigator.pushReplacement(
        //     context, MaterialPageRoute(builder: (context) => GoogleSignin()));
      }
    }
  }

  Future<void> _showMyDialog(context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Error'),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Permission Denied!'),
                Text('Please try again.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Okay'),
              onPressed: () {
                Timer(const Duration(seconds: 1),() async => await getPermissions(context));
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(body: SafeArea(child: SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 50),
          const Icon(Icons.fact_check_outlined,size: 150,color: Colors.green),
          const SizedBox(height: 50),
          const Text("We Need Permissions!",style: TextStyle(
              fontFamily: 'Proxima',
              fontSize: 28,
              fontWeight: FontWeight.bold
          )),
          Container(
              margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 20),
              child: const Text("Please grant few required permission's for application to run it's tasks.",
                style: TextStyle(
                    fontFamily: 'Proxima',
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.5
                ),
                textAlign: TextAlign.center,
              )),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.sms_outlined,size: 25,color: AppColor.primary),
                    const SizedBox(width: 20),
                    Expanded(child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("SMS",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                            smsRequested ? const SizedBox(width: 5):const SizedBox(),
                            smsRequested ? const Icon(Icons.verified,color: AppColor.primary,size: 18):const SizedBox()
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text("To protect you from spam messages",style: TextStyle(fontSize: 13,color: Colors.black54)),
                      ],
                    )),
                    // GestureDetector(child: Container(
                    //     padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                    //     decoration: BoxDecoration(
                    //         color: AppColor.primary,
                    //         borderRadius: BorderRadius.circular(5)
                    //     ),
                    //     child: const Text("Allow",style: TextStyle(color: Colors.white,fontSize: 16)
                    //     )),onTap: () async{
                    //   var check = await Permission.sms.request();
                    // }),
                  ],
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.7,
                  child: const Divider(thickness: 1)),
              const SizedBox(height: 5),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                decoration: const BoxDecoration(
                  // color: Colors.white
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.desktop_windows,size: 25,color: AppColor.primary),
                    const SizedBox(width: 20),
                    Expanded(child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text("Display Over Apps",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                            systemRequested ? const SizedBox(width: 5):const SizedBox(),
                            systemRequested ? const Icon(Icons.verified,color: AppColor.primary,size: 18):const SizedBox()
                          ],
                        ),
                        const SizedBox(height: 5),
                        const Text("To alert whenever we detect something suspicious",style: TextStyle(fontSize: 13,color: Colors.black54)),
                      ],
                    )),
                    // GestureDetector(child: Container(
                    //     padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                    //     decoration: BoxDecoration(
                    //         color: AppColor.primary,
                    //         borderRadius: BorderRadius.circular(5)
                    //     ),
                    //     child: const Text("Allow",style: TextStyle(color: Colors.white,fontSize: 16)
                    //     )),onTap: () async{
                    //   var check = await Permission.sms.request();
                    // }),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 40),
          !smsRequested || !systemRequested ? GestureDetector(child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 25),
            decoration: BoxDecoration(
              color: !smsRequested && !systemRequested ? AppColor.primary:AppColor.primary.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10)
            ),
            child: const Text("Allow All Access",style: TextStyle(color: Colors.white,fontFamily: 'Proxima',fontWeight: FontWeight.bold,fontSize: 16)),
          ),onTap: (){
            if(!smsRequested && !systemRequested) {
              getPermissions(context);
            }
          }):GestureDetector(child: Container(
            padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 25),
            decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(10)
            ),
            child: const Text("Continue",style: TextStyle(color: Colors.white,fontFamily: 'Proxima',fontWeight: FontWeight.bold,fontSize: 16)),
          ),onTap: (){
            Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => GoogleSignin()));
          }),
        ],
      ),
    )));
  }

}