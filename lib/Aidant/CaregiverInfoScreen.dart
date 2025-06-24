import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hopeless/Aidant/CaregiverHome.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CaregiverInfoScreen extends StatefulWidget {
  const CaregiverInfoScreen({Key? key}) : super(key: key);

  @override
  State<CaregiverInfoScreen> createState() => _CaregiverInfoScreenState();
}

class _CaregiverInfoScreenState extends State<CaregiverInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _patientIdController = TextEditingController();

  
  // List to store multiple patient IDs
  List<String> _patientIds = [];
  bool _loading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _patientIdController.dispose();
    super.dispose();
  }

  void _addPatientId() {
    final patientId = _patientIdController.text.trim();
    if (patientId.isNotEmpty && !_patientIds.contains(patientId)) {
      setState(() {
        _patientIds.add(patientId);
        _patientIdController.clear();
      });
    }
  }

  void _removePatientId(String patientId) {
    setState(() {
      _patientIds.remove(patientId);
    });
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_patientIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إضافة معرف مريض واحد على الأقل')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      final phoneNumber = user?.phoneNumber;
    

      if (phoneNumber == null || idToken == null) {
        throw Exception("بيانات المصادقة غير مكتملة");
      }

      final fullName = _fullNameController.text.trim();

      print('[📤] Sending complete profile data to backend...');

      final response = await http.post(
        Uri.parse('https://medremind.onrender.com/api/aidant/complete-profile/'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone_number': phoneNumber,
          'full_name': fullName,
          'patients': _patientIds,
        }),
      );

      print('[🌐] Complete Profile Response: ${response.statusCode}');
      print('[📝] Response Body: ${response.body}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to complete caregiver profile');
      }

      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context,MaterialPageRoute(builder: (_) => const CaregiverHomeScreen()),
  );
    } catch (e) {
      debugPrint('[❌ Error]: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء التسجيل: ${e.toString()}')),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 238, 244, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(
                'معلومات مرافق المريض',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF112A54),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'يرجى إدخال معلوماتك لمتابعة الخدمة',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 16,
                  color: const Color(0xFF112A54),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildFormCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _fullNameController,
                label: 'الاسم الكامل لمقدم الرعاية',
                icon: Icons.person,
                validator: (value) => value!.isEmpty ? 'يرجى إدخال الاسم الكامل' : null,
              ),
              const SizedBox(height: 20),
              _buildPatientIdSection(),
              const SizedBox(height: 20),
              _buildPatientsList(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF112A54),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'متابعة',
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientIdSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _patientIdController,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  labelText: 'معرف المريض (Public Key)',
                  prefixIcon: const Icon(Icons.badge, color: Color(0xFF112A54)),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onFieldSubmitted: (_) => _addPatientId(),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _addPatientId,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF112A54),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'يمكنك إضافة أكثر من معرف مريض',
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPatientsList() {
    if (_patientIds.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'لم يتم إضافة أي معرف مريض بعد',
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المرضى المضافون (${_patientIds.length})',
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF112A54),
          ),
        ),
        const SizedBox(height: 12),
        ..._patientIds.map((patientId) => Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              const Icon(Icons.person, color: Color(0xFF112A54), size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  patientId,
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _removePatientId(patientId),
                icon: const Icon(Icons.close, color: Colors.red, size: 20),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF112A54)),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator,
    );
  }

}