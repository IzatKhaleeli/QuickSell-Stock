class ExpensesItemModel {
  int id;
  String name;
  double price;
  DateTime? createdAt;

  ExpensesItemModel({
    required this.id,
    required this.name,
    required this.price,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "price": price,
    };
  }

  factory ExpensesItemModel.fromJson(Map<String, dynamic> json) {
    return ExpensesItemModel(
      id: json["ExpID"] != null ? json["ExpID"] as int : 0,
      name: (json["ExpDesc"] != null) ? json["ExpDesc"].toString() : "N/A",
      price: json["TotalPrice"] != null
          ? (json["TotalPrice"] as num).toDouble()
          : 0.0,
      createdAt:
          json["CreatedAT"] != null ? DateTime.parse(json["CreatedAT"]) : null,
    );
  }

  factory ExpensesItemModel.fromExpensesTypeJson(Map<String, dynamic> json) {
    return ExpensesItemModel(
      id: json["id"] != null ? json["id"] as int : 0,
      name: (json["name"] != null) ? json["name"].toString() : "N/A",
      price: json["price"] != null ? (json["price"] as num).toDouble() : 0.0,
    );
  }

  @override
  String toString() {
    return 'ExpensesItemModel{id: $id, name: $name, price: $price}';
  }
}
