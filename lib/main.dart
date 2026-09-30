import 'package:flutter/material.dart';

// AUTHENTICATION
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';

import 'theme/app_theme.dart';

void main() {
  runApp(const ToothConnectApp());
}

class ToothConnectApp extends StatelessWidget {
  const ToothConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "ToothConnect",
      theme: AppTheme.lightTheme,
      routes: {
        "/login": (context) => const LoginScreen(),
        "/register": (context) => const RegisterScreen(),
        "/forgot-password": (context) => const ForgotPasswordScreen(),
        "/reset-password": (context) => const ResetPasswordScreen(),
      },
      home: const LoginScreen(),
    );
  }
}