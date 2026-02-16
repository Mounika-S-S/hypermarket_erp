import '../core/api/api_client.dart';

class InventoryService {
  final ApiClient _api = ApiClient();

  Future<List<dynamic>> getBranches() async {
    return await _api.get("/branches");
  }

  Future<List<dynamic>> getProducts(String branchId) async {
    return await _api.get("/inventory/$branchId");
  }

  Future<void> addProduct(Map data) async {
    await _api.post("/inventory", data);
  }

  Future<void> updateProduct(String id, Map data) async {
    await _api.put("/inventory/$id", data);
  }
}
