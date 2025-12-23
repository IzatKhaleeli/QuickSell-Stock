import 'package:flutter/material.dart';
import '../Models/ItemModel.dart';
import '../api_services/ItemService.dart';

class ItemsState extends ChangeNotifier {
  List<ItemModel> _item = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ItemModel> get items => _item;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchItems(BuildContext context, int storeId) async {
    debugPrint("fetchItems started");
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<ItemModel> fetchedItems =
          await ItemService.fetchItems(context, storeId);
      _item = fetchedItems;
      debugPrint("fetchedItems :${_item.toString()}");
    } catch (e) {
      _errorMessage = "Failed to load items: $e";
      _item = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> deleteItem(
    BuildContext context,
    String itemId,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await ItemService.deleteItem(context: context, itemId: itemId);

      if (response['success'] == true &&
          (response['status'] == 200 || response['status'] == 201)) {
        return null;
      } else {
        _errorMessage = "Failed to delete item: ${response['error']}";
        return _errorMessage;
      }
    } catch (e) {
      _errorMessage = "Failed to delete item: $e";
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateItem(
    BuildContext context,
    ItemModel item,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Map<String, dynamic> body = {
        "Price": item.sellingPrice,
        "ActualPrice": item.purchasePrice,
        "ItemName": item.itemName,
        "StoreID": 1,
        "IsActive": true,
      };

      final response = await ItemService.updateItem(
          context: context, body: body, itemId: item.itemId.toString());

      if (response['success'] == true &&
          (response['status'] == 200 || response['status'] == 201)) {
        return null;
      } else {
        _errorMessage = "Failed to update item: ${response['error']}";
        return _errorMessage;
      }
    } catch (e) {
      _errorMessage = "Failed to update item: $e";
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> postItem(
    BuildContext context,
    ItemModel item,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Map<String, dynamic> body = {
        "Price": item.sellingPrice,
        "ActualPrice": item.purchasePrice,
        "ItemName": item.itemName,
        "StoreID": 1,
        "IsActive": true,
      };

      final response = await ItemService.updateItem(
          context: context, body: body, itemId: item.itemId.toString());

      if (response['success'] == true &&
          (response['status'] == 200 || response['status'] == 201)) {
        return null;
      } else {
        _errorMessage = "Failed to update item: ${response['error']}";
        return _errorMessage;
      }
    } catch (e) {
      _errorMessage = "Failed to update item: $e";
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearItems() {
    _item = [];
    notifyListeners();
  }

  void clearState() {
    _item = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
