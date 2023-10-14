// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../service/api_service.dart';

class LoginInfo extends StatefulWidget {
  final String memberCode;
  const LoginInfo({
    Key? key,
    required this.memberCode,
  }) : super(key: key);

  @override
  State<LoginInfo> createState() => _LoginInfoState();
}

class _LoginInfoState extends State<LoginInfo> {
  var answer = [];
  bool isLoading = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoginInfo();
  }

  void getLoginInfo() async {
    setState(() {
      isLoading = true;
    });
    try {
      print(widget.memberCode);
      var response = await ApiService().post(
          "/api/account/login-info/family-member",
          {'familyMemberCode': widget.memberCode},
          headers,
          context);
      setState(() {
        isLoading = false;
        answer = response;
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
          actions: [
            Padding(
              padding: const EdgeInsets.only(
                right: 10,
              ),
              child: IconButton(
                onPressed: () async {
                  final image = await ssController.capture();

                  saveAndShare(image!);
                },
                icon: const Icon(Icons.share),
              ),
            )
          ],
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
                      'Associated with ${answer.length} logins',
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
                        itemCount: answer.length,
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
                                      ListTile(
                                        title: const Text(
                                          "Login Name",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: Text(
                                          answer[index]['loginName'],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16),
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
                                      ListTile(
                                        title: const Text(
                                          "Password",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        subtitle: Text(
                                          answer[index]['password'],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16),
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
                                      ListTile(
                                        title: const Text(
                                          "User Type",
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 14,
                                          ),
                                        ),
                                        trailing: GestureDetector(
                                          onTap: () {
                                            Clipboard.setData(
                                              ClipboardData(
                                                text:
                                                    'Login Name: ${answer[index]['loginName']}\nPassword: ${answer[index]['password']}',
                                              ),
                                            );
                                          },
                                          child: const Icon(
                                            Icons.copy,
                                          ),
                                        ),
                                        subtitle: Text(
                                          answer[index]['userTypeText'],
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16),
                                        ),
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
