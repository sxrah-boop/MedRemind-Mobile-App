import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hopeless/services/auth_service.dart';


class CompleteUserInfoScreen extends StatefulWidget {
  const CompleteUserInfoScreen({super.key});

  @override
  State<CompleteUserInfoScreen> createState() => _CompleteUserInfoScreenState();
}

class _CompleteUserInfoScreenState extends State<CompleteUserInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('معلومات المستخدم'),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Text(
                  'أدخل معلوماتك الشخصية',
                  style: theme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 24),

                _buildTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _dobController,
                  label: 'تاريخ الميلاد',
                  readOnly: true,
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),

                DropdownButtonFormField<String>(
                  decoration: _inputDecoration('الجنس'),
                  value: _selectedGender,
                  onChanged: (value) => setState(() => _selectedGender = value),
                  validator: (value) =>
                      value == null ? 'الرجاء اختيار الجنس' : null,
                  items: const [
                    DropdownMenuItem(value: 'ذكر', child: Text('ذكر')),
                    DropdownMenuItem(value: 'أنثى', child: Text('أنثى')),
                  ],
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _addressController,
                  label: 'العنوان',
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final user = FirebaseAuth.instance.currentUser;
                        final idToken = await user?.getIdToken();
                        final phone = user?.phoneNumber;
                        final uid = user?.uid;

                        if (idToken == null || phone == null || uid == null || _selectedDate == null) {
                          throw Exception("Missing token, UID, phone number, or birth date");
                        }

                        final birthDate =
                            '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

                        await AuthService.completeUserProfile(
                          fullname: _nameController.text.trim(),
                          birthDate: birthDate,
                          gender: _selectedGender == 'ذكر' ? 'male' : 'female',
                          address: _addressController.text.trim(),
                          idToken: idToken,
                          phoneNumber: phone,
                        );

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      } catch (e) {
                        print('❌ Error completing profile: $e');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تعذر حفظ المعلومات')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF112A54),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'متابعة',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: (value) =>
          (value == null || value.isEmpty) ? 'هذا الحقل مطلوب' : null,
      decoration: _inputDecoration(label),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF2F4F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF112A54), width: 1.4),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1940),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text('test');
  }
}