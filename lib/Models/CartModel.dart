class CartModel {
  int id;
  DateTime createdAt;
  String createdBy;
  double totalPrice;
  String status;

  CartModel({
    required this.id,
    required this.createdAt,
    required this.createdBy,
    required this.totalPrice,
    required this.status,
  });

  Map<String, dynamic> toJson() {
    return {
      "OrderID": id,
      "CreatedAT": createdAt.toIso8601String(),
      "UserID": createdBy,
      "TotalPrice": totalPrice,
      "Status": status,
    };
  }

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json["OrderID"],
      createdAt: json["CreatedAT"] != null
          ? DateTime.parse(json["CreatedAT"])
          : DateTime.now(),
      createdBy: json["UserID"] ?? "N/A",
      totalPrice: (json["TotalPrice"] as num?)?.toDouble() ?? 0.0,
      status: json["Status"] ?? "N/A",
    );
  }

  @override
  String toString() {
    return 'CartModel(id: $id, createdAt: $createdAt, createdBy: $createdBy, totalPrice: $totalPrice, status: $status)';
  }
}
