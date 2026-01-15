import 'package:flutter/material.dart';
import '../db/database_helper.dart';
import '../models/product.dart';
import '../models/inventory_transaction.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _qtyController = TextEditingController();

  List<Product> products = [];
  int? selectedProductId;
  String transactionType = "IN"; // IN or OUT

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final data = await DatabaseHelper.instance.getProducts();
    setState(() {
      products = data;
      if (products.isNotEmpty) {
        selectedProductId ??= products.first.id;
      }
    });
  }

  Future<void> submitInventory() async {
    if (selectedProductId == null || _qtyController.text.isEmpty) return;

    final qty = int.parse(_qtyController.text);

    final product =
        products.firstWhere((p) => p.id == selectedProductId);

    if (transactionType == "OUT" && product.stock < qty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Insufficient stock"),
      backgroundColor: Colors.red,
    ),
  );
  return;
}

final newStock =
    transactionType == "IN" ? product.stock + qty : product.stock - qty;


    // Update product stock
    final updatedProduct = Product(
      id: product.id,
      name: product.name,
      price: product.price,
      stock: newStock,
    );

    await DatabaseHelper.instance.updateProduct(updatedProduct);

    // Record inventory transaction
    await DatabaseHelper.instance.insertInventoryTransaction(
      InventoryTransaction(
        productId: product.id!,
        type: transactionType,
        quantity: qty,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );

    _qtyController.clear();
    await loadProducts();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Inventory updated")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory")),
      floatingActionButton: FloatingActionButton(
        onPressed: submitInventory,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product dropdown
              DropdownButtonFormField<int>(
                value: selectedProductId,
                decoration:
                    const InputDecoration(labelText: "Select Product"),
                items: products.map((p) {
                  return DropdownMenuItem<int>(
                    value: p.id,
                    child: Text("${p.name} (Stock: ${p.stock})"),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedProductId = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Quantity
              TextField(
                controller: _qtyController,
                keyboardType: TextInputType.number,
                decoration:
                    const InputDecoration(labelText: "Quantity"),
              ),

              const SizedBox(height: 16),

              // IN / OUT selector
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Stock IN"),
                      value: "IN",
                      groupValue: transactionType,
                      onChanged: (v) {
                        setState(() => transactionType = v!);
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text("Stock OUT"),
                      value: "OUT",
                      groupValue: transactionType,
                      onChanged: (v) {
                        setState(() => transactionType = v!);
                      },
                    ),
                  ),
                ],
              ),

              const Divider(height: 32),

              const Text(
                "Current Products",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              ...products.map(
                (p) => Card(
                  child: ListTile(
                    title: Text(p.name),
                    subtitle: Text(
                      "Price: ₹${p.price} | Stock: ${p.stock}",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
