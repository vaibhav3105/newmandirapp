import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mandir_app/screens/accountScreen.dart';
import 'package:mandir_app/screens/addTodo.dart';
import 'package:mandir_app/service/api_service.dart';
import 'package:mandir_app/utils/helper.dart';

import 'auth/login_screen.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();

  await FlutterDownloader.initialize(
      debug:
          true, // optional: set to false to disable printing logs to console (default: true)
      ignoreSsl:
          true // option: set to false to disable working with http links (default: false)
      );
  runApp(const MyApp());
  myCustomConfig();
}

myCustomConfig() {
  //TODO:  https://pub.dev/packages/flutter_easyloading/example
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
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
      // home: const LoginScreen(),
      home: const AccountScreen(),
    );
  }
}
