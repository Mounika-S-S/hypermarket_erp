import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api/api_client.dart';

class InventoryService {
  static Future<List<dynamic>> fetchInventory(String storeId) async {
    final response = await ApiClient.get(
      '/inventory?store_id=$storeId',
    );

    final decoded = json.decode(response.body);

    if (response.statusCode == 200 && decoded['error'] == false) {
      return decoded['data'];
    } else {
      throw Exception('Failed to load inventory');
    }
  }
}
