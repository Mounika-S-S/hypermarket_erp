import 'package:flutter/material.dart';
import '../core/api/api_client.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() =>
      _UserManagementScreenState();
}

class _UserManagementScreenState
    extends State<UserManagementScreen> {
  final ApiClient _api = ApiClient();
  List users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final data = await _api.get("/users");
    users = data;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("User Management")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => CreateUserDialog(
              onUserCreated: loadUsers,
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: users.isEmpty
          ? const Center(child: Text("No users found"))
          : ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final u = users[index];
                return Card(
                  child: ListTile(
                    title: Text(u["username"]),
                    subtitle: Text(u["role"]),
                  ),
                );
              },
            ),
    );
  }
}

class CreateUserDialog extends StatefulWidget {
  final VoidCallback onUserCreated;

  const CreateUserDialog({
    Key? key,
    required this.onUserCreated,
  }) : super(key: key);

  @override
  State<CreateUserDialog> createState() =>
      _CreateUserDialogState();
}

class _CreateUserDialogState
    extends State<CreateUserDialog> {
  final ApiClient _api = ApiClient();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String role = "EMPLOYEE";

  void createUser() async {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      return;
    }

    await _api.post("/users", {
      "username": usernameController.text,
      "email": emailController.text,
      "password": passwordController.text,
      "role": role
    });

    widget.onUserCreated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create User"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration:
                  const InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: emailController,
              decoration:
                  const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: "Password"),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: role,
              items: const [
                DropdownMenuItem(
                    value: "EMPLOYEE",
                    child: Text("EMPLOYEE")),
                DropdownMenuItem(
                    value: "MANAGER",
                    child: Text("MANAGER")),
              ],
              onChanged: (value) {
                role = value!;
                setState(() {});
              },
            )
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: createUser,
          child: const Text("Create"),
        )
      ],
    );
  }
}
