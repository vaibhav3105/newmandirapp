import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mandir_app/screens/myFamilyList.dart';
import 'package:mandir_app/utils/helper.dart';
import 'package:mandir_app/utils/utils.dart';

final Map<String, String> headers = {
  "Content-Type": "application/json; charset=UTF-8",
  'ClientKey': "JainMandir37",
};

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
      return Uri.parse("http://192.168.1.10:1000/SocietyApi$url");
    } else {
      return Uri.parse("http://122.160.175.36:1000/SocietyApi$url");
    }
  }

  static void login(Map<String?, String?> body, Map<String, String> headers,
      BuildContext context) async {
    try {
      await updateHeaders();
      var url = "/api/account/login";
      // /api/account/login
      http.Response response = await http.post(ResolveMyApiUrl(url),
          body: jsonEncode(body), headers: headers);
      if (response.statusCode != 200) {
        // debugger();
        print(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Center(
              child: Text(
                'Login name or password is incorrect',
              ),
            ),
          ),
        );
        return;
      }
      await Helper.saveUserAccessToken(
          jsonDecode(response.body)['accessToken']);
      await Helper.saveUserType(jsonDecode(response.body)['userType']);
      await Helper.saveUserTypeText(jsonDecode(response.body)['userTypeText']);
      await updateHeaders();
      nextScreen(
        context,
        const MyFamilyList(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Center(
            child: Text(
              'Login Successfull',
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // Future<http.Response> getResponse(Map<String, String> headers,
  //     BuildContext context, Map<String, String> body, String url) async {
  //   try {
  //     http.Response response = await http.post(Uri.parse(url),
  //         body: jsonEncode(body), headers: headers);
  //     print(response.statusCode);
  //     if (response.statusCode != 200) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             jsonDecode(response.body)['message'],
  //           ),
  //         ),
  //       );
  //       return response;
  //     }
  //     return response;
  //     // // httpErrorHandler(
  //     // //     response: response,
  //     // //     context: context,
  //     // //     onSuccess: () =>
  //     // //         showSnackbar(context, "Login Successfull", Colors.green)
  //     //  );
  //   } catch (e) {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text(e.toString())));
  //     return http.Response('Error occurred', 500);
  //   }
  // }

  Future<dynamic> post(
    String url,
    var body,
    var headers,
    BuildContext context,
  ) async {
    try {
      url = "http://122.160.175.36:1000/SocietyApi$url";
      http.Response response = await http.post(Uri.parse(url),
          body: jsonEncode(body), headers: headers);
      print(response.statusCode);

      switch (response.statusCode) {
        case 200:
          return jsonDecode(response.body);
        case 401:
        case 403:
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Unauthorized!",
              ),
            ),
          );
          // Todo: Redirect to login page code
          break;
        default:
          var x = jsonDecode(response.body);
          print(x);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                x['errorMessage'],
              ),
            ),
          );
      }
      return {};
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
      return {};
    }
  }
}
