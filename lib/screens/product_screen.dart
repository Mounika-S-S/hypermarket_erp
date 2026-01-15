import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../models/product.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final data = await DatabaseHelper.instance.getProducts();
    setState(() => products = data);
  }

  Future<void> addProduct() async {
    final result = await Navigator.push<Product>(
      context,
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );

    if (result != null) {
      await DatabaseHelper.instance.insertProduct(result);
      loadProducts();
    }
  }

  Future<void> editProduct(Product product) async {
    final result = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductScreen(product: product),
      ),
    );

    if (result != null) {
      await DatabaseHelper.instance.updateProduct(result);
      loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final p = products[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              title: Text(p.name),
              subtitle: Text(
                "Price: ₹${p.price} | Stock: ${p.stock}",
              ),
              trailing: const Icon(Icons.edit),
              onTap: () => editProduct(p),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ================= ADD / EDIT PRODUCT =================

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController nameController =
      TextEditingController();
  final TextEditingController priceController =
      TextEditingController();
  final TextEditingController stockController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameController.text = widget.product!.name;
      priceController.text =
          widget.product!.price.toString();
      stockController.text =
          widget.product!.stock.toString();
    }
  }

  void save() {
    final product = Product(
      id: widget.product?.id,
      name: nameController.text,
      price: int.parse(priceController.text),
      stock: int.parse(stockController.text),
    );

    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.product == null
              ? "Add Product"
              : "Edit Product",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(labelText: "Name"),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Price"),
            ),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Stock"),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: save,
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
