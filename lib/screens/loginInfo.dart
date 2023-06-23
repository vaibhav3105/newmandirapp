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
  var answer = {};
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(child: Text(answer.toString())),
    );
  }
}
