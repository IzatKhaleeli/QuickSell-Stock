import 'package:flutter/material.dart';
import '../Models/ExpensesItemModel.dart';
import '../api_services/expenses_service.dart';

class ExpenseState extends ChangeNotifier {
  List<ExpensesItemModel> _expenses = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ExpensesItemModel> get expenses => _expenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch expenses from API
  Future<void> fetchExpenses(BuildContext context) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<ExpensesItemModel> fetchedExpenses =
          await ExpensesService.fetchExpenses(context);
      _expenses = fetchedExpenses;
    } catch (e) {
      _errorMessage = "Failed to load expenses: $e";
      _expenses = [];
      debugPrint("_errorMessage:${_errorMessage}");
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearExpenses() {
    _expenses = [];
    notifyListeners();
  }

  void clearState() {
    _expenses = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
