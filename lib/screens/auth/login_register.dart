import 'package:cysecurity/providers/auth_provider.dart';

import 'package:cysecurity/const/paths.dart';
import 'package:cysecurity/const/variables.dart';
import 'package:cysecurity/screens/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class GoogleSignin extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: implement build
    var width = MediaQuery.of(context).size.width;
    UserLogin user = ref.watch(loginProvider);
    if(user.status == AUTH_STATUS.AUTHENTICATED){
      SchedulerBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Dashboard()));
      });
    }
    return SafeArea(child: Scaffold(
      body: Stack(
            children: [
              Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: width * 0.2,left: width * 0.2,right: width * 0.2),
                  child: const Text("Darwis App",style: TextStyle(fontSize: 40,fontWeight: FontWeight.bold))
              ),
              Container(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.only(bottom: width * 0.2,left: width * 0.2,right: width * 0.2),
                  child: ElevatedButton(
                    onPressed: () => ref.read(loginProvider.notifier).handleSignIn(),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Image.asset(Paths.googleIcon,scale: 20),
                          const Text(Variables.googleLogin,style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15
                          ),)
                        ]),
                  )
              )
            ],
          )
    ));
  }

}