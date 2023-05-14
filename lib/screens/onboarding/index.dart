import 'package:cysecurity/const/colors.dart';
import 'package:cysecurity/database/onboarding_permission.dart';
import 'package:cysecurity/database/user_auth/provider.dart';
import 'package:cysecurity/main.dart';
import 'package:cysecurity/screens/auth/login_register.dart';
import 'package:cysecurity/screens/dashboard/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:onboarding/onboarding.dart';
import 'package:permission_handler/permission_handler.dart';

class OnBoarding extends StatefulWidget {
  const OnBoarding({Key? key}) : super(key: key);

  @override
  State<OnBoarding> createState() => _OnBoardingState();
}

class _OnBoardingState extends State<OnBoarding> {

  late Material materialButton;
  late int index;

  List<PageModel> onboardingPagesList(context) {
    return [
      PageModel(
        widget: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColor.background,
            border: Border.all(
              width: 0.0,
              color: AppColor.background,
            ),
          ),
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.android,size: 200,color: AppColor.primary),
                    const SizedBox(height: 80),
                    const Text("Auto Scan Apps!",style: TextStyle(
                      fontFamily: 'Proxima',
                      fontSize: 30,
                      fontWeight: FontWeight.bold
                    )),
                    Container(
                        margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 20),
                        child: const Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's",
                          style: TextStyle(
                              fontFamily: 'Proxima',
                              fontSize: 15,
                              color: Colors.black54,
                              height: 1.5
                          ),
                          textAlign: TextAlign.center,
                        )),
                  ],
                ),
              ),
        ),
      ),
      PageModel(
        widget: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColor.background,
            border: Border.all(
              width: 0.0,
              color: AppColor.background,
            ),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sms_failed_rounded,size: 200,color: AppColor.primary),
                const SizedBox(height: 80),
                const Text("Alert for OTP!",style: TextStyle(
                    fontFamily: 'Proxima',
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                )),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 20),
                    child: const Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's",
                      style: TextStyle(
                          fontFamily: 'Proxima',
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.5
                      ),
                      textAlign: TextAlign.center,
                    )),
              ],
            ),
          ),
        ),
      ),
      PageModel(
        widget: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColor.background,
            border: Border.all(
              width: 0.0,
              color: AppColor.background,
            ),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.sms,size: 200,color: AppColor.primary),
                const SizedBox(height: 80),
                const Text("Spam Messages!",style: TextStyle(
                    fontFamily: 'Proxima',
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                )),
                Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 20),
                    child: const Text("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's",
                      style: TextStyle(
                          fontFamily: 'Proxima',
                          fontSize: 15,
                          color: Colors.black54,
                          height: 1.5
                      ),
                      textAlign: TextAlign.center,
                    )),
              ],
            ),
          ),
        ),
      ),
      PageModel(
        widget: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColor.background,
            border: Border.all(
              width: 0.0,
              color: AppColor.background,
            ),
          ),
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fact_check_outlined,size: 150,color: Colors.green),
                const SizedBox(height: 50),
                const Text("Grant Permissions!",style: TextStyle(
                    fontFamily: 'Proxima',
                    fontSize: 30,
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
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.symmetric(vertical: 10,horizontal: 10),
                      decoration: const BoxDecoration(
                          color: Colors.white
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Container(
                          //     padding: const EdgeInsets.all(10),
                          //     decoration: BoxDecoration(
                          //         color: AppColor.primary.withOpacity(0.3),
                          //         borderRadius: BorderRadius.circular(5)
                          //     ),
                          //     child: const Icon(Icons.sms,size: 30,color: AppColor.primary)
                          // ),
                          // const SizedBox(width: 20),
                          Expanded(child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("SMS Permission Required",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              SizedBox(
                                  width: MediaQuery.of(context).size.width / 1.8,
                                  child: const Text("Sms permission required to protect you from spam messages",style: TextStyle(fontSize: 13,color: Colors.black54))),
                              // const SizedBox(height: 10),
                            ],
                          )),
                          GestureDetector(child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                              decoration: BoxDecoration(
                                  color: AppColor.primary,
                                  borderRadius: BorderRadius.circular(5)
                              ),
                              child: const Text("Allow",style: TextStyle(color: Colors.white,fontSize: 16)
                              )),onTap: () async{
                            var check = await Permission.sms.request();
                          }),
                        ],
                      ),
                    )
                  ],
                ),
                // GestureDetector(child: Container(
                //   padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 25),
                //   decoration: BoxDecoration(
                //     color: AppColor.primary,
                //     borderRadius: BorderRadius.circular(10)
                //   ),
                //   child: const Text("Grant Permissions",style: TextStyle(color: Colors.white,fontFamily: 'Proxima',fontWeight: FontWeight.bold,fontSize: 16)),
                // ),onTap: (){
                //   getPermissions();
                // },),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  OnBoardingPermissionProvider permissionProvider = OnBoardingPermissionProvider();

  @override
  void initState() {
    super.initState();
    materialButton = _skipButton();
    index = 0;
  }

  Material _skipButton({void Function(int)? setIndex}) {
    return Material(
      borderRadius: defaultSkipButtonBorderRadius,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: defaultSkipButtonBorderRadius,
        onTap: () {
          if (setIndex != null) {
            index = 3;
            setIndex(3);
          }
        },
        child: const Padding(
          padding: EdgeInsets.only(left: 10),
          child: Text(
            'Skip',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColor.secondaryText
            ),
          ),
        ),
      )
    );
  }

  Material _nextButton({void Function(int)? setIndex}) {
    return Material(
      borderRadius: defaultSkipButtonBorderRadius,
      color: Colors.transparent,
      child: InkWell(
        borderRadius: defaultSkipButtonBorderRadius,
        onTap: () {
          if (setIndex != null) {
            index = index + 1;
            setIndex(index);
          }
        },
        child: const Padding(
          padding: EdgeInsets.only(left: 50,right: 10),
          child: Text(
            'Next',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: Colors.black
            ),
          ),
      ))
    );
  }

  Material get _signupButton {
    return Material(
      borderRadius: defaultProceedButtonBorderRadius,
      color: defaultProceedButtonColor,
      child: InkWell(
        borderRadius: defaultProceedButtonBorderRadius,
        onTap: () {},
        child: const Padding(
          padding: defaultProceedButtonPadding,
          child: Text(
            'Grant Permissions',
            style: defaultProceedButtonTextStyle,
          ),
        ),
      ),
    );
  }

  Future<void> _showMyDialog() async {
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future getPermissions() async{
    var systemAlert = Permission.systemAlertWindow;
    if (await systemAlert.isGranted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GoogleSignin()));
    }else {
        await permissionProvider.open();
        var check = await Permission.systemAlertWindow.request();
        if (check.isDenied) {
          _showMyDialog();
        }
        if (check.isGranted) {
          await permissionProvider.insert(OnBoardingPermission.fromMap({'onboarding_done': 1,'system_alert_permission':1}));
          await permissionProvider.close();
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => GoogleSignin()));
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: Onboarding(
          pages: onboardingPagesList(context),
          onPageChange: (int pageIndex) {
            index = pageIndex;
          },
          startPageIndex: 0,
          footerBuilder: (context, dragDistance, pagesLength, setIndex) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: AppColor.background,
                border: Border.all(
                  width: 0.0,
                  color: AppColor.background,
                ),
              ),
              child: ColoredBox(
                color: AppColor.background,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30.0,left: 10,right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _skipButton(setIndex: setIndex),
                      CustomIndicator(
                        netDragPercent: dragDistance,
                        pagesLength: pagesLength,
                        indicator: Indicator(
                          activeIndicator: const ActiveIndicator(color: Colors.grey),
                          closedIndicator: const ClosedIndicator(color: AppColor.primary,borderWidth: 1),
                          indicatorDesign: IndicatorDesign.polygon(
                            polygonDesign: PolygonDesign(
                              polygon: DesignType.polygon_circle,
                            ),
                          ),
                        ),
                      ),
                      index == pagesLength - 1
                          ? Container()
                          : _nextButton(setIndex: setIndex),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}