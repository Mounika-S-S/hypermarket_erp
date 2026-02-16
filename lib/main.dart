import 'package:flutter/material.dart';
import './auth/login_screen.dart';
import 'inventory/inventory_screen.dart';
import './sales/sales_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hypermarket ERP',
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => LoginScreen(),
        "/inventory": (context) => InventoryScreen(),
        "/sales": (context) => SalesScreen(),
      },
    );
  }
}
