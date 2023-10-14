import 'package:flutter/material.dart';
import 'package:mandir_app/service/api_service.dart';

class AccountService {
  static String changeLoginNameUrl = '/api/account/change-login-name';

  Future<dynamic> changeLoginName(
      String loginName, BuildContext context) async {
    try {
      var response = await ApiService().post(
        changeLoginNameUrl,
        {'newLoginName': loginName},
        headers,
        context,
      );
      return response;
    } catch (e) {
      print(e.toString());
    }
  }
}
