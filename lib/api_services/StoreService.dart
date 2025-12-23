import 'package:flutter/cupertino.dart';

import '../Constants/api_constants.dart';
import '../Models/StoreModel.dart';
import '../services/api_request.dart';

class StoreService {
  static Future<List<StoreModel>> fetchStores(BuildContext context) async {
    final response = await ApiRequest.get(ApiConstants.fetchStoresEndPoint,
        context: context);

    if (response['success']) {
      List<dynamic> data = response['data'];
      return data.map((json) => StoreModel.fromJson(json)).toList();
    } else {
      throw Exception(response['error']);
    }
  }
}
