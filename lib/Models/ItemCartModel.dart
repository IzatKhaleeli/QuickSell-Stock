import 'package:uuid/uuid.dart';

class ItemCart {
  int id;
  double purchasePrice;
  double sellingPrice;
  int quantity;
  final String guid;
  int? orderId;
  String? itemName;
  int? itemSizeId;
  String? itemSizeName;

  ItemCart({
    required this.id,
    required this.purchasePrice,
    required this.sellingPrice,
    this.itemSizeId,
    this.itemSizeName,
    this.quantity = 1,
    this.orderId,
    this.itemName,
  }) : guid = const Uuid().v4();

  factory ItemCart.fromJson(Map<String, dynamic> json) {
    return ItemCart(
      id: json["id"],
      purchasePrice: json["purchasePrice"],
      sellingPrice: json["sellingPrice"],
      quantity: json["quantity"],
      itemName: json["ItemName"] ?? " ",
    );
  }

  factory ItemCart.fromOrderItemJson(Map<String, dynamic> json) {
    return ItemCart(
      id: -1,
      purchasePrice: (json["ActualPrice"] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json["UnitPrice"] as num?)?.toDouble() ?? 0.0,
      quantity: json["Qty"] ?? 0,
      orderId: int.tryParse(json["OrderID"]?.toString() ?? '') ?? -1,
      itemName: json["ItemName"] ?? " ",
      itemSizeName: json["SizeLabel"] ?? "N/A",
    );
  }

  @override
  String toString() {
    return 'ItemCart{id: $id, purchasePrice: $purchasePrice, sellingPrice: $sellingPrice, quantity: $quantity}';
  }
}
