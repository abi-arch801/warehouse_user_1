import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:warehouse_user_1/presentation/pages/app_theme.dart';
import 'package:warehouse_user_1/presentation/pages/dashboard_pages.dart';
import 'package:warehouse_user_1/presentation/pages/login_pages.dart';
import 'package:warehouse_user_1/presentation/pages/register_pages.dart';
import 'package:warehouse_user_1/presentation/pages/splash_pages.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.lightOverlay);
  runApp(const GudangProApp());
}

class GudangProApp extends StatelessWidget {
  const GudangProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GudangPro',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
