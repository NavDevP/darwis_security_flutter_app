
import 'package:cysecurity/database/apk_hash/model/model.dart';
import 'package:cysecurity/database/apk_hash/provider.dart';
import 'package:cysecurity/database/link_scan/model/model.dart';
import 'package:cysecurity/database/link_scan/provider.dart';
import 'package:cysecurity/database/otp_scan/model/model.dart';
import 'package:cysecurity/database/otp_scan/provider.dart';
import 'package:cysecurity/screens/detail/apk_detail.dart';
import 'package:cysecurity/screens/detail/link_detail.dart';
import 'package:cysecurity/screens/detail/overview_detail.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:lottie/lottie.dart';

import '../../../const/colors.dart';

Widget dashboardStatus(width) {
  ApkHashProvider provider = ApkHashProvider();
  return ValueListenableBuilder(
            valueListenable: Hive.box<ApkHashModel>(provider.getBoxName()).listenable(),
            builder: (context, Box<ApkHashModel> items, _) {

            var error = items.values.where((element) => element.verdict == 3).isNotEmpty;
            // var warning = items.values.where((element) => element.verdict == 2).isNotEmpty;
            if(items.values.isEmpty){
              return AnimatedContainer(
                width: width,
                height: width * 0.37,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [Colors.orange.shade800, Colors.redAccent.shade400],
                    )),
                padding: const EdgeInsets.symmetric(vertical: 10),
                duration: const Duration(seconds: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          // color: Colors.white24
                      ),
                      child: Stack(
                          alignment: Alignment.center,
                          children: [
                          Container(
                            alignment: Alignment.center,
                            child: SizedBox(
                                height: 100,
                                width: 100,
                                child: OverflowBox(
                                    minHeight: 100,
                                    maxHeight: 100,
                                    child: Lottie.asset("assets/images/scanning.json",fit: BoxFit.cover)
                                )
                            ),
                          ),
                          // Container(
                          //     alignment: Alignment.topCenter,
                          //     child: Lottie.asset('assets/images/scanning.json',width:120,height: 100,fit: BoxFit.cover)
                          // ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.white
                            ),
                            child: Icon(Icons.warning, size: 32, color: Colors.orange.shade800)
                          ),
                      ])
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text("You're not protected",
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                        SizedBox(height: 5),
                        Text("Scanning for Malware",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                        // const SizedBox(height: 10),
                        // Row(
                        //   children: const [
                        //     Text("Progress: ",style: TextStyle(
                        //         color: Colors.white,
                        //         fontSize: 14,
                        //         fontWeight: FontWeight.w500)),
                        //     Text("80%",style: TextStyle(
                        //         color: Colors.white,
                        //         fontSize: 15,
                        //         fontWeight: FontWeight.w800))
                        //   ],
                        // )
                      ],
                    )
                  ],
                ),
              );
            }
            return error ? Stack(children: [
              Container(
                width: width,
                height: width * 0.37,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      begin: Alignment.bottomLeft,
                      end: Alignment.topRight,
                      colors: [Colors.red.shade700, Colors.redAccent],
                    )),
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.white24),
                      child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Colors.white),
                          child: const Icon(Icons.close_rounded,
                              size: 50, color: Colors.red)),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Critical Apps",
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 5),
                        const Text("Some app's have issue",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 5),
                        Text("Last Scanned: ${(DateTime.now().minute - items.getAt(0)!.scannedOn.minute) > 0 ? "${DateTime.now().minute - items.getAt(0)!.scannedOn.minute} min's ago":"Just now"}",
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600)),
                      ],
                    )
                  ],
                ),
              ),
              GestureDetector(child: Container(
                width: MediaQuery.of(context).size.width,
                height: width * 0.44,
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: width,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900,
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20))
                  ),
                  child: const Text("Check Report",style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.w700),textAlign: TextAlign.center),
                ),
              ),onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => OverViewDetail())))
            ]):
            // warning ? Container(
            //   width: width,
            //   height: width * 0.37,
            //   decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(20),
            //       gradient: LinearGradient(
            //         begin: Alignment.bottomLeft,
            //         end: Alignment.topRight,
            //         colors: [Colors.orange.shade700, Colors.orangeAccent],
            //       )),
            //   padding: const EdgeInsets.symmetric(vertical: 10),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //     children: [
            //       Container(
            //         padding:
            //         const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            //         decoration: BoxDecoration(
            //             borderRadius: BorderRadius.circular(100),
            //             color: Colors.white24),
            //         child: Container(
            //           padding: const EdgeInsets.all(10),
            //             decoration: BoxDecoration(
            //                 borderRadius: BorderRadius.circular(100),
            //                 color: Colors.white),
            //             child: const Icon(Icons.warning,
            //                 size: 30, color: Colors.orange)),
            //       ),
            //       Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           const Text("Warning Apps",
            //               style: TextStyle(
            //                   color: Colors.white70,
            //                   fontSize: 14,
            //                   fontWeight: FontWeight.w500)),
            //           const SizedBox(height: 5),
            //           const Text("Some app's have issue's",
            //               style: TextStyle(
            //                   color: Colors.white,
            //                   fontSize: 18,
            //                   fontWeight: FontWeight.w600)),
            //           const SizedBox(height: 5),
            //           Text("Last Scanned: ${items.getAt(0)?.scannedOn.hour}",
            //               style: const TextStyle(
            //                   color: Colors.white70,
            //                   fontSize: 14,
            //                   fontWeight: FontWeight.w600))
            //         ],
            //       )
            //     ],
            //   ),
            // ):
            Container(
              width: width,
              height: width * 0.37,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomLeft,
                    end: Alignment.topRight,
                    colors: [AppColor.primary, AppColor.primaryAccent],
                  )),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.white24),
                    child: const Icon(Icons.check_circle,
                        size: 55, color: Colors.white),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Summary Status",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 5),
                      const Text("Everything Good",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 5),
                      Text("Last Scanned: ${items.values.isNotEmpty ? items.getAt(0)?.scannedOn.hour:''}",
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w600))
                    ],
                  )
                ],
              ),
            );
        });
}

Widget dashboardOverview(width,context) {
  LinkScanProvider provider2 = LinkScanProvider();
  return Column(
    children: [
      Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Overview",
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
              // Icon(Icons.more_horiz,color: Colors.black87)
            ],
          )),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(child:SizedBox(
              height: width * 0.33,
              width: width / 2.2,
              child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 1,
                  color: Colors.white,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Container(
                      padding:
                          const EdgeInsets.only(top: 12, bottom: 10, left: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: AppColor.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5)),
                                child: const Icon(
                                  Icons.stacked_line_chart,
                                  color: AppColor.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Apk's Scanned",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  Text("Total count",
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12))
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                              ValueListenableBuilder(
                                  valueListenable:
                                      ApkHashProvider().getBox().listenable(),
                                  builder:
                                      (context, Box<ApkHashModel> items, _) {
                                    return Text("${items.values.where((element) => element.verdict != 0 && element.verdict != 2).length}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28));
                                  })
                            ],
                          )
                        ],
                      )))),onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ApkDetail()))),
          SizedBox(
              height: width * 0.33,
              width: width / 2.2,
              child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 1,
                  color: Colors.white,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Container(
                      padding:
                          const EdgeInsets.only(top: 12, bottom: 10, left: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: AppColor.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5)),
                                child: const Icon(
                                  Icons.password,
                                  color: AppColor.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("OTP Warnings",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  Text("Total count",
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12))
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: [
                                  ValueListenableBuilder(
                                  valueListenable: OtpScanProvider().getBox().listenable(),
                                  builder: (context, Box<OtpScanModel> items, _) {
                                        return Text(
                                          "${items.length}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold, fontSize: 28),
                                        );
                                  })
                            ],
                          )
                        ],
                      )))),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
  GestureDetector(child: SizedBox(
              height: width * 0.35,
              width: width * 0.92,
              child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 1,
                  color: Colors.white,
                  shadowColor: Colors.black26,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Container(
                      padding:
                          const EdgeInsets.only(top: 12, bottom: 10, left: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: AppColor.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(5)),
                                child: const Icon(
                                  Icons.link,
                                  color: AppColor.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Links Scanned",
                                      style: TextStyle(
                                          color: Colors.black87,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13)),
                                  Text("Total count",
                                      style: TextStyle(
                                          color: Colors.black45,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12))
                                ],
                              )
                            ],
                          ),
                          GestureDetector(child: Row(
                            children: [
                              ValueListenableBuilder(
                                  valueListenable: LinkScanProvider().getBox().listenable(),
                                  builder: (context, Box<LinkScanModel> items, _) {
                                    return Text(
                                        "${items.values.where((element) => element.verdict != 0).length}",
                                        style: const TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 28),
                                    );
                                  })
                            ],
                          ),onTap: () async { await provider2.dataBox.clear();})
                        ],
                      )))),onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => LinkDetail()))),
        ],
      ),
    ],
  );
}

Widget dashboardActions(width) {
  int i =1;
  return Column(
    children: [
      Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Actions",
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            ],
          )),
      const SizedBox(height: 10),
      SizedBox(
          height: 40,
          child: ListView.builder(
              itemCount: 3,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 15),
                  decoration: BoxDecoration(
                      color: AppColor.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColor.primary)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: Center(
                      child: Text(
                          index == 1
                              ? "High"
                              : (index == 2 ? "Moderate" : "Critical"),
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                );
              })),
      const SizedBox(height: 20),
      SizedBox(
          height: 140,
          child: ValueListenableBuilder(
              valueListenable: ApkHashProvider().getBox().listenable(),
              builder: (context, Box<ApkHashModel> items, _) {
                return ListView.builder(
                    itemCount: items.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      if(items.getAt(index)?.verdict != 1) {
                        return SizedBox(
                            width: width / 1.5,
                            child: Card(
                                semanticContainer: true,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                elevation: 1,
                                color: Colors.white,
                                shadowColor: Colors.black26,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Container(
                                    padding: const EdgeInsets.all(15),
                                    child: Stack(
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Text("${index + 1}",
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 25)),
                                                const SizedBox(height: 5),
                                                Text(
                                                    "${items
                                                        .getAt(index)?.name}",
                                                    style: const TextStyle(
                                                        color: Colors.black87,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 16),
                                                    overflow:
                                                    TextOverflow.ellipsis),
                                                const SizedBox(height: 5),
                                                const Text("Apk has threat",
                                                    style: TextStyle(
                                                        color: Colors.black45,
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 14))
                                              ],
                                            ),
                                            Row(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.access_time,
                                                    size: 18,
                                                    color: Colors.black54),
                                                SizedBox(width: 5),
                                                Text("04:20",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                        FontWeight.w400)),
                                                SizedBox(width: 20),
                                                Icon(Icons.date_range,
                                                    size: 18,
                                                    color: Colors.black54),
                                                SizedBox(width: 5),
                                                Text("19 Feb",
                                                    style: TextStyle(
                                                        fontSize: 16,
                                                        color: Colors.black54,
                                                        fontWeight:
                                                        FontWeight.w400))
                                              ],
                                            )
                                          ],
                                        ),
                                        Container(
                                            alignment: Alignment.topRight,
                                            child: Container(
                                              width: 60,
                                              height: 25,
                                              decoration: BoxDecoration(
                                                  color: items
                                                      .getAt(index)
                                                      ?.verdict == 2
                                                      ? Colors.orange
                                                      : items
                                                      .getAt(index)
                                                      ?.verdict == 3 ? Colors
                                                      .red : Colors.green,
                                                  borderRadius:
                                                  BorderRadius.circular(5)),
                                              child: Center(
                                                  child: Text(
                                                      items
                                                          .getAt(index)
                                                          ?.verdict == 2
                                                          ? 'High'
                                                          : items
                                                          .getAt(index)
                                                          ?.verdict == 3
                                                          ? 'Critical'
                                                          : 'Safe',
                                                      style: const TextStyle(
                                                          color: Colors
                                                              .white))),
                                            ))
                                      ],
                                    ))));
                      }
                      return Container();
                    });
              })),
    ],
  );
}
