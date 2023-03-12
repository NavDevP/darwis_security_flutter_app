import 'package:flutter/material.dart';

import '../../../const/colors.dart';

Widget dashboardStatus(width) {
  var status = true;
  return  status ? Container(
    width: width,
    height: width * 0.37,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            AppColor.primary,
            AppColor.primaryAccent
          ],
        )
    ),
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.white24
          ),
          child: const Icon(Icons.check_circle,size: 55,color: Colors.white),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("Summary Status",style: TextStyle(color: Colors.white70,fontSize: 14,fontWeight: FontWeight.w500)),
            SizedBox(height: 5),
            Text("Everything Good",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w600)),
            SizedBox(height: 5),
            Text("Last Scanned: Today",style: TextStyle(color: Colors.white70,fontSize: 14,fontWeight: FontWeight.w600))
          ],
        )
      ],
    ),
  ):
  Container(
    width: width,
    height: width * 0.37,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [
            Colors.red.shade700,
            Colors.redAccent
          ],
        )
    ),
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 15,horizontal: 15),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: Colors.white24
          ),
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  color: Colors.white
              ),
              child: const Icon(Icons.close_rounded,size: 50,color: Colors.red)),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text("Critical Apps",style: TextStyle(color: Colors.white70,fontSize: 14,fontWeight: FontWeight.w500)),
            SizedBox(height: 5),
            Text("Some app's have issue",style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.w600)),
            SizedBox(height: 5),
            Text("Last Scanned: Today",style: TextStyle(color: Colors.white70,fontSize: 14,fontWeight: FontWeight.w600))
          ],
        )
      ],
    ),
  );
}

Widget dashboardOverview(width) {
  return  Column(
    children: [
      Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Overview",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 18)),
          // Icon(Icons.more_horiz,color: Colors.black87)
        ],
      )),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              height: width * 0.3,
              width: width / 2.2,
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
                      padding: const EdgeInsets.only(top: 12,bottom:10,left: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: AppColor.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: const Icon(Icons.stacked_line_chart,color: AppColor.primary,size: 20,),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Apk's Scanned",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 13)),
                                  Text("Total count",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 12))
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: const [
                              Text("40",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),)
                            ],
                          )
                        ],
                      )
                  )
              )),
          SizedBox(
              height: width * 0.3,
              width: width / 2.2,
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
                      padding: const EdgeInsets.only(top: 12,bottom:10,left: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: AppColor.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: const Icon(Icons.sms_outlined,color: AppColor.primary,size: 20,),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("SMS scanned",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 13)),
                                  Text("Total count",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 12))
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: const [
                              Text("100",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),)
                            ],
                          )
                        ],
                      )
                  )
              )),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
              height: width * 0.3,
              width: width * 0.92,
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
                      padding: const EdgeInsets.only(top: 12,bottom:10,left: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: AppColor.primary.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: const Icon(Icons.link,color: AppColor.primary,size: 20,),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("SMS Links Scanned",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 13)),
                                  Text("Total count",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 12))
                                ],
                              )
                            ],
                          ),
                          Row(
                            children: const [
                              Text("60",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),)
                            ],
                          )
                        ],
                      )
                  )
              )),
        ],
      ),
    ],
  );
}

Widget dashboardActions(width) {
  return Column(
    children: [
      Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text("Actions",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 18)),
        ],
      )),
      const SizedBox(height: 10),
      SizedBox(
          height: 40,
          child: ListView.builder(
          itemCount: 3,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index){
            return Container(
                      margin: const EdgeInsets.only(right: 15),
                      decoration: BoxDecoration(
                        color: AppColor.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColor.primary)
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
                      child: Center(child: Text(index == 1 ? "High": (index == 2 ? "Moderate": "Critical"),style: const TextStyle(fontWeight: FontWeight.bold))),
                  );
          })),
      const SizedBox(height: 20),
      SizedBox(
          height: 140,
          child: ListView.builder(
          itemCount: 5,
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index){
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("${index + 1}",style: const TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 25)),
                                    const SizedBox(height: 5),
                                    const Text("Darwin App - AblaMalware",style: TextStyle(color: Colors.black87,fontWeight: FontWeight.bold,fontSize: 16),overflow: TextOverflow.ellipsis),
                                    const SizedBox(height: 5),
                                    const Text("Apk has threat",style: TextStyle(color: Colors.black45,fontWeight: FontWeight.bold,fontSize: 14))
                                  ],
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.access_time,size: 18,color: Colors.black54),
                                    SizedBox(width: 5),
                                    Text("04:20",style: TextStyle(fontSize: 16,color: Colors.black54,fontWeight: FontWeight.w400)),
                                    SizedBox(width: 20),
                                    Icon(Icons.date_range,size: 18,color: Colors.black54),
                                    SizedBox(width: 5),
                                    Text("19 Feb",style: TextStyle(fontSize: 16,color: Colors.black54,fontWeight: FontWeight.w400))
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
                                    color: index == 1 ? Colors.orange: Colors.red,
                                    borderRadius: BorderRadius.circular(5)
                                  ),
                                  child: Center(child: Text(index == 1 ? 'High':'Critical',style: TextStyle(color: Colors.white))),
                              ))
                          ],
                        )
                    )
                ));
          })),
    ],
  );
}