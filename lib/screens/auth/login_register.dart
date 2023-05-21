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
                  child: Image.asset("assets/images/logo/darwis.png",width: 250)
              ),
              Container(
                  alignment: Alignment.bottomCenter,
                  margin: EdgeInsets.only(bottom: width * 0.4,left: width * 0.15,right: width * 0.15),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4086f4),
                      padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 5)
                    ),
                    onPressed: () => ref.read(loginProvider.notifier).handleSignIn(),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Image.asset(Paths.googleIcon,scale: 30),
                          ),
                          const SizedBox(width: 10),
                          const Text(Variables.googleLogin,style: TextStyle(
                              color: Colors.white,
                              fontSize: 17
                          ),)
                        ]),
                  )
              ),
              Container(
                alignment: Alignment.bottomCenter,
                margin: EdgeInsets.only(bottom: width * 0.3),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width / 1.8,
                  child: const Text("By signing in you're agreeing to our terms and conditions",textAlign: TextAlign.center),
                ),
              )
            ],
          )
    ));
  }

}