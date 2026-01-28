import '../core/api/api_client.dart';

class SalesService {
  static Future<bool> createSale(
    String storeId,
    List<Map<String, dynamic>> items,
  ) async {
    final response = await ApiClient.post(
      '/sales',
      {
        'store_id': storeId,
        'items': items,
      },
    );

    return response.statusCode == 201;
  }
}
