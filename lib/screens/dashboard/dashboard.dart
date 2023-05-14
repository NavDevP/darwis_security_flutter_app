import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cysecurity/const/colors.dart';
import 'package:cysecurity/database/otp_scan/provider.dart';
import 'package:cysecurity/database/user_auth/provider.dart';
import 'package:cysecurity/main.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../database/apk_hash/provider.dart';
import 'widgets/dashboard_widgets.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  Dashboard({super.key});

  @override
  State<StatefulWidget> createState() => _DashboadState();

}

class _DashboadState extends State<Dashboard>{

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  TextEditingController linkTextController = TextEditingController();

  int _currentPermissionIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialService();
  }

  Future initialService() async{
    await initializeService();
  }

  void showReport(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          alignment: Alignment.center,
          title: const Text("Report Link",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold)),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 40,horizontal: 15),
            child: TextFormField(
                controller: linkTextController,
                decoration: InputDecoration(
                hintText: 'Enter your Link',
                errorText: validateLink(linkTextController.text),
              )),
          ),
          contentPadding: EdgeInsets.zero,
          actionsAlignment: MainAxisAlignment.center,
          actionsOverflowButtonSpacing: 8.0,
          actionsPadding: const EdgeInsets.all(0),
          actions: [
            Row(
              children: [
                Expanded(child: GestureDetector(
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Colors.red.shade600,
                          borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20))
                      ),
                      child: const Text("Close",style: TextStyle(color: Colors.white,fontSize: 16)),
                    ))),
                Expanded(child: GestureDetector(
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          color: AppColor.primary,
                          borderRadius: BorderRadius.only(bottomRight: Radius.circular(20))
                      ),
                      child: const Text("Submit",style: TextStyle(color: Colors.white,fontSize: 16)),
                    )
                )),
              ],
            )
          ],
        );
      },
    );
  }

  String? validateLink(String value) {
    if(value.isNotEmpty) {
      final check = RegExp(
          r'^((?:.|\n)*?)((http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?)')
          .hasMatch(value);
      if (!check) {
        return "Text is not a link!";
      }
      return null;
    }
    return null;
  }

  Future checkPermissions() async{
    List<Widget> widgets = [];
    var sms = Permission.sms;
    var alert = Permission.systemAlertWindow;

    if(await sms.isDenied){
      widgets.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
        decoration: const BoxDecoration(
            color: Colors.white
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5)
                ),
                child: const Icon(Icons.sms,size: 30,color: AppColor.primary)
            ),
            const SizedBox(width: 20),
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("SMS Permission Required",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text("Sms permission required to protect you from spam messages",style: TextStyle(fontSize: 13,color: Colors.black54)),
                const SizedBox(height: 10),
                GestureDetector(child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                    decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: const Text("Allow",style: TextStyle(color: Colors.white,fontSize: 16)
                    )),onTap: () async{
                      var check = await Permission.sms.request();
                      if(check.isGranted) {
                        await initialService();
                        setState(() {});
                      }
                    }),
              ],
            ))
          ],
        ),
      ));
    }
    if(await alert.isDenied){
      widgets.add(Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
        decoration: const BoxDecoration(
            color: Colors.white
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(5)
                ),
                child: const Icon(Icons.add_alert,size: 30,color: AppColor.primary)
            ),
            const SizedBox(width: 20),
            Expanded(child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Alert Permission Required",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                const SizedBox(height: 5),
                const Text("Display over other app's permission required to alert any malware.",style: TextStyle(fontSize: 13,color: Colors.black54)),
                const SizedBox(height: 10),
                GestureDetector(child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 20),
                    decoration: BoxDecoration(
                        color: AppColor.primary,
                        borderRadius: BorderRadius.circular(5)
                    ),
                    child: const Text("Allow",style: TextStyle(color: Colors.white,fontSize: 16)
                    )),onTap: () async { await Permission.systemAlertWindow.request(); setState(() {});}),
              ],
            ))
          ],
        ),
      ));
    }

    return widgets;
  }



  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var width = MediaQuery.of(context).size.width;
    return SafeArea(child: Scaffold(
      key: _scaffoldKey,
      // drawer: Drawer(
      //     width: 250,
      //     child: Stack(
      //       children: [
      //         ListView(
      //           children: [
      //             DrawerHeader(
      //               decoration: const BoxDecoration(
      //                 color: AppColor.primary,
      //               ),
      //               child: ValueListenableBuilder(
      //                 valueListenable: UserAuthProvider().getBox().listenable(),
      //                 builder: (context, item,child){
      //                   return Column(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     mainAxisAlignment: MainAxisAlignment.end,
      //                     children: <Widget>[
      //                       Text("${item.getAt(0)?.name}",style: const TextStyle(color: Colors.white,fontSize: 20)),
      //                       const SizedBox(height: 5),
      //                       Text("${item.getAt(0)?.email}",style: const TextStyle(color: Colors.white70,fontSize: 14)),
      //                       const SizedBox(height: 5),
      //                     ],
      //                   );
      //                 },
      //               )
      //             ),
      //             const ListTile(
      //               minLeadingWidth: 10,
      //               leading: Icon(Icons.logout),
      //               title: Text("Logout"),
      //             )
      //           ],
      //         ),
      //         Container(
      //           margin: const EdgeInsets.only(bottom: 10),
      //           alignment: Alignment.bottomCenter,
      //         child: const Text("Terms & Conditions"),
      //         )
      //       ],
      //     ),
      // ),
      // drawerEdgeDragWidth: 100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.menu,color: AppColor.primary),
        //   onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        // ),
        actions: [
          Stack(
            children: [
              Container(
                  alignment: Alignment.center,
                  child: const Icon(Icons.notifications_none,color: AppColor.primary)),
              Container(
                alignment: Alignment.centerRight,
               margin: const EdgeInsets.only(bottom: 14,left: 13),
               child: Container(
                 width: 10,
                 decoration: BoxDecoration(
                     color: Colors.red,
                     borderRadius: BorderRadius.circular(20)
                 ),
                 height: 10,
               ),
              ),
            ]
          ),
          const SizedBox(width: 15),
        ],
        title: Image.asset("assets/images/logo/darwis_header.png",width: 105),
      ),
      body: Container(
          margin: EdgeInsets.only(left: width * 0.04,right: width * 0.04),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                dashboardStatus(width),
                const SizedBox(height: 20),
                FutureBuilder(
                    future: checkPermissions(),
                    builder: (context, snapshot){
                      if(snapshot.hasData && snapshot.data.length > 0) {
                        return Column(
                          children: [
                            CarouselSlider(
                                items: snapshot.data,
                                options: CarouselOptions(
                                    viewportFraction: 1,
                                    height: width * 0.34,
                                    enableInfiniteScroll: false,
                                    autoPlay: false,
                                    onPageChanged: (index, reason) {
                                      _currentPermissionIndex = index;
                                      setState(() {});
                                    }
                                )
                            ),
                            const SizedBox(height: 10),
                            snapshot.data.length > 1 ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for(var c = 0; c < snapshot.data.length; c++)
                                  Container(
                                    margin: c != 0 ? const EdgeInsets.only(
                                        left: 10) : EdgeInsets.zero,
                                    width: 10, height: 10,
                                    decoration: BoxDecoration(
                                        color: _currentPermissionIndex == c
                                            ? AppColor.primary
                                            : AppColor.primary.withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                  ),
                                // Container(
                                //   margin: const EdgeInsets.only(left: 10),
                                //   width: 10,height: 10,
                                //   decoration: BoxDecoration(
                                //       color: AppColor.primary.withOpacity(0.3),
                                //       borderRadius: BorderRadius.circular(20)
                                //   ),
                                // ),
                              ],
                            ):Container(),
                            const SizedBox(height: 20),
                          ],
                        );
                      }
                      return Container();
                }),
                dashboardOverview(width,context),
                const SizedBox(height: 20),
                Container(
                  width: width,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Column(
                    children: [
                      Image.asset("assets/images/link.jpg",width: 200),
                      const SizedBox(height: 10),
                      const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("Report any links here you found malicious and secure other users from the link.",
                          style: TextStyle(fontSize: 16),textAlign: TextAlign.center,
                      )),
                      const SizedBox(height: 20),
                      GestureDetector(child: Container(
                        width: width,
                        padding: const EdgeInsets.all(15),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: AppColor.primary,
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(10),bottomLeft: Radius.circular(10))
                        ),
                        child: const Text("Report Link",style: TextStyle(color: Colors.white,fontSize: 18)),
                      ),onTap: (){
                       showReport();
                      })
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Container(
                //     margin: const EdgeInsets.only(left: 10,right: 10,top: 20),
                //     decoration: BoxDecoration(
                //         borderRadius: BorderRadius.circular(10),
                //         color: Colors.white
                //     ),
                //     child: Column(
                //       mainAxisAlignment: MainAxisAlignment.center,
                //       children: [
                //         Container(
                //           decoration: const BoxDecoration(
                //               borderRadius: BorderRadius.only(topRight: Radius.circular(10),topLeft: Radius.circular(10)),
                //               color: Colors.black12
                //           ),
                //           padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                //           child: Row(
                //             children: [
                //               Image.asset("assets/images/logo/darwis_logo.png",width: 23),
                //               const SizedBox(width: 10),
                //               const Text("Darwis",style: TextStyle(fontSize: 16)),
                //             ],
                //           ),
                //         ),
                //         const SizedBox(height: 20),
                //         Container(
                //           padding: const EdgeInsets.all(10),
                //             decoration: const BoxDecoration(
                //               color: Colors.redAccent,
                //               shape: BoxShape.circle
                //             ),
                //             child: Image.asset(
                //             "assets/images/sheild.png",
                //             width: 50)),
                //         const SizedBox(height: 20),
                //         const Text("OTP ALERT!", style: TextStyle(
                //             color: Colors.black87,
                //             fontSize: 24,
                //             fontWeight: FontWeight.bold)),
                //         const SizedBox(height: 20),
                //         Container(
                //           padding: const EdgeInsets.symmetric(horizontal: 25),
                //             child: const Text("Do not share OTP with anyone until you really know", style: TextStyle(
                //             color: Colors.red,
                //             fontSize: 15,fontWeight: FontWeight.bold),textAlign: TextAlign.center)),
                //         const SizedBox(height: 20),
                //         Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //           crossAxisAlignment: CrossAxisAlignment.end,
                //           children: [
                //             Expanded(child: Container(
                //                 height: 40,
                //                 alignment: Alignment.center,
                //                 decoration: const BoxDecoration(
                //                   borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10)),
                //                   color: Colors.black87
                //                 ),
                //                 child: const Text("Close",
                //                   style: TextStyle(color: Colors.white)))),
                //             Expanded(child: Container(
                //                 height: 40,
                //                 decoration: const BoxDecoration(
                //                   color: Colors.red,
                //                   borderRadius: BorderRadius.only(bottomRight: Radius.circular(10))
                //                 ),
                //                 alignment: Alignment.center,
                //                 child: const Text("Okay",
                //                   style: TextStyle(color: Colors.white)))),
                //           ],
                //         )
                //       ],
                //     )
                // ),
                const SizedBox(height: 50),
                // dashboardActions(width),
              ],
            ),
          )),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 10,
        backgroundColor: AppColor.primary.withOpacity(0.8),
        showUnselectedLabels: false,
        showSelectedLabels: false,
        selectedIconTheme: const IconThemeData(color: Colors.white),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled),label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.person),label: ""),
        ],
      ),
    ));
  }

}