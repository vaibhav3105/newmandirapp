// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Login Info',
          ),
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
                          return Card(
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
                                        color: Colors.black, fontSize: 16),
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
                                        color: Colors.black, fontSize: 16),
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
                                  subtitle: Text(
                                    answer[index]['userTypeText'],
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ));
  }
}
