import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:http/http.dart' as http;
import 'package:mandir_app/auth/login_screen.dart';
import 'package:mandir_app/screens/myFamilyList.dart';
import 'package:mandir_app/screens/updateAppScreen.dart';
import 'package:mandir_app/utils/app_enums.dart';
import 'package:mandir_app/utils/helper.dart';
import 'package:mandir_app/utils/utils.dart';
import 'package:random_string/random_string.dart';

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
  static String? apiBaseUrl;

  getIpFromIpfi() async {
    try {
      var response = await http.get(
        Uri.parse(
          'https://api.ipify.org/',
        ),
      );
      if (response.statusCode == 200) {
        return response.body;
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  static Future<void> ResolveApiBaseUrl() async {
    if (apiBaseUrl == null) {
      var ipFromIpfi = await ApiService().getIpFromIpfi();
      if (ipFromIpfi == '122.160.175.36') {
        apiBaseUrl = dotenv.env['PRIVATE_API_BASE_URL'];
      } else {
        apiBaseUrl = dotenv.env['PUBLIC_API_BASE_URL'];
      }
    }
  }

  logOut(BuildContext context, bool clearSessionData) async {
    nextScreenReplace(context, const LoginScreen());
    if (clearSessionData == true) {
      await clearSession();
    }
  }

  clearSession() async {
    await Helper.saveUserAccessToken('');
    await Helper.saveUserType(0);
    await Helper.saveUserTypeText('');
    await Helper.saveUserSsnCode('');
    await Helper.saveUserLoginName('');
    await Helper.saveUserPassword('');
    await Helper.showBiometricLogin(false);
  }

  static Future<Uri> ResolveMyApiUrl(String url, BuildContext context) async {
    if (apiBaseUrl == null) {
      var ipFromIpfi = await ApiService().getIpFromIpfi();
      if (ipFromIpfi == '122.160.175.36') {
        apiBaseUrl = dotenv.env['PRIVATE_API_BASE_URL'];
      } else {
        apiBaseUrl = dotenv.env['PUBLIC_API_BASE_URL'];
      }
    }

    return Uri.parse("$apiBaseUrl$url");
  }

  handleApiResponseForFileUpload(
      BuildContext context, http.StreamedResponse response) async {
    // dynamic responseBody = jsonDecode(response.body);
    print(response.statusCode);
    // print(responseBody);

    switch (response.statusCode) {
      case 200:
        break;
      case 401:
      case 403:
        showToast(context, ToastTypes.ERROR, 'Unauthorized');
        nextScreenReplace(context, const LoginScreen());
        break;
      default:
        var streamedBytes = await response.stream.toBytes();
        var result = String.fromCharCodes(streamedBytes);

        dynamic responseBody = jsonDecode(result);
        if (responseBody != null && responseBody != '') {
          if (responseBody.containsKey('errorMessage')) {
            showToast(context, ToastTypes.WARN, responseBody['errorMessage']);
          } else if (responseBody.containsKey("errors")) {
            Map<String, dynamic> errors = responseBody["errors"];
            for (var key in errors.keys) {
              if (errors[key] is List<String> && errors[key].isNotEmpty) {
                showToast(context, ToastTypes.WARN, errors[key][0]);
                break;
              }
            }
          } else {
            showToast(context, ToastTypes.WARN, 'Some error occured.');
          }
        }
    }
  }

  handleApiResponse(BuildContext context, http.Response response) {
    // dynamic responseBody = jsonDecode(response.body);
    print(response.statusCode);
    // print(responseBody);

    switch (response.statusCode) {
      case 200:
        break;
      case 401:
      case 403:
        showToast(context, ToastTypes.ERROR, 'Unauthorized');
        nextScreenReplace(context, const LoginScreen());
        break;
      default:
        dynamic responseBody = jsonDecode(response.body);
        if (responseBody != null && responseBody != '') {
          if (responseBody.containsKey('errorMessage')) {
            showToast(context, ToastTypes.WARN, responseBody['errorMessage']);
          } else if (responseBody.containsKey("errors")) {
            Map<String, dynamic> errors = responseBody["errors"];
            for (var key in errors.keys) {
              if (errors[key] is List<String> && errors[key].isNotEmpty) {
                showToast(context, ToastTypes.WARN, errors[key][0]);
                break;
              }
            }
          } else {
            showToast(context, ToastTypes.WARN, 'Some error occured.');
          }
        }
    }
  }

  static void login(
    BuildContext context,
    String loginName,
    String password,
    // Map<String?, String?> body,
  ) async {
    try {
      // await updateHeaders();
      EasyLoading.show(status: 'Logging you in...');
      await ResolveApiBaseUrl();
      var ip = apiBaseUrl!.split(':')[1].replaceAll('//', '');
      showToast(context, ToastTypes.SUCCESS, 'Connecting to $ip...');
      var ssnCode = randomAlphaNumeric(62);
      var url = "/api/account/login";
      Map<String?, String?> body = {
        'loginName': loginName,
        'password': password,
        'ssnCode': ssnCode,
      };
      dynamic jsonObj = await ApiService().post(url, body, headers, context);
      EasyLoading.dismiss();
      if (jsonObj == null) {
        await ApiService().clearSession();
        return;
      }

      await Helper.saveUserAccessToken(jsonObj['accessToken']);
      await Helper.saveUserType(jsonObj['userType']);
      await Helper.saveUserTypeText(jsonObj['userTypeText']);
      await Helper.saveUserSsnCode(ssnCode);
      await Helper.saveUserLoginName(loginName);
      await Helper.saveUserPassword(password);
      await Helper.showBiometricLogin(true);

      await updateHeaders();
      if (jsonObj['appVer'] < appVersion) {
        nextScreenReplace(
          context,
          UpdateAppScreen(
            url: jsonObj['appDownloadUrl'],
            message: jsonObj['appDownloadMsg'],
          ),
        );
      } else {
        nextScreenReplace(
          context,
          MyFamilyList(code: ''),
        );
      }
      showToast(context, ToastTypes.INFO, "You have logged-in");
    } catch (e) {
      showToast(context, ToastTypes.ERROR, e.toString());
    }
  }

  Future<dynamic> post(
    String url,
    var body,
    var headers,
    BuildContext context,
  ) async {
    try {
      await ResolveApiBaseUrl();
      // EasyLoading.show(status: 'Please wait...');
      var uri = Uri.parse("$apiBaseUrl$url");
      http.Response response =
          await http.post(uri, body: jsonEncode(body), headers: headers);

      // EasyLoading.dismiss();
      handleApiResponse(context, response);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } on SocketException catch (e) {
      switch (e.message) {
        case 'Connection refused':
          showToast(context, ToastTypes.WARN, 'Server connection failed.');
          break;
        default:
          showToast(context, ToastTypes.ERROR, e.toString());
      }
      await logOut(context, false);
    } catch (e) {
      print(e.toString());
      showToast(context, ToastTypes.ERROR, e.toString());
    }
    return null;
  }

  Future<dynamic> uploadDoc(
    String url,
    File file,
    var body,
    var headers,
    BuildContext context,
  ) async {
    try {
      await ResolveApiBaseUrl();
      var uri = Uri.parse("$apiBaseUrl$url");
      var request = http.MultipartRequest('POST', uri);
      var doc = await http.MultipartFile.fromPath('uploadFile', file.path);
      request.files.add(doc);
      body.forEach((key, value) {
        request.fields[key] = value.toString();
      });
      headers.forEach((key, value) {
        request.headers[key] = value;
      });
      var response = await request.send();
      await handleApiResponseForFileUpload(context, response);
      switch (response.statusCode) {
        case 200:
          var streamedBytes = await response.stream.toBytes();
          var result = String.fromCharCodes(streamedBytes);

          return jsonDecode(result);
      }
    } on SocketException catch (e) {
      switch (e.message) {
        case 'Connection refused':
          showToast(context, ToastTypes.WARN, 'Server connection failed.');
          break;
        default:
          showToast(context, ToastTypes.ERROR, e.toString());
      }
      await logOut(context, false);
    } catch (e) {
      print(e.toString());
      showToast(context, ToastTypes.ERROR, e.toString());
    }
    return null;
  }
}
