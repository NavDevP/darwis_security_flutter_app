import 'package:cysecurity/background/apk_hash/api_reponse.dart';
import 'package:cysecurity/const/colors.dart';
import 'package:cysecurity/database/apk_hash/model/model.dart';
import 'package:cysecurity/database/apk_hash/provider.dart';
import 'package:cysecurity/database/link_scan/model/model.dart';
import 'package:cysecurity/database/link_scan/provider.dart';
import 'package:cysecurity/screens/detail/apk_detail.dart';
import 'package:cysecurity/screens/detail/link_detail.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class OverViewDetail extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _OverViewDetail();
}

class _OverViewDetail extends State<OverViewDetail> {

  late TooltipBehavior _tooltipBehavior;


  @override
  void initState() {
    // TODO: implement initState
    _tooltipBehavior =  TooltipBehavior(enable: true);
    super.initState();
  }

  int apkTotalResults=0,apkMalwareResults=0,linkScanResults=0,linkMalwareResults=0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColor.primary),
              // leading: IconButton(
              //   icon: const Icon(Icons.menu,color: AppColor.primary),
              //   onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              // ),
              actions: [
                Stack(children: [
                  Container(
                      alignment: Alignment.center,
                      child: const Icon(Icons.notifications_none,
                          color: AppColor.primary)),
                  Container(
                    alignment: Alignment.centerRight,
                    margin: const EdgeInsets.only(bottom: 14, left: 13),
                    child: Container(
                      width: 10,
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(20)),
                      height: 10,
                    ),
                  ),
                ]),
                const SizedBox(width: 15),
              ],
              title: const Text("Report Overview",
                  style: TextStyle(
                      color: Colors.black54, fontWeight: FontWeight.w600)),
            ),
            body: SingleChildScrollView(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Container(
                    margin: const EdgeInsets.only(left: 10),
                    child: const Text("Overview",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold))),
                const SizedBox(height: 10),
                SfCartesianChart(
                    tooltipBehavior: _tooltipBehavior,
                    // Initialize category axis
                    primaryXAxis: CategoryAxis(),
                    series: <ColumnSeries<ChartData, String>>[
                      ColumnSeries<ChartData, String>(
                          color: AppColor.primary,
                          dataSource: [
                            ChartData('Scanned - Malware\n (Apk Scan)', apkTotalResults.toDouble()),
                            if(linkScanResults > 0)
                              ChartData('Scanned - Spam\n (Link Scan)', linkScanResults.toDouble())
                          ],
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          name: ''),
                      ColumnSeries<ChartData, String>(
                          color: Colors.redAccent,
                          dataSource: [
                            ChartData('Scanned - Malware\n (Apk Scan)', apkMalwareResults.toDouble()),
                            if(linkMalwareResults > 0)
                              ChartData('Scanned - Spam\n (Link Scan)', linkMalwareResults.toDouble()),
                          ],
                          xValueMapper: (ChartData data, _) => data.x,
                          yValueMapper: (ChartData data, _) => data.y,
                          name: '')
                    ]
                  ),
                  ValueListenableBuilder(
                    builder: (context,Box<ApkHashModel> box,_) {
                    List<ApkHashModel> total = box.values.where((element) => element.verdict != 0 && element.verdict != 2).toList();
                    List<ApkHashModel> malware = box.values.where((element) => element.verdict == 3).toList();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        apkTotalResults = total.length;
                        apkMalwareResults = malware.length;
                      });
                    });
                      return Container(
                        margin: const EdgeInsets.only(
                            top: 15,
                            left: 15,
                            right: 15,
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                                decoration: const BoxDecoration(
                                  color: AppColor.primary,
                                  borderRadius: BorderRadius.only(topRight: Radius.circular(6),topLeft: Radius.circular(6))
                                ),
                                child: Row(
                              children: const [
                                Icon(Icons.android,color: Colors.white),
                                SizedBox(width: 10),
                                Text("Apk Scan Results",style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold))
                              ],
                            )),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                            child: Row(
                              children: [
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("Here is the scan results of all apk's in the device"),
                                    const SizedBox(height: 10),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Colors.red.withOpacity(0.1)
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 3),
                                      child: Text("${malware.length} app's have malware",style: const TextStyle(color: Colors.red,fontWeight: FontWeight.bold)),
                                    )
                                  ],
                                )),
                                const SizedBox(width: 40),
                                Stack(
                                  children: [
                                    SizedBox(
                                      height: 50,
                                      width: 50,
                                      child: CircularProgressIndicator(
                                        color: Colors.red,
                                        strokeWidth: 6,
                                        value: (malware.length / total.length),
                                        backgroundColor: Colors.green,
                                      )),
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: Center(child: Text("${((malware.length / total.length) * 100).toInt()}%",style: const TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),))
                                      )
                                  ],
                                ),
                              ],
                            )),
                            const SizedBox(height: 5),
                            GestureDetector(child: Container(
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6),bottomRight: Radius.circular(6)),
                              ),
                              child: const Text("Check List",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16)),
                            ),onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ApkDetail()))),
                          ],
                        ),
                      );
                    }, valueListenable: ApkHashProvider().getBox().listenable()
                  ),
                  const SizedBox(height: 10),
                  ValueListenableBuilder(
                    builder: (context,Box<LinkScanModel> box,_) {
                      List<LinkScanModel> total = box.values.where((element) => element.verdict != 0).toList();
                      List<LinkScanModel> malware = box.values.where((element) => element.verdict == 2).toList();
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          linkScanResults = total.length;
                          linkMalwareResults = malware.length;
                        });
                      });
                      if(total.isNotEmpty) {
                        return Container(
                        margin: const EdgeInsets.only(
                          top: 15,
                          left: 15,
                          right: 15,
                        ),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                                decoration: const BoxDecoration(
                                    color: AppColor.primary,
                                    borderRadius: BorderRadius.only(topRight: Radius.circular(6),topLeft: Radius.circular(6))
                                ),
                                child: Row(
                                  children: const [
                                    Icon(Icons.link,color: Colors.white),
                                    SizedBox(width: 10),
                                    Text("Link Scan Results",style: TextStyle(fontSize: 16,color: Colors.white,fontWeight: FontWeight.bold))
                                  ],
                                )),
                            Padding(padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                                child: Row(
                                  children: [
                                    Expanded(child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Here is the scan results of all sms link's in the device"),
                                        const SizedBox(height: 10),
                                        Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              color: Colors.red.withOpacity(0.1)
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 3),
                                          child: Text("${malware.length} link's are not safe",style: const TextStyle(color: Colors.red,fontWeight: FontWeight.bold)),
                                        )
                                      ],
                                    )),
                                    const SizedBox(width: 40),
                                    Stack(
                                      children: [
                                        SizedBox(
                                            height: 50,
                                            width: 50,
                                            child: CircularProgressIndicator(
                                              color: Colors.red,
                                              strokeWidth: 6,
                                              value: (malware.length / total.length),
                                              backgroundColor: Colors.green,
                                            )),
                                        SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: Center(child: Text("${((malware.length / total.length) * 100).toInt()}%",style: const TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                            ),))
                                        )
                                      ],
                                    ),
                                  ],
                                )),
                            const SizedBox(height: 5),
                            GestureDetector(child: Container(
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 20),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(6),bottomRight: Radius.circular(6)),
                              ),
                              child: const Text("Check List",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 16)),
                            ),onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LinkDetail())))
                          ],
                        ),
                      );
                      }
                      return Container();
                    }, valueListenable: LinkScanProvider().getBox().listenable()),
                const SizedBox(height: 50),
              ],
            ))
        ));
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double? y;
}
