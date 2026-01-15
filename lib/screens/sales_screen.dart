import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/product.dart';
import '../models/sale.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  Product? selectedProduct;
  List<Product> products = [];
  final TextEditingController qtyController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final data = await DatabaseHelper.instance.getProducts();
    setState(() => products = data);
  }

  Future<void> submitSale() async {
    if (selectedProduct == null) return;

    final qty = int.parse(qtyController.text);

    // Reduce stock
    selectedProduct!.stock -= qty;
    await DatabaseHelper.instance.updateProduct(selectedProduct!);

    // Insert sale
    await DatabaseHelper.instance.insertSale(
      Sale(
        productId: selectedProduct!.id!,
        quantity: qty,
        price: selectedProduct!.price,
        total: selectedProduct!.price * qty,
        createdAt: DateTime.now().toIso8601String(),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Sale")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<Product>(
              hint: const Text("Select product"),
              items: products
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                          "${p.name} (Stock: ${p.stock})"),
                    ),
                  )
                  .toList(),
              onChanged: (value) =>
                  setState(() => selectedProduct = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Quantity"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: submitSale,
              child: const Text("Submit Sale"),
            ),
          ],
        ),
      ),
    );
  }
}
