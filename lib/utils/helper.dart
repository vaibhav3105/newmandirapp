import 'package:shared_preferences/shared_preferences.dart';

class Helper {
  static Future<bool?> saveLss(String key, String value) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setString(key, value);
  }

  static Future<String?> getLss(String key) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(key);
  }

  static Future<bool?> saveUserAccessToken(String token) async {
    return await saveLss("userAccessToken", token);
  }

  static Future<bool?> saveUserLoginName(String loginName) async {
    return await saveLss("loginName", loginName);
  }

  static Future<bool?> saveUserPassword(String password) async {
    return await saveLss("password", password);
  }

  static Future<bool?> saveUserTypeText(String userTypeText) async {
    return await saveLss("userTypeText", userTypeText);
  }

  static Future<bool?> saveUserType(int userType) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setInt('userType', userType);
  }

  static Future<bool?> showBiometricLogin(bool showBiometric) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setBool('showBiometric', showBiometric);
  }

  static Future<String?> getUserAccessToken() async {
    return getLss("userAccessToken");
  }

  static Future<String?> getUserSsnCode() async {
    return getLss("userSsnCode");
  }

  static Future<String?> getUserLoginName() async {
    return getLss("loginName");
  }

  static Future<String?> getUserPassword() async {
    return getLss("password");
  }

  static Future<String?> getUserTypeText() async {
    return getLss("userTypeText");
  }

  static Future<int?> getUserType() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getInt('userType');
  }

  static Future<bool?> getShowBiometricLogin() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool('showBiometric');
  }

  static Future<bool?> saveAccountList(String json) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setString('accountList', json);
  }

  static Future<String?> readAccountList() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString('accountList');
  }
}
