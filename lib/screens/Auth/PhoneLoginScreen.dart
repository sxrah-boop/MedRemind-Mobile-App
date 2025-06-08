import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hopeless/screens/Auth/otp_screen.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _loading = false;

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _formatPhone(String input) {
    final phone = input.trim().replaceAll(' ', '');
    return phone.startsWith('+') ? phone : '+213$phone';
  }

  void _sendOTP() async {
  final phone = _phoneController.text.trim();
  print('[DEBUG] Raw input: $phone');

  if (phone.length < 9) {
    _showMessage('أدخل رقم هاتف صحيح');
    return;
  }

  final fullPhone = _formatPhone(phone);
  print('[DEBUG] Formatted phone: $fullPhone');
  setState(() => _loading = true);

  try {
    print('[DEBUG] Starting verifyPhoneNumber...');
    FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);

    await _auth.verifyPhoneNumber(
      phoneNumber: fullPhone,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        print('[DEBUG] ✅ verificationCompleted callback triggered');
        try {
          await _auth.signInWithCredential(credential);
          print('[DEBUG] ✅ signInWithCredential succeeded');
        } catch (e) {
          print('[ERROR] signInWithCredential failed: $e');
        }
      },
      verificationFailed: (e) {
        print('[ERROR] ❌ verificationFailed: ${e.code} - ${e.message}');
        final errors = {
          'invalid-phone-number': 'رقم الهاتف غير صالح',
          'too-many-requests': 'عدد كبير من المحاولات. حاول لاحقًا.',
          'quota-exceeded': 'تم تجاوز حد الإرسال للمشروع.',
          'internal-error': 'حدث خطأ داخلي. أعد المحاولة.'
        };
        _showMessage(errors[e.code] ?? 'خطأ: ${e.message}');
        setState(() => _loading = false);
      },
      codeSent: (verificationId, _) {
        print('[DEBUG] 📩 codeSent: verificationId=$verificationId');
        setState(() => _loading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OTPScreen(
              verificationId: verificationId,
              phoneNumber: fullPhone,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (id) {
        print('[DEBUG] ⌛️ codeAutoRetrievalTimeout: $id');
      },
    );
    print('[DEBUG] Called verifyPhoneNumber, no immediate error');
  } catch (e) {
    print('[ERROR] Exception in _sendOTP: $e');
    _showMessage('حدث خطأ أثناء الإرسال');
    setState(() => _loading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('السلام عليكم 👋',
                  style: theme.titleMedium?.copyWith(
                      fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right),
              const SizedBox(height: 8),
              Text('أدخل رقم هاتفك لتسجيل الدخول',
                  style: theme.bodyMedium, textAlign: TextAlign.right),
              const SizedBox(height: 32),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF2F4F7),
                  labelText: 'رقم الهاتف',
                  prefixText: '+213 ',
                  prefixStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: Color(0xFF112A54), width: 1.4),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _sendOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF112A54),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('إرسال رمز التحقق'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
