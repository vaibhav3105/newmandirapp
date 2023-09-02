import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mandir_app/auth/login_screen.dart';
import 'package:mandir_app/screens/myFamilyList.dart';
import 'package:mandir_app/screens/updateAppScreen.dart';
import 'package:mandir_app/utils/helper.dart';
import 'package:mandir_app/utils/utils.dart';

final Map<String, String> headers = {
  "Content-Type": "application/json; charset=UTF-8",
  'ClientKey': "JainMandir37",
};

const double appVersion = -1.0;

updateHeaders() async {
  String? ssnCode = await Helper.getUserSsnCode();
  String? accessToken = await Helper.getUserAccessToken();
  headers['SsnCode'] = ssnCode!;
  headers['Authorization'] = "bearer $accessToken";
}

class ApiService {
  static bool usePrivateIP = false;

  static Uri ResolveMyApiUrl(String url) {
    // return Uri.parse("http://192.168.1.10:1000/SocietyApi$url");
    if (usePrivateIP == true) {
      return Uri.parse("http://192.168.1.101:1000/SocietyApi$url");
    } else {
      return Uri.parse("http://122.160.175.36:1000/SocietyApi$url");
    }
  }

  static void login(Map<String?, String?> body, Map<String, String> headers,
      BuildContext context) async {
    try {
      await updateHeaders();
      var url = "/api/account/login";

      http.Response response = await http.post(ResolveMyApiUrl(url),
          body: jsonEncode(body), headers: headers);
      if (response.statusCode != 200) {
        print(response.body);

        showCustomSnackbar(
          context,
          Colors.red,
          'Login name or password is incorrect',
        );

        return;
      }

      await Helper.saveUserAccessToken(
          jsonDecode(response.body)['accessToken']);
      await Helper.saveUserType(jsonDecode(response.body)['userType']);
      await Helper.saveUserTypeText(jsonDecode(response.body)['userTypeText']);
      int tokenExpirationTime =
          Duration(minutes: jsonDecode(response.body)['validity'])
                  .inMilliseconds +
              DateTime.now().millisecondsSinceEpoch;
      // int tokenExpirationTime = const Duration(seconds: 10).inMilliseconds +
      //     DateTime.now().millisecondsSinceEpoch;
      await Helper.saveTokenValidity(tokenExpirationTime);
      await updateHeaders();
      if (jsonDecode(response.body)['appVer'] < appVersion) {
        nextScreenReplace(
          context,
          UpdateAppScreen(
            url: jsonDecode(response.body)['appDownloadUrl'],
            message: jsonDecode(response.body)['appDownloadMsg'],
          ),
        );
      } else {
        nextScreen(
          context,
          MyFamilyList(code: ''),
        );
      }

      showCustomSnackbar(
        context,
        Colors.black,
        "Login Successful",
      );
    } catch (e) {
      print(e.toString());
      // showCustomSnackbar(
      //   context,
      //   Colors.black,
      //   e.toString(),
      // );
    }
  }

  Future<dynamic> post(
    String url,
    var body,
    var headers,
    BuildContext context,
  ) async {
    try {
      // url = "http://122.160.175.36:1000/SocietyApi$url";
      http.Response response = await http.post(ResolveMyApiUrl(url),
          body: jsonEncode(body), headers: headers);
      print(response.statusCode);

      switch (response.statusCode) {
        case 200:
          return jsonDecode(response.body);
        case 401:
        case 403:
          showCustomSnackbar(
            context,
            Colors.black,
            'Unauthorized',
          );
          nextScreenReplace(
            context,
            const LoginScreen(),
          );

          // Todo: Redirect to login page code
          break;
        default:
          var x = jsonDecode(response.body);
          print(x);
          showCustomSnackbar(
            context,
            Colors.black,
            x['errorMessage'],
          );
      }
      return {};
    } catch (e) {
      print(e.toString());
      // showCustomSnackbar(
      //   context,
      //   Colors.black,
      //   e.toString(),
      // );

      return {};
    }
  }
}
