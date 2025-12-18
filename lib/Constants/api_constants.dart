class ApiConstants {
  static const String baseUrl =
      'https://my-api-2-ed000a488e73.herokuapp.com/api';
  static const String loginEndPoint = '$baseUrl/auth/login';
  static const String fetchStoresEndPoint = '$baseUrl/auth/Stores';
  static const String fetchExpensesEndPoint = '$baseUrl/GetExp';
  static const String fetchHistoryExpensesEndPoint =
      '$baseUrl/GetExpensesHistory';
  static const String fetchStoreItemsEndPoint = '$baseUrl/StoreItems';
  static const String fetchItemSizesEndPoint = '$baseUrl/GetItemSizes';
  static const String createOrderEndPoint = '$baseUrl/orders';
  static const String fetchOrdersEndPoint = '$baseUrl/OrdersByDateRange';
  static const String creatGetOrderByIdEndPoint =
      '$baseUrl/OrderItemsByOrderId';
  static const String createExpenseOrdersEndPoint = '$baseUrl/CreateExpenses';
  static const String fetchTodayProfitReportEndPoint =
      '$baseUrl/GetDailtProfit';
  static const String fetchAllOrderItemsReportEndPoint =
      '$baseUrl/OrderItemsReport';
}
