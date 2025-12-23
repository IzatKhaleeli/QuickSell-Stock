import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

Future<void> saveCredentials(String username, String password) async {
  await storage.write(key: 'username', value: username);
  await storage.write(key: 'password', value: password);
}

Future<Map<String, String?>> getCredentials() async {
  String? username = await storage.read(key: 'username');
  String? password = await storage.read(key: 'password');
  return {'username': username, 'password': password};
}

Future<void> deleteCredentials() async {
  await storage.delete(key: 'username');
  await storage.delete(key: 'password');
}
