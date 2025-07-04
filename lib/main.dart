// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:hopeless/Aidant/CaregiverHome.dart';
// import 'package:hopeless/Aidant/fetchRole.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:awesome_notifications/awesome_notifications.dart';

// import 'firebase_options.dart';
// import 'notification-reminders/notification_servicee_basic.dart';
// import 'screens/homescreen.dart';
// import 'screens/notification_screen.dart';
// import 'screens/Auth/user_type_selection_screen.dart';

// final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Firebase
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // Initialize Notifications
//   await NotificationService.init();
//   await initializeDateFormatting();

//   runApp(MyApp());
// }

// class MyApp extends StatefulWidget {
//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   String? screenToLaunch;
//   Widget? _initialScreen;

//   @override
//   void initState() {
//     super.initState();
//     _setupInitialScreen();
//   }
// // Future<void> _setupInitialScreen() async {
// //   SharedPreferences prefs = await SharedPreferences.getInstance();
// //   final payloadJson = prefs.getString('initial_payload');

// //   if (payloadJson != null) {
// //     final Map<String, dynamic> payload = jsonDecode(payloadJson);
// //     screenToLaunch = payload['screen'];
// //     await prefs.remove('initial_payload');

// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       if (screenToLaunch == 'notification') {
// //         navKey.currentState?.pushNamedAndRemoveUntil(
// //           '/notification',
// //           (route) => false,
// //           arguments: payload,
// //         );
// //       }
// //     });
// //   }

// //   final patientToken = prefs.getString('patient_token');
// //   final caregiverToken = prefs.getString('caregiver_token');
// //   final idToken = caregiverToken ?? patientToken;

// //   if (idToken != null) {
// //     if (caregiverToken != null) {
// //       print('🟢 Authenticated as Caregiver');
// //       print('🔐 Caregiver token: $caregiverToken');
// //     } else {
// //       print('🔵 Authenticated as Patient');
// //       print('🔐 Patient token: $patientToken');
// //     }

// //     try {
// //       final userRoleData = await fetchUserRole(idToken);
// //       final role = userRoleData['role'];
// //       print('📋 Backend role response: $role');

// //       setState(() {
// //         if (role == 'patient') {
// //           _initialScreen = const HomeScreen();
// //         } else if (role == 'aidant') {
// //           _initialScreen = const CaregiverHomeScreen();
// //         } else {
// //           _initialScreen = const UserTypeSelectionScreen();
// //         }
// //       });
// //     } catch (e) {
// //       print('❌ Failed to fetch user role. Redirecting to UserTypeSelectionScreen. Error: $e');
// //       setState(() {
// //         _initialScreen = const UserTypeSelectionScreen();
// //       });
// //     }
// //   } else {
// //     print('❌ No token found. Redirecting to UserTypeSelectionScreen.');
// //     setState(() {
// //       _initialScreen = const UserTypeSelectionScreen();
// //     });
// //   }
// // }
// Future<void> _setupInitialScreen() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   final payloadJson = prefs.getString('initial_payload');

//   if (payloadJson != null) {
//     final Map<String, dynamic> payload = jsonDecode(payloadJson);
//     screenToLaunch = payload['screen'];
//     await prefs.remove('initial_payload');

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (screenToLaunch == 'notification') {
//         navKey.currentState?.pushNamedAndRemoveUntil(
//           '/notification',
//           (route) => false,
//           arguments: payload,
//         );
//       }
//     });
//   }

//   final patientToken = prefs.getString('patient_token');
//   final caregiverToken = prefs.getString('caregiver_token');
//   final idToken = caregiverToken ?? patientToken;

//   if (idToken != null) {
//     if (caregiverToken != null) {
//       print('🟢 Authenticated as Caregiver');
//       print('🔐 Caregiver token: $caregiverToken');
//     } else if (patientToken != null) {
//       print('🔵 Authenticated as Patient');
//       print('🔐 Patient token: $patientToken');
//     }

//     final userRoleData = await fetchUserRole(idToken);
//     final role = userRoleData?['role'];
//     print('📋 Backend role response: $role');

//     setState(() {
//       if (role == 'patient') {
//         _initialScreen = const HomeScreen();
//       } else if (role == 'aidant') {
//         _initialScreen = const CaregiverHomeScreen();
//       } else {
//         _initialScreen = const UserTypeSelectionScreen();
//       }
//     });
//   } else {
//     print('❌ No token found in SharedPreferences. Redirecting to UserTypeSelectionScreen.');
//     setState(() {
//       _initialScreen = const UserTypeSelectionScreen();
//     });
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     // Show loading until initial screen is determined
//     if (_initialScreen == null) {
//       return const MaterialApp(
//         home: Scaffold(
//           body: Center(child: CircularProgressIndicator()),
//         ),
//       );
//     }

//     return MaterialApp(
//       navigatorKey: navKey,
//       debugShowCheckedModeBanner: false,
//       title: 'Medication Reminder',
//       theme: ThemeData(
//         scaffoldBackgroundColor: Colors.grey[100],
//         textTheme: TextTheme(
//           displayLarge: GoogleFonts.ibmPlexSansArabic(fontSize: 32, fontWeight: FontWeight.w700),
//           titleLarge: GoogleFonts.ibmPlexSansArabic(fontSize: 20, fontWeight: FontWeight.w600),
//           titleMedium: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.w600),
//           bodyLarge: GoogleFonts.ibmPlexSansArabic(fontSize: 16, fontWeight: FontWeight.w400),
//           bodyMedium: GoogleFonts.ibmPlexSansArabic(fontSize: 14, fontWeight: FontWeight.w500),
//           bodySmall: GoogleFonts.ibmPlexSansArabic(fontSize: 13, fontWeight: FontWeight.w400),
//           labelLarge: GoogleFonts.ibmPlexSansArabic(fontSize: 12, fontWeight: FontWeight.w600),
//           labelSmall: GoogleFonts.ibmPlexSansArabic(fontSize: 11, fontWeight: FontWeight.w400),
//         ),
//       ),
//       home: _initialScreen,
//       onGenerateRoute: (settings) {
//         switch (settings.name) {
//           case '/home':
//             return MaterialPageRoute(builder: (_) => const HomeScreen());

//           case '/UserTypeSelectionScreen':
//             return MaterialPageRoute(builder: (_) => const UserTypeSelectionScreen());

//           case '/notification':
//             final payload = settings.arguments as Map<String, String>;
//             return MaterialPageRoute(builder: (_) => NotificationScreen(payload: payload));

//           default:
//             return MaterialPageRoute(
//               builder: (_) => const Scaffold(
//                 body: Center(child: Text('Loading..')),
//               ),
//             );
//         }
//       },
//     );
//   }
// }


// Updated main.dart
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hopeless/Aidant/CaregiverHome.dart';
import 'package:hopeless/Aidant/fetchRole.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

import 'firebase_options.dart';
import 'notification-reminders/notification_servicee_basic.dart';
import 'screens/homescreen.dart';
import 'screens/notification_screen.dart';
import 'screens/Auth/user_type_selection_screen.dart';

final GlobalKey<NavigatorState> navKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notifications
  await NotificationService.init();
  await initializeDateFormatting();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? screenToLaunch;
  Widget? _initialScreen;

  @override
  void initState() {
    super.initState();
    _setupInitialScreen();
  }

  Future<void> _setupInitialScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Handle notification payload
    final payloadJson = prefs.getString('initial_payload');
    if (payloadJson != null) {
      final Map<String, dynamic> payload = jsonDecode(payloadJson);
      screenToLaunch = payload['screen'];
      await prefs.remove('initial_payload');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (screenToLaunch == 'notification') {
          navKey.currentState?.pushNamedAndRemoveUntil(
            '/notification',
            (route) => false,
            arguments: payload,
          );
        }
      });
    }

    // Check Firebase Auth state first
    final User? currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser != null) {
      try {
        // Get fresh token from Firebase
        final String? freshToken = await currentUser.getIdToken(true); // Force refresh
        print('🔄 Retrieved fresh Firebase token');
        
        // Fetch user role with fresh token
        final userRoleData = await fetchUserRole(freshToken);
        final role = userRoleData?['role'];
        print('📋 Backend role response: $role');

        // Store fresh token based on role
        if (role == 'patient') {
          await prefs.setString('patient_token', freshToken!);
          await prefs.remove('caregiver_token');
        } else if (role == 'aidant') {
          await prefs.setString('caregiver_token', freshToken!);
          await prefs.remove('patient_token');
        }

        setState(() {
          if (role == 'patient') {
            _initialScreen = const HomeScreen();
          } else if (role == 'aidant') {
            _initialScreen = const CaregiverHomeScreen();
          } else {
            _initialScreen = const UserTypeSelectionScreen();
          }
        });
        
      } catch (e) {
        print('❌ Failed to get fresh token or fetch user role: $e');
        // Clear stored tokens and redirect to login
        await _clearStoredTokens(prefs);
        setState(() {
          _initialScreen = const UserTypeSelectionScreen();
        });
      }
    } else {
      print('❌ No authenticated Firebase user. Redirecting to UserTypeSelectionScreen.');
      // Clear any stored tokens
      await _clearStoredTokens(prefs);
      setState(() {
        _initialScreen = const UserTypeSelectionScreen();
      });
    }
  }

  Future<void> _clearStoredTokens(SharedPreferences prefs) async {
    await prefs.remove('patient_token');
    await prefs.remove('caregiver_token');
  }

  @override
  Widget build(BuildContext context) {
    // Show loading until initial screen is determined
    if (_initialScreen == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

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
      home: _initialScreen,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());

          case '/UserTypeSelectionScreen':
            return MaterialPageRoute(builder: (_) => const UserTypeSelectionScreen());

          case '/notification':
            final payload = settings.arguments as Map<String, String>;
            return MaterialPageRoute(builder: (_) => NotificationScreen(payload: payload));

          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Loading..')),
              ),
            );
        }
      },
    );
  }
}
