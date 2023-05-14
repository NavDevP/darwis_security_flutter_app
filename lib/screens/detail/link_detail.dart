
import 'package:android_intent_plus/android_intent.dart';
import 'package:cysecurity/const/colors.dart';
import 'package:cysecurity/database/apk_hash/model/model.dart';
import 'package:cysecurity/database/apk_hash/provider.dart';
import 'package:cysecurity/database/link_scan/model/model.dart';
import 'package:cysecurity/database/link_scan/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LinkDetail extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _LinkDetail();
}

class _LinkDetail extends State<LinkDetail> {


  void deleteApp(String package) async {
    AndroidIntent intent = AndroidIntent(
      action: 'android.intent.action.UNINSTALL_PACKAGE',
      data: 'package:$package',
    );
    await intent.launch();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: AppColor.primary),
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
          title: const Text("Link Scan Results",style: TextStyle(color: Colors.black54,fontWeight: FontWeight.w600)),
        ),
        body: ValueListenableBuilder(
            valueListenable: LinkScanProvider().getBox().listenable(),
            builder: (context,Box<LinkScanModel> box,_){
              List<LinkScanModel> data =  box.values.where((element) => element.verdict == 2).toList();
              if(data.isNotEmpty) {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.only(top: 15,left: 15,right: 15, bottom: (index == (data.length - 1) ? 15: 0)),
                      padding: const EdgeInsets.only(left: 10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.redAccent),
                          borderRadius: BorderRadius.circular(6)
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.link,color: AppColor.primary),
                          const SizedBox(width: 10),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data[index].link,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w600)),
                              // const SizedBox(height: 5),
                              // SizedBox(
                              //     width: MediaQuery.of(context).size.width / 2.2,
                              //     child: Text(data[index].message,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400),overflow: TextOverflow.ellipsis)
                              // ),
                              // const SizedBox(height: 5),
                              // SizedBox(
                              //     width: MediaQuery.of(context).size.width / 2.2,
                              //     child: Column(
                              //       crossAxisAlignment: CrossAxisAlignment.start,
                              //       children: const [
                              //         Text("MALWARE: ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600)),
                              //         Text("com.torjan.blabal.virus",style: TextStyle(color: Colors.red,fontWeight: FontWeight.w700)),
                              //       ],
                              //     ))
                            ],
                          )),
                          // Column(
                          //   crossAxisAlignment: CrossAxisAlignment.end,
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: <Widget>[
                          //     GestureDetector(child: Container(
                          //       height: MediaQuery.of(context).size.width / 8,
                          //       width: MediaQuery.of(context).size.width / 4.5,
                          //       alignment: Alignment.center,
                          //       decoration: const BoxDecoration(
                          //           color: Colors.red,
                          //           borderRadius: BorderRadius.only(topRight: Radius.circular(5),bottomRight: Radius.circular(5))
                          //       ),
                          //       child: const Text("Delete",style: TextStyle(color: Colors.white)),
                          //     ),onTap: () => {}),
                          //     // Container(
                          //     //   height: MediaQuery.of(context).size.width / 8,
                          //     //   width: MediaQuery.of(context).size.width / 4.5,
                          //     //   alignment: Alignment.center,
                          //     //   decoration: const BoxDecoration(
                          //     //       color: AppColor.primary,
                          //     //       borderRadius: BorderRadius.only(bottomRight: Radius.circular(5))
                          //     //   ),
                          //     //   child: const Text("Ignore",style: TextStyle(color: Colors.white)),
                          //     // ),
                          //   ],
                          // )
                        ],
                      ),
                    );
                  },
                );
              }
              return const Center(child: Text("No Malware\n All Good :)",style: TextStyle(fontSize: 20)));
            })
    ));
  }

}