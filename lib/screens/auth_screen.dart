import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_management/providers/auth_provider.dart';
import 'package:user_management/screens/home_screen.dart';

class AuthScreen extends StatefulWidget {
  final String preSelectedRole;
  const AuthScreen({super.key, required this.preSelectedRole});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
  late String role;

  @override
  void initState() {
    super.initState();
    role = widget.preSelectedRole; // Set the pre-selected role
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void _authenticate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success;

    if (isLogin) {
      // Login
      success = await authProvider.login(
        emailController.text,
        passwordController.text,
      );
    } else {
      // Register
      success = await authProvider.register(
        emailController.text,
        passwordController.text,
        role,
      );
    }

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isLogin ? "Login Failed" : "Registration Failed"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Welcome")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Role Selection at the top
            ToggleButtons(
              isSelected: [role == "User", role == "Authority"],
              onPressed: (index) {
                setState(() {
                  role = index == 0 ? "User" : "Authority";
                });
              },
              borderRadius: BorderRadius.circular(10),
              selectedColor: Colors.white,
              color: Colors.black,
              fillColor: Colors.green,
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("User"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("Authority"),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Login/Register Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLogin
                      ? "Don't have an account?"
                      : "Already have an account?",
                ),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(isLogin ? "Register" : "Login"),
                ),
              ],
            ),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _authenticate,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 24,
                ),
              ),
              child: Text(isLogin ? "Login" : "Register"),
            ),
          ],
        ),
      ),
    );
  }
}
