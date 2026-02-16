import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  final AuthService _auth = AuthService();

void _login() async {
  try {
    final role = await _auth.login(
      _username.text.trim(),
      _password.text.trim(),
    );

    print("ROLE: $role");

    if (!mounted) return;

    if (role == "ADMIN" || role == "MANAGER") {
      Navigator.pushReplacementNamed(context, "/inventory");
    } else if (role == "EMPLOYEE") {
      Navigator.pushReplacementNamed(context, "/sales");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid credentials")),
      );
    }
  } catch (e) {
    print("LOGIN ERROR: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _username, decoration: InputDecoration(labelText: "Username")),
            TextField(controller: _password, obscureText: true, decoration: InputDecoration(labelText: "Password")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _login, child: Text("Login"))
          ],
        ),
      ),
    );
  }
}
