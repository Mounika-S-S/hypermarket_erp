import 'package:flutter/material.dart';

import 'sales/sales_screen.dart';
import 'auth/login_screen.dart';

void main() {
  runApp(const HypermarketERP());
}

class HypermarketERP extends StatelessWidget {
  const HypermarketERP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hypermarket ERP',
      debugShowCheckedModeBanner: false,

      // Default screen (after auth you can change this)
      home: const SalesScreen(),

      // ❌ DO NOT ADD /inventory here because it needs storeId
      routes: {
        '/login': (_) => const LoginScreen(),
        '/sales': (_) => const SalesScreen(),
      },
    );
  }
}
