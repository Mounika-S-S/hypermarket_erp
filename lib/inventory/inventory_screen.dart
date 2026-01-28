import 'package:flutter/material.dart';
import 'inventory_service.dart';

class InventoryScreen extends StatefulWidget {
  final String storeId;
  const InventoryScreen({super.key, required this.storeId});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<dynamic>> _inventoryFuture;

  @override
  void initState() {
    super.initState();
    _inventoryFuture = InventoryService.fetchInventory(widget.storeId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory")),
      body: FutureBuilder<List<dynamic>>(
        future: _inventoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading inventory"));
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return const Center(child: Text("No inventory found"));
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final product = item['product_id'];

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(product['name']),
                  subtitle: Text("SKU: ${product['sku']}"),
                  trailing: Text(
                    "Qty: ${item['quantity']}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
