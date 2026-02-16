import '../core/api/api_client.dart';

class SalesService {
  final ApiClient _api = ApiClient();

  Future<List<dynamic>> getBranches() async {
    return await _api.get("/branches");
  }

  Future<List<dynamic>> getProducts(String branchId) async {
    return await _api.get("/inventory/$branchId");
  }

  Future<dynamic> createSale(Map data) async {
    return await _api.post("/sales", data);
  }
}
