import 'package:flutter/material.dart';
import '../core/api/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../sales/sales_history_screen.dart';
import '../admin/user_management_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({Key? key}) : super(key: key);

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ApiClient _api = ApiClient();

  String? role;
  String? selectedBranch;
  List branches = [];
  List products = [];

  @override
  void initState() {
    super.initState();
    loadRole();
    loadBranches();
  }

  Future<void> loadRole() async {
    role = await SecureStorage().getRole();
    setState(() {});
  }

  Future<void> loadBranches() async {
    final data = await _api.get("/branches");
    branches = data;
    setState(() {});
  }

  Future<void> loadProducts() async {
    if (selectedBranch == null) return;
    final data = await _api.get("/inventory/$selectedBranch");
    products = data;
    setState(() {});
  }

  bool get canEdit => role == "ADMIN" || role == "MANAGER";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventory"),
        actions: [
          if (role == "ADMIN" || role == "MANAGER")
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const SalesHistoryScreen()),
                );
              },
            ),
          if (role == "ADMIN")
            IconButton(
              icon: const Icon(Icons.people),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const UserManagementScreen()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SecureStorage().clear();
              Navigator.pushReplacementNamed(context, "/");
            },
          )
        ],
      ),
      floatingActionButton: canEdit && selectedBranch != null
          ? FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AddProductDialog(
                    branchId: selectedBranch!,
                    onAdded: loadProducts,
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        children: [
          DropdownButton<String>(
            hint: const Text("Select Branch"),
            value: selectedBranch,
            isExpanded: true,
            items: branches.map<DropdownMenuItem<String>>((b) {
              return DropdownMenuItem(
                value: b["_id"],
                child: Text(b["name"]),
              );
            }).toList(),
            onChanged: (value) {
              selectedBranch = value;
              loadProducts();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return Card(
                  child: ListTile(
                    title: Text(p["name"]),
                    subtitle: Text(
                        "Qty: ${p["quantity"]} ${p["unit"]} | ₹${p["unitPrice"]}"),
                    trailing: canEdit
                        ? IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => EditProductDialog(
                                  product: p,
                                  onUpdated: loadProducts,
                                ),
                              );
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class EditProductDialog extends StatefulWidget {
  final Map product;
  final VoidCallback onUpdated;

  const EditProductDialog({
    Key? key,
    required this.product,
    required this.onUpdated,
  }) : super(key: key);

  @override
  State<EditProductDialog> createState() =>
      _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final ApiClient _api = ApiClient();
  late TextEditingController qtyController;

  @override
  void initState() {
    super.initState();
    qtyController = TextEditingController(
        text: widget.product["quantity"].toString());
  }

  void updateProduct() async {
    final newQty = int.parse(qtyController.text);
    if (newQty < 0) return;

    await _api.put("/inventory/${widget.product["_id"]}", {
      "quantity": newQty
    });

    widget.onUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Quantity"),
      content: TextField(
        controller: qtyController,
        keyboardType: TextInputType.number,
      ),
      actions: [
        ElevatedButton(
            onPressed: updateProduct,
            child: const Text("Update"))
      ],
    );
  }
}

class AddProductDialog extends StatefulWidget {
  final String branchId;
  final VoidCallback onAdded;

  const AddProductDialog({
    Key? key,
    required this.branchId,
    required this.onAdded,
  }) : super(key: key);

  @override
  State<AddProductDialog> createState() =>
      _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final ApiClient _api = ApiClient();

  final nameController = TextEditingController();
  final qtyController = TextEditingController();
  final priceController = TextEditingController();
  String unit = "NOS";

  void addProduct() async {
    final qty = int.parse(qtyController.text);
    final price = double.parse(priceController.text);

    if (qty < 0 || price < 0) return;

    await _api.post("/inventory", {
      "name": nameController.text,
      "quantity": qty,
      "unit": unit,
      "unitPrice": price,
      "branch": widget.branchId
    });

    widget.onAdded();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Product"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration:
                  const InputDecoration(labelText: "Product Name"),
            ),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Quantity"),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Unit Price"),
            ),
            DropdownButton<String>(
              value: unit,
              items: const [
                DropdownMenuItem(value: "NOS", child: Text("NOS")),
                DropdownMenuItem(value: "KG", child: Text("KG")),
              ],
              onChanged: (value) {
                unit = value!;
                setState(() {});
              },
            )
          ],
        ),
      ),
      actions: [
        ElevatedButton(
            onPressed: addProduct,
            child: const Text("Add"))
      ],
    );
  }
}
