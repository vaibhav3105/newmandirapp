import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mandir_app/service/api_service.dart';

class DocsService {
  static String uploadDocUrl = '/api/family-member/upload-doc';
  static String getDocUrl = '/api/family-member/download-doc';

  Future<dynamic> uploadDoc(
    BuildContext context,
    String familyMemberCode,
    String docType,
    File file,
  ) async {
    try {
      var response = await ApiService().uploadDoc(
          uploadDocUrl,
          file,
          {'familyMemberCode': familyMemberCode, 'docType': docType},
          headers,
          context);
      print(response);
      return response;
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> getDoc(String familiMemberCode, BuildContext context) async {
    try {
      var response = await ApiService().post(
          getDocUrl,
          {
            'familyMemberCode': familiMemberCode,
            'docType': "PROFILE_PHOTO",
          },
          headers,
          context);
      return response;
    } catch (e) {
      print(e.toString());
    }
  }
}
