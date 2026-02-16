import '../core/api/api_client.dart';
import '../core/storage/secure_storage.dart';

class AuthService {
  final ApiClient _api = ApiClient();
  final SecureStorage _storage = SecureStorage();

Future<String?> login(String username, String password) async {
  final response = await _api.post("/auth/login", {
    "username": username,
    "password": password
  });

  print("LOGIN RESPONSE: $response");

  if (response["token"] != null) {
    await _storage.saveToken(response["token"]);
    await _storage.saveRole(response["role"]);
    return response["role"];
  }

  return null;
}


  Future<void> logout() async {
    await _storage.clear();
  }
}
