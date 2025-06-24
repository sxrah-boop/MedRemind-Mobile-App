import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hopeless/screens/Auth/otp_screen.dart';

enum UserType { patient, caregiver }

class PhoneLoginScreen extends StatefulWidget {
  final UserType userType;

  const PhoneLoginScreen({Key? key, required this.userType}) : super(key: key);

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

  String get _userTypeTitle {
    return widget.userType == UserType.patient ? 'للمريض' : 'للمرافق';
  }

  String get _userTypeIcon {
    return widget.userType == UserType.patient ? '🧑‍⚕️' : '👨‍👩‍👧‍👦';
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
      // FirebaseAuth.instance.setSettings(appVerificationDisabledForTesting: true);

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
            'internal-error': 'حدث خطأ داخلي. أعد المحاولة.',
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
              builder:
                  (_) => OTPScreen(
                    verificationId: verificationId,
                    phoneNumber: fullPhone,
                    userType: widget.userType,
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF112A54)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // User type indicator
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF112A54).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _userTypeTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF112A54),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(_userTypeIcon, style: const TextStyle(fontSize: 20)),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'السلام عليكم 👋',
                style: theme.titleMedium?.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF112A54),
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 8),
              Text(
                'أدخل رقم هاتفك لتسجيل الدخول',
                style: theme.bodyMedium?.copyWith(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 40),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textDirection: TextDirection.ltr,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8F9FA),
                  labelText: 'رقم الهاتف',
                  labelStyle: TextStyle(color: Colors.grey.shade600),
                  prefixText: '+213 ',
                  prefixStyle: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: Color(0xFF112A54),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _loading ? null : _sendOTP,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF112A54),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  elevation: 0,
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child:
                    _loading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text('إرسال رمز التحقق'),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
