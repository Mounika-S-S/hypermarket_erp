import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  final SecureStorage _storage = SecureStorage();

  Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    };
  }

  Future<dynamic> get(String endpoint) async {
    final response = await http.get(
      Uri.parse("${AppConstants.baseUrl}$endpoint"),
      headers: await _headers(),
    );
    return jsonDecode(response.body);
  }

  Future<dynamic> post(String endpoint, Map data) async {
  final response = await http.post(
    Uri.parse("${AppConstants.baseUrl}$endpoint"),
    headers: await _headers(),
    body: jsonEncode(data),
  );

  print("STATUS: ${response.statusCode}");
  print("BODY: ${response.body}");

  if (response.statusCode >= 200 && response.statusCode < 300) {
    return jsonDecode(response.body);
  } else {
    throw Exception("API Error: ${response.body}");
  }
}


  Future<dynamic> put(String endpoint, Map data) async {
    final response = await http.put(
      Uri.parse("${AppConstants.baseUrl}$endpoint"),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    return jsonDecode(response.body);
  }
}
