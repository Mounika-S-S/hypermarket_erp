import 'package:flutter/material.dart';
import 'product_screen.dart';
import 'sales_screen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hypermarket ERP")),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
  _card(context, "Products", Icons.inventory, () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductScreen()),
    );
  }),

  _card(context, "Sales", Icons.point_of_sale, () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SalesScreen()),
    );
  }),
],


      ),
      
    );
    
  }
  Widget _card(
  BuildContext context,
  String title,
  IconData icon,
  VoidCallback onTap,
) {
  return Card(
    elevation: 4,
    child: InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 18)),
        ],
      ),
    ),
  );
}

}
