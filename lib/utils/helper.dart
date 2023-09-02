import 'package:shared_preferences/shared_preferences.dart';

class Helper {
  // static Future<bool?> saveUserAccessToken(String token) async {
  //   SharedPreferences sp = await SharedPreferences.getInstance();
  //   return await sp.setString("userAccessToken", token);
  // }

  // static Future<bool?> saveUserTypeText(String userTypeText) async {
  //   SharedPreferences sp = await SharedPreferences.getInstance();
  //   return await sp.setString("userTypeText", userTypeText);
  // }

  // static Future<bool?> saveUserTypeCode(int code) async {
  //   SharedPreferences sp = await SharedPreferences.getInstance();
  //   return await sp.setInt("userTypeCode", code);
  // }

  // static Future<bool?> saveUserSsnCode(String ssn) async {
  //   SharedPreferences sp = await SharedPreferences.getInstance();
  //   return await sp.setString("userSsnCode", ssn);
  // }

  // static Future<String?> getUserAccessToken() async {
  //   SharedPreferences sp = await SharedPreferences.getInstance();
  //   return sp.getString("userAccessToken");
  // }

  // static Future<String?> getUserSsnCode() async {
  //   SharedPreferences sp = await SharedPreferences.getInstance();
  //   return sp.getString("userSsnCode");
  // }

  // static Future<String?> getUserTypeText() async {
  //   SharedPreferences sp = await SharedPreferences.getInstance();
  //   return sp.getString("userTypeText");
  // }

  // static Future<int?> getUserTypeCode() async {
  //   SharedPreferences sp = await SharedPreferences.getInstance();
  //   return sp.getInt("userTypeCode");
  // }

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

  static Future<bool?> saveUserTypeText(String userTypeText) async {
    return await saveLss("userTypeText", userTypeText);
  }

  static Future<bool?> saveUserType(int userType) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setInt('userType', userType);
  }

  static Future<bool?> saveUserSsnCode(String ssn) async {
    return await saveLss("userSsnCode", ssn);
  }

  static Future<String?> getUserAccessToken() async {
    return getLss("userAccessToken");
  }

  static Future<String?> getUserSsnCode() async {
    return getLss("userSsnCode");
  }

  static Future<String?> getUserTypeText() async {
    return getLss("userTypeText");
  }

  static Future<int?> getUserType() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getInt('userType');
  }

  static Future<bool?> saveTokenValidity(int validity) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setInt('validity', validity);
  }

  static Future<int?> getTokenValidity() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getInt('validity');
  }
}
