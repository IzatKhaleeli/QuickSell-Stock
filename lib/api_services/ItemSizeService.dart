import 'package:flutter/cupertino.dart';
import '../Constants/api_constants.dart';
import '../Models/ItemSizeModel.dart';
import '../services/api_request.dart';

class ItemSizeService {
  static Future<List<ItemSizeModel>> fetchItemsSizes(
      BuildContext context, int itemId) async {
    final response = await ApiRequest.get(
        "${ApiConstants.fetchItemSizesEndPoint}/${itemId}",
        context: context);
    if (response['success']) {
      List<dynamic> data = response['data'];
      return data.map((json) => ItemSizeModel.fromJson(json)).toList();
    } else {
      throw Exception(response['error']);
    }
  }
}
