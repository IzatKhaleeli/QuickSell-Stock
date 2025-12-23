import 'package:provider/provider.dart';
import '../screens/LoginScreen/LoginScreen.dart';
import '../services/api_request.dart';
import '../services/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../Constants/api_constants.dart';
import 'CartState.dart';
import 'ExpenseState.dart';
import 'ItemsState.dart';
import 'StoreState.dart';

class LoginState with ChangeNotifier {
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  bool _loginSccessful = false;

  bool get loginSccessful => _loginSccessful;
  bool get isLoading => _isLoading;
  String get username => _username;
  String get password => _password;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void isLoginSccessful(bool loginSccessful) {
    _loginSccessful = loginSccessful;
    notifyListeners();
  }

  void setUsername(String username) {
    _username = username;
    notifyListeners();
  }

  void setPassword(String password) {
    _password = password;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(
      String username, String password, BuildContext context) async {
    Map<String, dynamic> map = {
      "username": username.trim(),
      "password": password,
    };
    print("Attempting login with username, password: $map");

    try {
      final result = await ApiRequest.post(ApiConstants.loginEndPoint, map,
          context: context);

      if (result['success']) {
        if (result['data'] != null && result['data'].containsKey('token')) {
          String token = result['data']['token'].toString();
          String userId = result['data']['userId'].toString();
          String role = result['data']['role'].toString();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username.toLowerCase());
          await prefs.setString('userId', userId);
          await prefs.setString('token', token);
          await prefs.setString('role', role);

          await prefs.setBool('isLoggedIn', true);

          return {
            'success': true,
            'status': 200,
          };
        } else {
          return {
            'success': false,
            'error': 'Invalid credentials or unexpected response.',
            'status': 400,
          };
        }
      } else {
        return {
          'success': false,
          'error': result['error'] ?? 'Unknown error occurred.',
          'status': result['status'] ?? 400,
        };
      }
    } catch (e) {
      print("Login failed: $e");
      return {
        'success': false,
        'error': 'An error occurred: $e',
        'status': 400,
      };
    }
  }

  Future<Map<String, dynamic>> autoLogin(BuildContext context) async {
    Map<String, String?> credentials = await getCredentials();
    String? username = credentials['username'];
    String? password = credentials['password'];

    if (username != null && password != null) {
      print("Auto login attempt for: $username");

      var response = await login(username, password, context);

      if (response['success']) {
        print("Auto login successful!");
        _username = username;
        notifyListeners();
        print("data from login is L=:${response}");
        return response;
      } else {
        print("Auto login failed: ${response['error']}");
        await deleteCredentials();
      }
    } else {
      print("No stored credentials found.");
    }
    return {
      'success': false,
      'error': 'Unknown error occurred.',
      'status': 400,
    };
  }

  void clearState() {
    _username = '';
    _password = '';
    _loginSccessful = false;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      _username = '';
      _password = '';
      _loginSccessful = false;

      notifyListeners();

      if (token != null) {
        await prefs.remove('username');
        await prefs.remove('token');
        print("Logged out successfully from server");

        Provider.of<CartState>(context, listen: false).clearState();
        Provider.of<LoginState>(context, listen: false).clearState();
        Provider.of<StoresState>(context, listen: false).clearState();
        Provider.of<ItemsState>(context, listen: false).clearState();
        Provider.of<ExpenseState>(context, listen: false).clearState();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        final snackBar = SnackBar(
          content: Text('Unexpected error. Please log in again.'),
          backgroundColor: Colors.orange,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      print("Logout failed: $e");
    }
  }
}
