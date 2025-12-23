import 'package:flutter/cupertino.dart';
import '../Constants/api_constants.dart';
import '../Models/ExpensesItemModel.dart';
import '../services/api_request.dart';

class ExpensesService {
  static Future<List<ExpensesItemModel>> fetchExpenses(
      BuildContext context) async {
    final response = await ApiRequest.get(
      ApiConstants.fetchExpensesEndPoint,
      context: context,
    );
    if (response['success']) {
      List<dynamic> data = response['data'];
      return data
          .map((json) => ExpensesItemModel.fromExpensesTypeJson(json))
          .toList();
    } else {
      throw Exception(response['error']);
    }
  }

  static Future<List<ExpensesItemModel>> fetchHistoryExpenses(
      BuildContext context, String startDate, String enddate) async {
    final response = await ApiRequest.get(
      "${ApiConstants.fetchHistoryExpensesEndPoint}?startDate=$startDate&endDate=$enddate",
      context: context,
    );
    if (response['success']) {
      List<dynamic> data = response['data'];
      return data.map((json) => ExpensesItemModel.fromJson(json)).toList();
    } else {
      throw Exception(response['error']);
    }
  }

  static Future<bool> createExpenseOrder(
      BuildContext context, int id, String desc, int price) async {
    final requestOrderData = {
      "ExpID": id,
      "ExpDesc": desc,
      "TotalPrice": price,
    };
    try {
      final response = await ApiRequest.post(
        ApiConstants.createExpenseOrdersEndPoint,
        requestOrderData,
        context: context,
      );

      if (response['success']) {
        return true;
      } else {
        throw Exception(response['error']);
      }
    } catch (e) {
      debugPrint("Error occurred while creating expense order: $e");
      return false;
    }
  }
}
