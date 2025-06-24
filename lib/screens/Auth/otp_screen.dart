import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hopeless/Aidant/CaregiverHome.dart';
import 'package:hopeless/Aidant/CaregiverInfoScreen.dart';
import 'package:hopeless/screens/Auth/CompleteUserInfoScreen.dart';
import 'package:hopeless/screens/homescreen.dart' as home;
import 'package:hopeless/services/auth_service.dart';

// Make sure to import UserType from wherever you define it
import 'package:hopeless/screens/Auth/PhoneLoginScreen.dart' show UserType;
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;
  final UserType userType;

  const OTPScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
    required this.userType,
  }) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;

  void _verifyCode() async {
    final code = _codeController.text.trim();
    print('Entered Code: $code');

    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("أدخل رمز تحقق مكون من 6 أرقام")),
      );
      return;
    }

    setState(() => _loading = true);
    print('Step 1: Verifying SMS code with Firebase...');

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user == null) throw Exception("Firebase user is null after sign-in.");

      print('Step 2: Firebase sign-in successful');
      final idToken = await user.getIdToken();

      try {
        print('Step 3: Sending token to backend for UID...');
        final uid = await AuthService.verifyWithBackend(idToken!);
        print('UID from backend: $uid');

        print('Step 4: Checking user status on backend...');

        // Check both user types to determine the user's actual status
        bool isPatient = false;
        bool isCaregiver = false;

        try {
          isPatient = await AuthService.checkUserStatusWithIdToken(
            idToken,
            userType: UserType.patient,
          );
        } catch (e) {
          print('Patient check failed: $e');
        }

        try {
          isCaregiver = await AuthService.checkUserStatusWithIdToken(
            idToken,
            userType: UserType.caregiver,
          );
        } catch (e) {
          print('Caregiver check failed: $e');
        }

        // Navigate based on actual user status, not the selected type
        if (isPatient) {
          print('✅ User is registered as Patient → Navigating to Patient Home');

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('patient_token', idToken);
          print('🔒 Saved patient token to SharedPreferences');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => home.HomeScreen()),
          );
        } else if (isCaregiver) {
          print(
            '✅ User is registered as Caregiver → Navigating to Caregiver Home',
          );
          print('Aidant token: $idToken');

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('caregiver_token', idToken);
          print('🔒 Saved caregiver token to SharedPreferences');

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => CaregiverHomeScreen()),
          );
        } else {
          // User has neither profile, navigate to complete profile based on selected type
          print('📝 User needs to complete profile → Navigating accordingly');

          if (widget.userType == UserType.patient) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CompleteUserInfoScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const CaregiverInfoScreen()),
            );
          }
        }
      } catch (backendError) {
        print('[❌ BACKEND ERROR] $backendError');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("خطأ من الخادم: ${backendError.toString()}")),
        );
      }
    } catch (firebaseError) {
      print('[❌ FIREBASE ERROR] $firebaseError');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("خطأ من Firebase: ${firebaseError.toString()}")),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('رمز التحقق'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'أدخل رمز التحقق المُرسل إلى ${widget.phoneNumber}',
              style: theme.bodyMedium,
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codeController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(letterSpacing: 32, fontSize: 20),
              decoration: const InputDecoration(
                counterText: "",
                border: OutlineInputBorder(),
                hintText: '••••••',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _verifyCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF112A54),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child:
                  _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'متابعة',
                        style: TextStyle(color: Colors.white),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
