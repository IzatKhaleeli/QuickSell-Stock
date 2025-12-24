import 'package:flutter/cupertino.dart';
import '../Constants/api_constants.dart';
import '../Models/ItemModel.dart';
import '../services/api_request.dart';

class ItemService {
  static Future<List<ItemModel>> fetchItems(
      BuildContext context, int storeId) async {
    final response = await ApiRequest.get(
        "${ApiConstants.fetchStoreItemsEndPoint}/${storeId}",
        context: context);
    if (response['success']) {
      List<dynamic> data = response['data'];
      return data.map((json) => ItemModel.fromJson(json)).toList();
    } else {
      throw Exception(response['error']);
    }
  }

  static Future<Map<String, dynamic>> updateItem(
      {required BuildContext context,
      required Map<String, dynamic> body,
      required int itemId}) async {
    final endpoint = "${ApiConstants.item}/$itemId";
    final response =
        await ApiRequest.put(endpoint: endpoint, body: body, context: context);
    return response;
  }

  static Future<Map<String, dynamic>> insertItem(
      {required BuildContext context,
      required Map<String, dynamic> body,
      required Map<String, String> headers}) async {
    const endpoint = ApiConstants.item;
    final response = await ApiRequest.post(
      endpoint,
      body,
      headers: headers,
      context: context,
    );
    return response;
  }

  static Future<Map<String, dynamic>> deleteItem(
      {required BuildContext context, required int itemId}) async {
    final endpoint = "${ApiConstants.item}/$itemId";
    final response =
        await ApiRequest.delete(endpoint: endpoint, context: context);
    return response;
  }
}
