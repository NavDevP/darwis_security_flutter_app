import 'package:cysecurity/const/colors.dart';
import 'widgets/dashboard_widgets.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  Dashboard({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    var width = MediaQuery.of(context).size.width;
    return SafeArea(child: Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
          width: 250,
          child: Stack(
            children: [
              ListView(
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      color: AppColor.primary,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const <Widget>[
                        Text('Abra ka Dabra',style: TextStyle(color: Colors.white,fontSize: 20)),
                        SizedBox(height: 5),
                        Text('abrakipatni@email.com',style: TextStyle(color: Colors.white70,fontSize: 14)),
                        SizedBox(height: 5),
                      ],
                    ),
                  ),
                  const ListTile(
                    minLeadingWidth: 10,
                    leading: Icon(Icons.logout),
                    title: Text("Logout"),
                  )
                ],
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                alignment: Alignment.bottomCenter,
              child: const Text("Terms & Conditions"),
              )
            ],
          ),
      ),
      drawerEdgeDragWidth: 100,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu,color: AppColor.primary),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
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
        title: const Text("DARWIS AF",style: TextStyle(color: AppColor.primary)),
      ),
      body: Container(
          margin: EdgeInsets.only(top: 20, left: width * 0.04,right: width * 0.04),
          child: SingleChildScrollView(
            child: Column(
              children: [
                dashboardStatus(width),
                const SizedBox(height: 30),
                dashboardOverview(width),
                const SizedBox(height: 20),
                dashboardActions(width),
              ],
            ),
          )),
    ));
  }

}