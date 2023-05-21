
import 'package:android_intent_plus/android_intent.dart';
import 'package:cysecurity/background/apk_hash/api_reponse.dart';
import 'package:cysecurity/const/colors.dart';
import 'package:cysecurity/database/apk_hash/model/model.dart';
import 'package:cysecurity/database/apk_hash/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ApkDetail extends StatefulWidget {

  @override
  State<StatefulWidget> createState() => _ApkDetail();
}

class _ApkDetail extends State<ApkDetail> {


  void deleteApp(String package) async {
      AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.UNINSTALL_PACKAGE',
        data: 'package:$package',
      );
      await intent.launch();
  }

  void ignoreApp(ApkHashModel package) async{
    ApkHashProvider provider = ApkHashProvider();
    await provider.initializationDone;

    await provider.ignoreScannedApk(package);
  }


  void showReportSubmitted(data){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          alignment: Alignment.center,
          content:   Container(
            // height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                          color: Colors.red.shade100.withOpacity(0.5),
                          shape: BoxShape.circle
                      ),
                      child: const Icon(Icons.report_gmailerrorred,size: 40,color: Colors.red)),
                  const SizedBox(height: 10),
                  const Text("Ignore Alert!",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text("Are you sure you want to ignore this app?\nThis will lead to not scan this app in future!",style: TextStyle(fontSize: 15),textAlign: TextAlign.center),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      MaterialButton(onPressed: () => Navigator.pop(context),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: const Text("CLOSE",style: TextStyle(color: AppColor.primary,fontWeight: FontWeight.bold)),
                      ),
                      MaterialButton(onPressed: () => {
                          Navigator.pop(context),
                          ignoreApp(data)
                        },
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: const Text("IGNORE",style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              )
          ),
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColor.primary),
        title: const Text("Apk Scan Results",style: TextStyle(color: Colors.black54,fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(child: Padding(
        padding: const EdgeInsets.only(top: 15,left: 15,right: 15),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Malware Apps",style: TextStyle(fontSize: 26,fontWeight: FontWeight.bold,color: Colors.redAccent)),
          const SizedBox(height: 10),
          const Text("Here is the list of all malware app's\nwe've found installed on you're device\nIf you don't recognize any of this application please uninstall then immediately or ignore.",style: TextStyle(fontSize: 14,letterSpacing: 0.8)),
          const SizedBox(height: 10),
          ValueListenableBuilder(
              valueListenable: ApkHashProvider().getBox().listenable(),
              builder: (context,Box<ApkHashModel> box,_){
                List<ApkHashModel> data =  box.values.where((element) => element.verdict == HashVerdict.MALWARE.value && !element.ignored).toList();
                if(data.isNotEmpty) {
                  return ListView.builder(
                    itemCount: data.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.only(top: 15, bottom: (index == (data.length - 1) ? 15: 0)),
                        padding: const EdgeInsets.only(left: 10),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.purple.shade100),
                            borderRadius: BorderRadius.circular(6)
                        ),
                        child: Row(
                          children: [
                            Image.memory(data[index].icon,width: 40),
                            const SizedBox(width: 20),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(data[index].name,style: const TextStyle(fontSize: 16,fontWeight: FontWeight.w600),overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 5),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width / 2.2,
                                    child: Text(data[index].packageName,style: const TextStyle(fontSize: 14,fontWeight: FontWeight.w400),overflow: TextOverflow.ellipsis)
                                ),
                                const SizedBox(height: 5),
                                SizedBox(
                                    width: MediaQuery.of(context).size.width / 2.2,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text("MALWARE: ",style: TextStyle(fontSize: 12,fontWeight: FontWeight.w600)),
                                        Text("com.torjan.virus",style: TextStyle(color: Colors.red,fontWeight: FontWeight.w700)),
                                      ],
                                    ))
                              ],
                            )),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                GestureDetector(child: Container(
                                  height: MediaQuery.of(context).size.width / 9,
                                  width: MediaQuery.of(context).size.width / 4.5,
                                  alignment: Alignment.center,
                                  decoration: const BoxDecoration(
                                    border: Border(left: BorderSide(color: Colors.red,width: 0.5)),
                                    // borderRadius: BorderRadius.only(topRight: Radius.circular(5))
                                  ),
                                  child: const Text("Uninstall",style: TextStyle(color: Colors.red)),
                                ),onTap: () => deleteApp(data[index].packageName)),
                                GestureDetector(child: Container(
                                  height: MediaQuery.of(context).size.width / 9,
                                  width: MediaQuery.of(context).size.width / 4.5,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    border: Border(left: const BorderSide(color: AppColor.primary,width: 0.5),top: BorderSide(color: Colors.purple.shade100)),
                                    // borderRadius: const BorderRadius.only(bottomRight: Radius.circular(5))
                                  ),
                                  child: const Text("Ignore",style: TextStyle(color: AppColor.primary)),
                                ),onTap: () => showReportSubmitted(data[index])),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  );
                }
                return const Padding(padding: EdgeInsets.only(top: 100),child: Center(child: Text("No Malware\n All Good :)",style: TextStyle(fontSize: 20))));
              })
        ],
      ))
      )
    ));
  }

}