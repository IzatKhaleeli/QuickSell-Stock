class ItemModel {
  double sellingPrice;
  double purchasePrice;
  int itemId;
  String? itemName;
  int? stockCount;

  ItemModel({
    required this.sellingPrice,
    required this.purchasePrice,
    required this.itemId,
    this.itemName,
    this.stockCount,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      sellingPrice: (json["Price"] as num).toDouble(),
      purchasePrice: (json["ActualPrice"] as num).toDouble(),
      itemId: json["ItemID"] != null ? int.parse(json["ItemID"]) : 0,
      itemName: json["ItemName"] ?? " ",
      stockCount: json["StockCount"] != null
          ? int.parse(json["StockCount"].toString())
          : 0,
    );
  }

  @override
  String toString() {
    return 'ItemModel(itemId: $itemId, sellingPrice: $sellingPrice, purchasePrice: $purchasePrice, itemName: $itemName, stockCount: $stockCount)';
  }
}
