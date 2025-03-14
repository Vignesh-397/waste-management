import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_management/providers/auth_provider.dart';
import 'package:user_management/screens/report_waste_screen.dart';
import 'package:user_management/screens/authority_dashboard_screen.dart';
import 'package:user_management/screens/landing_screen.dart';
import 'package:user_management/screens/select_ward_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final bool isAuthority = authProvider.userRole == 'Authority';

    // Directly navigate based on role
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isAuthority) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ReportWasteScreen()),
        );
      }
    });

    return isAuthority
        ? AuthorityHomeScreen(authProvider: authProvider)
        : const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class AuthorityHomeScreen extends StatelessWidget {
  final AuthProvider authProvider;
  const AuthorityHomeScreen({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Ward"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LandingScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: AuthorityScreen(),
    );
  }
}
