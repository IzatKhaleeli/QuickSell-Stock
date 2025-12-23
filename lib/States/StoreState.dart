import 'package:flutter/material.dart';
import '../Models/StoreModel.dart';
import '../api_services/StoreService.dart';

class StoresState extends ChangeNotifier {
  List<StoreModel> _stores = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Selected store info
  Map<String, String>? _selectedStore;

  // Getters
  List<StoreModel> get stores => _stores;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, String>? get selectedStore => _selectedStore;

  // Fetch stores from API
  Future<void> fetchStores(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<StoreModel> fetchedStores = await StoreService.fetchStores(context);
      debugPrint("fetchedStores :${fetchedStores.toString()}");

      _stores = fetchedStores;
    } catch (e) {
      _errorMessage = "Failed to load stores: $e";
      _stores = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // Set selected store info
  void setSelectedStore(String storeId, String address) {
    _selectedStore = {
      "store": storeId,
      "address": address,
    };
    notifyListeners();
  }

  // Clear stores and selected store info when logging out
  void clearState() {
    _stores = [];
    _selectedStore = null;
    notifyListeners();
  }
}
