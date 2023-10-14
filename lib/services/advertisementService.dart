import 'package:flutter/material.dart';
import 'package:mandir_app/service/api_service.dart';

class AdvertisementService {
  static String getAdvertisementUrl = '/api/master-data/one-random-adver';

  Future<dynamic> getRandomAdvertisement(BuildContext context) async {
    try {
      var response = await ApiService().post(
        getAdvertisementUrl,
        {},
        headers,
        context,
      );
      return response;
    } catch (e) {
      print(e.toString());
    }
  }
}
