import 'package:flutter/material.dart';

import '../inventory/inventory_screen.dart';
import 'sales_service.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final _storeController = TextEditingController();
  final _productController = TextEditingController();
  final _qtyController = TextEditingController();

  final List<_CartItem> _cart = [];
  bool _loading = false;

  void _addToCart() {
    final productId = _productController.text.trim();
    final qty = int.tryParse(_qtyController.text);

    if (productId.isEmpty || qty == null || qty <= 0) {
      _showMessage('Enter valid product and quantity');
      return;
    }

    setState(() {
      _cart.add(_CartItem(productId: productId, quantity: qty));
    });

    _productController.clear();
    _qtyController.clear();
  }

  void _removeItem(int index) {
    setState(() {
      _cart.removeAt(index);
    });
  }

  Future<void> _completeSale() async {
    final storeId = _storeController.text.trim();

    if (storeId.isEmpty) {
      _showMessage('Store ID is required');
      return;
    }

    if (_cart.isEmpty) {
      _showMessage('Cart is empty');
      return;
    }

    setState(() => _loading = true);

    final success = await SalesService.createSale(
      storeId,
      _cart
          .map((item) => {
                'product_id': item.productId,
                'quantity': item.quantity,
              })
          .toList(),
    );

    setState(() => _loading = false);

    if (success) {
      setState(() => _cart.clear());
      _showMessage('Sale completed successfully');
    } else {
      _showMessage('Sale failed. Check stock or network.');
    }
  }

  void _openInventory() {
    final storeId = _storeController.text.trim();

    if (storeId.isEmpty) {
      _showMessage('Enter Store ID first');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InventoryScreen(storeId: storeId),
      ),
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('POS / Sales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory),
            onPressed: _openInventory,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _storeController,
              decoration: const InputDecoration(labelText: 'Store ID'),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _productController,
                    decoration:
                        const InputDecoration(labelText: 'Product ID'),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 90,
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Qty'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _addToCart,
              child: const Text('Add to Cart'),
            ),

            const SizedBox(height: 20),
            Expanded(
              child: _cart.isEmpty
                  ? const Center(child: Text('Cart is empty'))
                  : ListView.builder(
                      itemCount: _cart.length,
                      itemBuilder: (context, index) {
                        final item = _cart[index];
                        return Card(
                          child: ListTile(
                            title: Text('Product: ${item.productId}'),
                            subtitle:
                                Text('Quantity: ${item.quantity}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeItem(index),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _completeSale,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Complete Sale'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItem {
  final String productId;
  final int quantity;

  _CartItem({required this.productId, required this.quantity});
}
