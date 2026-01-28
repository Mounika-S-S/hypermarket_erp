import 'dart:convert';
import '../core/api/api_client.dart';
import '../core/storage/secure_storage.dart';

class AuthService {
  static String? currentRole;

  static Future<bool> login(String email, String password) async {
    final response = await ApiClient.post(
      '/auth/login',
      {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      await SecureStorage.saveToken(data['token']);
      currentRole = data['user']['role'];

      return true;
    }
    return false;
  }

  static bool isAdmin() => currentRole == 'admin';
  static bool isManager() => currentRole == 'manager';
  static bool isCashier() => currentRole == 'cashier';

  static Future<void> logout() async {
    await SecureStorage.clear();
    currentRole = null;
  }
}
