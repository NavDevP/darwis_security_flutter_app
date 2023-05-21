import 'package:cysecurity/const/colors.dart';
import 'package:cysecurity/database/user_auth/provider.dart';
import 'package:cysecurity/screens/auth/login_register.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
            child: ValueListenableBuilder(
                valueListenable: UserAuthProvider().getBox().listenable(),
                builder: (context, box, _) {
                  var data = box.values.first;
                  return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      GestureDetector(child: const Icon(Icons.arrow_back,size: 30,color: AppColor.primary),onTap: () => Navigator.pop(context)),
                      const SizedBox(width: 10),
                      const Text("Profile",
                          style: TextStyle(
                              fontSize: 30, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 20),
                          child: Row(
                            children: [
                              Container(
                                  width: 60,
                                  height: 60,
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: AppColor.primary),
                                      shape: BoxShape.circle,
                                      color: AppColor.primary.withOpacity(0.1),
                                  image: data.avatar.isNotEmpty ? DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(data.avatar)
                                  ):const DecorationImage(image: AssetImage(""))),
                                  child: data.avatar.isEmpty ? const Icon(Icons.person, size: 30):Container()),
                              const SizedBox(width: 20),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),overflow: TextOverflow.fade,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(data.email,
                                      style: const TextStyle(
                                          color: Colors.black54, fontSize: 13),
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ))
                            ],
                          )),
                    ),
                    const SizedBox(height: 20),
                    const Text("Other Settings",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    // SizedBox(
                    //     width: MediaQuery.of(context).size.width,
                    //     child: Card(
                    //       child: Padding(
                    //           padding: const EdgeInsets.symmetric(
                    //               horizontal: 15, vertical: 15),
                    //           child: Row(
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: const [
                    //               Icon(Icons.settings,
                    //                   size: 26, color: AppColor.primary),
                    //               SizedBox(width: 15),
                    //               Text(
                    //                 "Settings",
                    //                 style: TextStyle(
                    //                     fontWeight: FontWeight.bold,
                    //                     fontSize: 18),
                    //               ),
                    //             ],
                    //           )),
                    //     )),
                    const SizedBox(height: 5),
                    SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Card(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Icon(Icons.account_tree_sharp,
                                      size: 26, color: AppColor.primary),
                                  SizedBox(width: 15),
                                  Text(
                                    "Terms & Condition",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                ],
                              )),
                        )),
                    const SizedBox(height: 5),
                    GestureDetector(child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Card(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 15),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Icon(Icons.login,
                                      size: 26, color: AppColor.primary),
                                  SizedBox(width: 15),
                                  Text("Logout",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18)),
                                ],
                              )),
                        )),
                      onTap: () {
                        UserAuthProvider().deleteUser();
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GoogleSignin()));
                      })
                  ]);
            })),
      ),
    ));
  }
}
