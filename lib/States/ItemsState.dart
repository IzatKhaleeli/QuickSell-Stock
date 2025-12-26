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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<ItemModel> fetchedItems =
          await ItemService.fetchItems(context, storeId);
      _item = fetchedItems;
    } catch (e) {
      _errorMessage = "Failed to load items: $e";
      _item = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> deleteItem(
    BuildContext context,
    int itemId,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response =
          await ItemService.deleteItem(context: context, itemId: itemId);

      final int status = response['status'] ?? -1;

      // Treat 204 No Content as success even if body is empty or parsing failed
      if (status == 204) {
        return null;
      }

      if (response['success'] == true && (status == 200 || status == 201)) {
        return null;
      } else {
        print(
            "else Error deleting item: response ${response['error'] ?? "NA"}");

        _errorMessage = "Failed to delete item: ${response['error'] ?? "NA"}";
        return _errorMessage;
      }
    } catch (e) {
      print("catch Error deleting item: $e");
      _errorMessage = "Failed to delete item: $e";
      return _errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> updateItem(
    BuildContext context,
    int itemId,
    Map<String, dynamic> body,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ItemService.updateItem(
          context: context, body: body, itemId: itemId);

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
    Map<String, dynamic> body,
    Map<String, String> headers,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ItemService.insertItem(
        headers: headers,
        context: context,
        body: body,
      );

      if (response['success'] == true &&
          (response['status'] == 200 || response['status'] == 201)) {
        return null;
      } else {
        _errorMessage = "Failed to create item: ${response['error']}";
        return _errorMessage;
      }
    } catch (e) {
      _errorMessage = "Failed to create item: $e";
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
