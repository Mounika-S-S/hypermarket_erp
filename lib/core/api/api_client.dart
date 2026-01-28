import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/secure_storage.dart';

class ApiClient {
  static const String baseUrl = "http://10.253.60.155:5000/api/v1";

  static Future<http.Response> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final token = await SecureStorage.getToken();

    return http.post(
      Uri.parse('$baseUrl$path'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> get(String path) async {
    final token = await SecureStorage.getToken();

    return http.get(
      Uri.parse('$baseUrl$path'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }
}
