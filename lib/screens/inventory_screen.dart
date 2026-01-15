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
  List<Product> products = [];
  Product? selectedProduct;
  List<InventoryTransaction> transactions = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final data = await DatabaseHelper.instance.getProducts();
    setState(() => products = data);
  }

  Future<void> loadTransactions(int productId) async {
    final data = await DatabaseHelper.instance
        .getTransactionsByProduct(productId);
    setState(() => transactions = data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Product selector
            DropdownButtonFormField<Product>(
              hint: const Text("Select product"),
              items: products
                  .map(
                    (p) => DropdownMenuItem(
                      value: p,
                      child: Text(
                        "${p.name} (Stock: ${p.stock})",
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedProduct = value;
                  transactions.clear();
                });
                if (value != null) {
                  loadTransactions(value.id!);
                }
              },
            ),

            const SizedBox(height: 20),

            /// Inventory history
            Expanded(
              child: transactions.isEmpty
                  ? const Center(
                      child: Text("No inventory records"),
                    )
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final t = transactions[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(
                              t.type == "IN"
                                  ? Icons.add
                                  : Icons.remove,
                              color: t.type == "IN"
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            title: Text(
                              "${t.type} : ${t.quantity}",
                            ),
                            subtitle: Text(t.createdAt),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
