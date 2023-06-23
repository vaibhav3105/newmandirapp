import 'package:flutter/material.dart';

import 'auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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

      // home: accessToken != null ? AllAddressScreen() : LoginScreen(),
      home: const LoginScreen(),
    );
  }
}
