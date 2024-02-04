// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mandir_app/utils/app_enums.dart';
import 'package:mandir_app/utils/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../service/api_service.dart';

class LoginInfo extends StatefulWidget {
  final String familyMemberCode;
  final String familyGroupCode;
  const LoginInfo({
    Key? key,
    required this.familyMemberCode,
    required this.familyGroupCode,
  }) : super(key: key);

  @override
  State<LoginInfo> createState() => _LoginInfoState();
}

class _LoginInfoState extends State<LoginInfo> {
  var LoginInfoMsg = '';
  var LoginInfoList = [];
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoginInfo();
  }

  void generateNewLogin() async {
    setState(() {
      isLoading = true;
    });
    try {
      var response = await ApiService().post2(
          context,
          "/api/account/create-login-info",
          {
            'familyMemberCode': widget.familyMemberCode,
            'familyGroupCode': widget.familyGroupCode,
          },
          headers);

      if (response.success == true) {
        showToast(context, ToastTypes.INFO, response.data['message']);
      } else {
        showToast(context, ToastTypes.WARN, response.data['errorMessage']);
      }
    } catch (e) {
      print(e.toString());
    }

    setState(() {
      isLoading = false;
    });

    getLoginInfo();
  }

  void getLoginInfo() async {
    setState(() {
      isLoading = true;
    });
    try {
      var response = await ApiService().post2(
          context,
          "/api/account/get-login-info",
          {
            'familyMemberCode': widget.familyMemberCode,
            'familyGroupCode': widget.familyGroupCode,
          },
          headers);

      var loginInfoMsg = '';
      var loginInfoList = [];
      if (response.success == true) {
        loginInfoMsg = response.data['message'];
        loginInfoList = response.data['loginList'];
      }

      setState(() {
        isLoading = false;
        LoginInfoMsg = loginInfoMsg;
        LoginInfoList = loginInfoList;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  final ssController = ScreenshotController();
  final ssController1 = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: ssController,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Login Info',
          ),
          // actions: [
          //   Padding(
          //     padding: const EdgeInsets.only(
          //       right: 10,
          //     ),
          //     child: IconButton(
          //       onPressed: () async {
          //         final image = await ssController.capture();
          //         saveAndShare(image!);
          //       },
          //       icon: const Icon(Icons.share),
          //     ),
          //   )
          // ],
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      LoginInfoMsg,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: LoginInfoList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Clipboard.setData(
                                  //   ClipboardData(
                                  //     text:
                                  //         'Login Name: ${answer[index]['loginName']}\nPassword: ${answer[index]['password']}',
                                  //   ),
                                  // );
                                  // print(Clipboard.getData());
                                },
                                child: Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  margin: EdgeInsets.zero,
                                  color: Colors.white,
                                  child: Column(
                                    children: [
                                      Padding(
                                        // padding: const EdgeInsets.symmetric(
                                        //     horizontal: 20, vertical: 12),
                                        padding: EdgeInsets.all(6.0),
                                        child: Table(
                                          // border: TableBorder.all(),
                                          // border: TableBorder.lerp(a, b, t)
                                          children: [
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Text(
                                                    "User Type",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Text(
                                                    LoginInfoList[index]
                                                        ['userTypeText'],
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16),
                                                  ),
                                                )),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Text(
                                                    "Login Name",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Text(
                                                    LoginInfoList[index]
                                                        ['loginName'],
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16),
                                                  ),
                                                )),
                                              ],
                                            ),
                                            TableRow(
                                              children: [
                                                const TableCell(
                                                    child: Padding(
                                                  padding: EdgeInsets.all(6.0),
                                                  child: Text(
                                                    "Password",
                                                    style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                )),
                                                TableCell(
                                                    child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  child: Text(
                                                    LoginInfoList[index]
                                                        ['password'],
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 16),
                                                  ),
                                                )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                        ),
                                        child: Divider(
                                          height: 0,
                                          thickness: 1,
                                          color: Color(0xFFF0F1F3),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              Clipboard.setData(
                                                ClipboardData(
                                                  text:
                                                      'Login Name: ${LoginInfoList[index]['loginName']}\nPassword: ${LoginInfoList[index]['password']}',
                                                ),
                                              );
                                            },
                                            // child: const Icon(
                                            //   Icons.copy,
                                            // ),
                                            child: const Text("Copy"),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Divider(
                                color: Colors.transparent,
                                height: 10,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 35, vertical: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                "Generate new Login",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          generateNewLogin();
                        },
                      ),
                    ),
                    // const Divider(
                    //   color: Colors.transparent,
                    //   height: 3,
                    // ),
                  ],
                ),
              ),
      ),
    );
  }

  Future saveAndShare(Uint8List bytes) async {
    final directory = (await getApplicationDocumentsDirectory()).path;
    File file = File('$directory/image.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)]);
    // await Share.shareXFiles([
    //   XFile.fromData(bytes, name: 'Login Info'),
    // ], subject: 'Share Login Info');
  }
}
