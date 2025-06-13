import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hopeless/chatbot/chat_screen.dart';
import 'package:hopeless/screens/Auth/PhoneLoginScreen.dart';
import 'package:hopeless/screens/homescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hopeless/notification-reminders/notification_service.dart';

import 'firebase_options.dart';
import 'notification-reminders/notification_service.dart';

import 'screens/notification_screen.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase init
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Notifications init
  await NotificationService.init(); // includes listener setup + payload save if any

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? screenToLaunch;

  @override
  void initState() {
    super.initState();
    _loadInitialNotificationPayload();
  }

  Future<void> _loadInitialNotificationPayload() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final payloadJson = prefs.getString('initial_payload');

    if (payloadJson != null) {
      final Map<String, dynamic> payload = jsonDecode(payloadJson);
      screenToLaunch = payload['screen'];
      await prefs.remove('initial_payload');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (screenToLaunch == 'notification') {
          navKey.currentState?.pushNamedAndRemoveUntil('/notification', (r) => false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navKey,
      debugShowCheckedModeBanner: false,
      title: 'Medication Reminder',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: TextTheme(
          displayLarge: GoogleFonts.ibmPlexSansArabic(fontSize: 32, fontWeight: FontWeight.w700),
          titleLarge: GoogleFonts.ibmPlexSansArabic(fontSize: 20, fontWeight: FontWeight.w600),
          titleMedium: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.w600),
          bodyLarge: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium: GoogleFonts.ibmPlexSansArabic(fontSize: 14, fontWeight: FontWeight.w500),
          bodySmall: GoogleFonts.ibmPlexSansArabic(fontSize: 13, fontWeight: FontWeight.w400),
          labelLarge: GoogleFonts.ibmPlexSansArabic(fontSize: 12, fontWeight: FontWeight.w600),
          labelSmall: GoogleFonts.ibmPlexSansArabic(fontSize: 11, fontWeight: FontWeight.w400),
        ),
      ),
      initialRoute: '/',
    onGenerateRoute: (RouteSettings settings) {
  switch (settings.name) {
    case '/':
    case '/home':
      return MaterialPageRoute(builder: (_) => PhoneLoginScreen());

    case '/notification':
      final payload = settings.arguments as Map<String, String>;
      return MaterialPageRoute(
        builder: (_) => NotificationScreen(payload: payload),
      );

    default:
      return MaterialPageRoute(
        builder: (_) => const Scaffold(
          body: Center(child: Text('❌ Route not found')),
        ),
      );
  }
}

    );
  }
}
