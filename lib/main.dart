import 'package:flutter/material.dart';
import 'package:toothconnect_mobile_app/screens/appointments/book_services_screen.dart';
import 'package:toothconnect_mobile_app/screens/patients/patient_records_screen.dart';
import 'package:toothconnect_mobile_app/screens/treatments/dental_treatment_plan_screen.dart';

// AUTHENTICATION
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';

// HOME
import 'screens/home/dashboard_screen.dart';

// MESSAGES
import 'screens/messages/messages_list_screen.dart';
import 'screens/messages/message_thread_screen.dart';

// NOTIFICATIONS
import 'screens/notifications/notifications_screen.dart';

// PATIENTS
import 'screens/patients/profile_screen.dart';

//APPOINTMENT
import 'screens/appointments/appointments_screen.dart';

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
      title: 'ToothConnect',
      theme: AppTheme.lightTheme,
      routes: {
        // AUTHENTICATION
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/reset-password': (context) => const ResetPasswordScreen(),

        // HOME
        '/home': (context) => const DashboardScreen(),

        // MESSAGES
        '/messages-list': (context) => const MessagesListScreen(),
        '/message-thread': (context) => const MessageThreadScreen(),

        // NOTIFICATIONS
        '/notifications': (context) => const NotificationsScreen(),

        // PATIENT
        '/profile': (context) => const ProfileScreen(),

        //APPOINTMENT
        '/appointments':(context) => const AppointmentScreenState(),

        //BOOK APPOINTMENT
        '/book-appointment':(context) => const AppointmentBookState(),

        //HISTORY
        '/records':(context) => const PatientRecordState(),

        //DENTAL TREATMENT
        '/dental-treatment-plan':(context)=> const DentalPlanState(),

      },
      home: const AppointmentScreenState(),
    );
  }
}