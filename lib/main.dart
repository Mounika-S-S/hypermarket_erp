import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const HypermarketERP());
}

class HypermarketERP extends StatelessWidget {
  const HypermarketERP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hypermarket ERP',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
