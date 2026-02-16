import 'package:flutter/material.dart';
import '../core/api/api_client.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({Key? key}) : super(key: key);

  @override
  State<SalesHistoryScreen> createState() =>
      _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final ApiClient _api = ApiClient();
  List sales = [];

  @override
  void initState() {
    super.initState();
    loadSales();
  }

  Future<void> loadSales() async {
    final data = await _api.get("/sales/history");
    sales = data;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sales History")),
      body: sales.isEmpty
          ? const Center(child: Text("No sales found"))
          : ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final s = sales[index];
                return Card(
                  child: ListTile(
                    title: Text("₹${s["totalAmount"]}"),
                    subtitle: Text(
                      "${s["branch"]["name"]} | ${s["createdBy"]["username"]}",
                    ),
                  ),
                );
              },
            ),
    );
  }
}
