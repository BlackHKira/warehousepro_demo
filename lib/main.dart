import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const WarehouseProApp());
}

class WarehouseProApp extends StatelessWidget {
  const WarehouseProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WarehousePro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1565C0),
        brightness: Brightness.light,
      ),
      home: const LoginScreen(),
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScreen();
  }
}
