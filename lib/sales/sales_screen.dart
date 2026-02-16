import 'package:flutter/material.dart';
import '../core/storage/secure_storage.dart';
import 'sales_service.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final SalesService _service = SalesService();

  String? selectedBranch;
  List<Map<String, dynamic>> branches = [];
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> cart = [];

  Map<String, dynamic>? selectedProduct;

  final TextEditingController quantityController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadBranches();
  }

  Future<void> loadBranches() async {
    final data = await _service.getBranches();
    branches = List<Map<String, dynamic>>.from(data);
    setState(() {});
  }

  Future<void> fetchProducts() async {
    if (selectedBranch == null) return;
    final data = await _service.getProducts(selectedBranch!);
    products = List<Map<String, dynamic>>.from(data);
    setState(() {});
  }

  double get grandTotal {
    return cart.fold(
      0.0,
      (sum, item) => sum + (item["lineTotal"] as double),
    );
  }

  void addToCart() {
    if (selectedProduct == null) return;

    if (quantityController.text.isEmpty) return;

    final int qty = int.parse(quantityController.text);

    final int availableQty = selectedProduct!["quantity"];

    if (qty > availableQty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quantity exceeds stock")),
      );
      return;
    }

    final double unitPrice =
        (selectedProduct!["unitPrice"] as num).toDouble();

    final double lineTotal = qty * unitPrice;

    cart.add({
      "productId": selectedProduct!["_id"],
      "quantity": qty,
      "lineTotal": lineTotal,
    });

    quantityController.clear();

    setState(() {});
  }

  Future<void> submitSale() async {
    if (selectedBranch == null || cart.isEmpty) return;

    final response = await _service.createSale({
      "branchId": selectedBranch,
      "items": cart
          .map((e) => {
                "productId": e["productId"],
                "quantity": e["quantity"],
              })
          .toList(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Total: ₹${response["totalAmount"]}")),
    );

    cart.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SecureStorage().clear();
              Navigator.pushReplacementNamed(context, "/");
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButton<String>(
              hint: const Text("Select Branch"),
              value: selectedBranch,
              isExpanded: true,
              items: branches.map((b) {
                return DropdownMenuItem<String>(
                  value: b["_id"],
                  child: Text(b["name"]),
                );
              }).toList(),
              onChanged: (value) {
                selectedBranch = value;
                fetchProducts();
              },
            ),

            const SizedBox(height: 20),

            Autocomplete<Map<String, dynamic>>(
              optionsBuilder:
                  (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<
                      Map<String, dynamic>>.empty();
                }

                return products.where((product) {
                  final name =
                      product["name"].toString().toLowerCase();
                  return name.contains(
                      textEditingValue.text.toLowerCase());
                });
              },
              displayStringForOption: (option) =>
                  "${option["name"]} (${option["quantity"]} ${option["unit"]})",
              onSelected: (option) {
                selectedProduct = option;
              },
            ),

            const SizedBox(height: 20),

            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Quantity"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: addToCart,
              child: const Text("Add"),
            ),

            const SizedBox(height: 20),

            Text(
              "Grand Total: ₹${grandTotal.toStringAsFixed(2)}",
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: submitSale,
              child: const Text("Complete Sale"),
            ),
          ],
        ),
      ),
    );
  }
}
