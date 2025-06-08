import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hopeless/screens/Auth/CompleteUserInfoScreen.dart';
import 'package:hopeless/services/auth_service.dart';
import 'package:hopeless/screens/homescreen.dart' as home;
class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  const OTPScreen({
    Key? key,
    required this.verificationId,
    required this.phoneNumber,
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

      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        print('Step 2: Firebase sign-in successful');
        final idToken = await user.getIdToken();
        print('Firebase ID Token: $idToken');

        print('Step 3: Sending token to backend for UID...');
        final uid = await AuthService.verifyWithBackend(idToken!);
        print('UID from backend: $uid');

        print('Step 4: Checking user status on backend...');
        final hasProfile = await AuthService.checkUserStatusWithIdToken(idToken);

        if (hasProfile) {
          print('User has profile → Navigating to Home');
         Navigator.pushReplacement(
  context,
  MaterialPageRoute(builder: (_) => home.HomeScreen()),
);

        } else {
          print('User does not have profile → Navigating to Complete Info');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CompleteUserInfoScreen()),
          );
        }
      }
    } catch (e) {
      print('ERROR during verification: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("حدث خطأ أثناء التحقق")),
      );
      setState(() => _loading = false);
    }
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
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('متابعة', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
