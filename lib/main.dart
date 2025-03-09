import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:user_management/firebase_options.dart';
import 'package:user_management/providers/auth_provider.dart';
import 'package:user_management/screens/auth_screen.dart';
import 'package:user_management/screens/home_screen.dart';
import 'package:user_management/screens/landing_screen.dart';

import 'package:permission_handler/permission_handler.dart';

Future<void> requestStoragePermission() async {
  if (await Permission.storage.request().isGranted) {
    print("Storage permission granted");
  } else {
    print("Storage permission denied");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  requestStoragePermission();
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Waste Reporting App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isAuthenticated
              ? const HomeScreen()
              : const LandingScreen();
        },
      ),
    );
  }
}
