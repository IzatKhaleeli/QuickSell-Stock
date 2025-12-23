import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/api_constants.dart';
import '../Models/CartModel.dart';
import '../Models/ItemCartModel.dart';
import '../Utils/idempotency_helper.dart';
import '../services/api_request.dart';

class CartService {
  static Future<List<CartModel>> fetchCarts(
      BuildContext context, String startDate, String enddate) async {
    final response = await ApiRequest.get(
        "${ApiConstants.fetchOrdersEndPoint}?startDate=$startDate&endDate=$enddate",
        context: context);
    if (response['success']) {
      List<dynamic> data = response['data'];
      return data.map((json) => CartModel.fromJson(json)).toList();
    } else {
      throw Exception(response['error']);
    }
  }

  static Future<void> createOrder(BuildContext context,
      List<ItemCart> itemsList, double totalCash, double totalVisa) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? 'token';
    final userId = prefs.getString('username') ?? 'Unknown';

    final requestOrderData = {
      "order": {
        "TotalPrice": (totalCash + totalVisa),
        "totalAmountCash": totalCash,
        "VisaTotalPrice": totalVisa,
        "UserID": userId,
        "Status": "Sent",
        "orderItems": itemsList.map((item) {
          return {
            "itemId": item.id.toString(),
            "quantity": item.quantity,
            "unitPrice": item.sellingPrice,
            "ActualPrice": item.purchasePrice,
          };
        }).toList()
      }
    };
    final headers = {
      "Authorization": "Bearer $token",
      "Content-Type": "application/json",
      "Idempotency-Key": IdempotencyHelper.generateKey(),
    };

    final response = await ApiRequest.post(
        ApiConstants.createOrderEndPoint, requestOrderData,
        context: context, headers: headers);
    if (!response['success']) {
      throw Exception(response['error']);
    }
  }

  static Future<List<ItemCart>> fetchOrderItems(
      BuildContext context, int orderId) async {
    final response = await ApiRequest.get(
        "${ApiConstants.creatGetOrderByIdEndPoint}/$orderId",
        context: context);
    if (response['success']) {
      List<dynamic> data = response['data'];
      return data.map((json) => ItemCart.fromOrderItemJson(json)).toList();
    } else {
      throw Exception(response['error']);
    }
  }

  static Future<Map<String, int>> fetchProfitValues(
      BuildContext context) async {
    final DateTime now = DateTime.now();
    final String today = DateFormat('yyyy-MM-dd').format(now);

    final response = await ApiRequest.get(
        "${ApiConstants.fetchTodayProfitReportEndPoint}?startDate=$today&endDate=$today",
        context: context);
    if (response['success']) {
      List<dynamic> data = response['data'];
      if (data.isNotEmpty) {
        final item = data[0];
        int totalProfit = item['TotalProfit'] ?? 0;
        int totalExpenses = item['TotalExpenses'] ?? 0;

        return {
          'TotalProfit': totalProfit,
          'TotalExpenses': totalExpenses,
        };
      }
    }
    return {
      'TotalProfit': 0,
      'TotalExpenses': 0,
    };
  }

  static Future<List<ItemCart>> fetchAllOrderItems(BuildContext context) async {
    final response = await ApiRequest.get(
        ApiConstants.fetchAllOrderItemsReportEndPoint,
        context: context);
    if (response['success']) {
      List<dynamic> data = response['data'];
      return data.map((json) => ItemCart.fromOrderItemJson(json)).toList();
    } else {
      throw Exception(response['error']);
    }
  }

  static Future<List<ItemCart>> fetchAllOrderItemsReport(
      BuildContext context, String startDate, String enddate) async {
    final response = await ApiRequest.get(
        "${ApiConstants.fetchAllOrderItemsReportEndPoint}?startDate=$startDate&endDate=$enddate",
        context: context);
    if (response['success']) {
      List<dynamic> data = response['data'];
      return data.map((json) => ItemCart.fromOrderItemJson(json)).toList();
    } else {
      throw Exception(response['error']);
    }
  }
}
