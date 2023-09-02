import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:mandir_app/screens/myFamilyList.dart';
import 'package:mandir_app/service/api_service.dart';
import 'package:mandir_app/utils/helper.dart';

import 'auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(
      debug:
          true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
          true // option: set to false to disable working with http links (default: false)
      );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? expirationTime = 0;
  String? accessToken;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getExpirationTime();
    getAccessToken();
  }

  getAccessToken() async {
    String? accessTokenFromHelper = await Helper.getUserAccessToken();
    updateHeaders();
    setState(() {
      accessToken = accessTokenFromHelper;
    });
  }

  getExpirationTime() async {
    int? expirationMilliSinceEpoch = await Helper.getTokenValidity();
    setState(() {
      expirationTime = expirationMilliSinceEpoch;
      print(expirationTime);
    });
    checkTokenAndInitiateTimer();
  }

  checkTokenAndInitiateTimer() async {
    // if (DateTime.now().millisecondsSinceEpoch >= expirationTime!) {
    //   refreshToken();
    // } else {
    Timer(
        Duration(
            milliseconds:
                expirationTime! - DateTime.now().millisecondsSinceEpoch), () {
      refreshToken();
    });
    // }
  }

  refreshToken() async {
    try {
      var response = await ApiService()
          .post("/api/account/new-token", {}, headers, context);
      print(response);
      int tokenExpirationTime =
          Duration(minutes: response['validity']).inMilliseconds +
              DateTime.now().millisecondsSinceEpoch;
      await Helper.saveTokenValidity(tokenExpirationTime);
      await Helper.saveUserAccessToken(response['accessToken']);
      updateHeaders();
      // checkTokenAndInitiateTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mandir App',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF0F1F3),
        appBarTheme: const AppBarTheme(
          foregroundColor: Colors.white,
          color: Color.fromARGB(
            255,
            106,
            78,
            179,
          ),
        ),
      ),
      home: accessToken != null
          ? MyFamilyList(
              code: '',
            )
          : const LoginScreen(),
    );
  }
}
