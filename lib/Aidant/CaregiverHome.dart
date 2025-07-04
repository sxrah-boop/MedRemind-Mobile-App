import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hopeless/screens/Auth/user_type_selection_screen.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CaregiverHomeScreen extends StatefulWidget {
  const CaregiverHomeScreen({Key? key}) : super(key: key);

  @override
  State<CaregiverHomeScreen> createState() => _CaregiverHomeScreenState();
}

class _CaregiverHomeScreenState extends State<CaregiverHomeScreen> {
  bool showDailyOnly = true;
  Map<String, dynamic>? patientInfo;
  List<Map<String, dynamic>> history = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('caregiver_token');

      if (token == null) throw Exception('No caregiver token found');

      final response = await http.get(
        Uri.parse('https://medremind.onrender.com/api/aidant/first-patient-intake/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          patientInfo = data['patient'];
          history = List<Map<String, dynamic>>.from(data['historique']);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  List<Map<String, dynamic>> get filteredHistory {
    if (showDailyOnly) {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      return history.where((item) {
        final date = item['horaire_prise_actuel']?.substring(0, 10);
        return date == today;
      }).toList();
    }
    return history;
  }

  String _formatAge(String birthDate) {
    try {
      final birth = DateTime.parse(birthDate);
      final now = DateTime.now();
      final age = now.year - birth.year;
      if (now.month < birth.month || (now.month == birth.month && now.day < birth.day)) {
        return '${age - 1} سنة';
      }
      return '$age سنة';
    } catch (e) {
      return 'غير محدد';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFEDF6FE),
        appBar: AppBar(
          backgroundColor: const Color(0xFF112A54),
          elevation: 0,
          title: Text('متابعة المريض',
              style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, size: 30, color: Color(0xFF112A54)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        patientInfo != null ? 'الاسم: ${patientInfo!['full_name']}' : 'الاسم: مساعد طبي',
                        style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF112A54)),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: Text('تسجيل الخروج', style: GoogleFonts.ibmPlexSansArabic(fontSize: 14)),
                  onTap: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('caregiver_token');
                    await prefs.remove('patient_token');
                    FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const UserTypeSelectionScreen()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : patientInfo == null
                ? const Center(child: Text('لا توجد بيانات مريض حالياً'))
                : Column(
                    children: [
                      // Enhanced Patient Info Card
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF112A54),
                                        const Color(0xFF112A54).withOpacity(0.7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                  child: Icon(
                                    patientInfo!['gender'] == 'female' ? Icons.woman : Icons.man,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        patientInfo!['full_name'],
                                        style: GoogleFonts.ibmPlexSansArabic(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF112A54),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatAge(patientInfo!['birth_date']),
                                        style: GoogleFonts.ibmPlexSansArabic(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDF6FE),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF112A54).withOpacity(0.1)),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.phone, color: Colors.grey[600], size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'رقم الهاتف: ${patientInfo!['phone_number']}',
                                        style: GoogleFonts.ibmPlexSansArabic(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.location_on, color: Colors.grey[600], size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'العنوان: ${patientInfo!['address']}',
                                        style: GoogleFonts.ibmPlexSansArabic(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.cake, color: Colors.grey[600], size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'تاريخ الميلاد: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(patientInfo!['birth_date']))}',
                                        style: GoogleFonts.ibmPlexSansArabic(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'تاريخ الجرعات',
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF112A54),
                              ),
                            ),
                            FilterChip(
                              label: Text(
                                showDailyOnly ? 'اليوم فقط' : 'جميع السجلات',
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 12,
                                  color: showDailyOnly ? Colors.white : const Color(0xFF112A54),
                                ),
                              ),
                              selected: showDailyOnly,
                              onSelected: (bool selected) {
                                setState(() {
                                  showDailyOnly = !showDailyOnly;
                                });
                              },
                              backgroundColor: Colors.white,
                              selectedColor: const Color(0xFF112A54),
                              side: const BorderSide(color: Color(0xFF112A54)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filteredHistory.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.medication_outlined,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      showDailyOnly ? 'لا توجد جرعات لليوم' : 'لا توجد سجلات جرعات',
                                      style: GoogleFonts.ibmPlexSansArabic(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 20),
                                itemCount: filteredHistory.length,
                                itemBuilder: (context, index) {
                                  final item = filteredHistory[index];
                                  final medicine = item['medicine'];
                                  return PrescriptionHistoryCard(
                                    medicineName: medicine['dci'] ?? 'دواء غير محدد',
                                    brandName: medicine['brand_name'] ?? '',
                                    dosage: medicine['dosage'] ?? '',
                                    medicineType: medicine['medicine_type'] ?? '',
                                    imageUrl: medicine['image'] ?? '',
                                    posologie: item['posologie'] ?? 1,
                                    scheduledDate: item['horaire_prise_actuel']?.substring(0, 10) ?? '',
                                    scheduledTime: item['horaire'] ?? '',
                                    actualTime: item['horaire_prise_actuel']?.substring(11, 16) ?? '',
                                    status: item['statut'] ?? 'unknown',
                                    confirmedAt: item['horaire_prise_actuel'] ?? '',
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class PrescriptionHistoryCard extends StatelessWidget {
  final String medicineName;
  final String brandName;
  final String dosage;
  final String medicineType;
  final String imageUrl;
  final int posologie;
  final String scheduledTime;
  final String scheduledDate;
  final String actualTime;
  final String status;
  final String confirmedAt;

  const PrescriptionHistoryCard({
    Key? key,
    required this.medicineName,
    required this.brandName,
    required this.dosage,
    required this.medicineType,
    required this.imageUrl,
    required this.posologie,
    required this.scheduledTime,
    required this.scheduledDate,
    required this.actualTime,
    required this.status,
    required this.confirmedAt,
  }) : super(key: key);

  Color _statusColor(String status) {
    switch (status) {
      case 'taken':
        return Colors.green;
      case 'late':
        return Colors.orange;
      case 'missed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'taken':
        return 'تم تناولها';
      case 'late':
        return 'متأخرة';
      case 'missed':
        return 'فائتة';
      default:
        return 'غير معروف';
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'taken':
        return Icons.check_circle;
      case 'late':
        return Icons.access_time;
      case 'missed':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Medicine Image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 64,
                              height: 64,
                              color: const Color(0xFF112A54).withOpacity(0.1),
                              child: const Icon(
                                Icons.medication,
                                color: Color(0xFF112A54),
                                size: 32,
                              ),
                            );
                          },
                        )
                      : Container(
                          width: 64,
                          height: 64,
                          color: const Color(0xFF112A54).withOpacity(0.1),
                          child: const Icon(
                            Icons.medication,
                            color: Color(0xFF112A54),
                            size: 32,
                          ),
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicineName,
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF112A54),
                        ),
                      ),
                      if (brandName.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            brandName,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (dosage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            dosage,
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(status).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _statusColor(status).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _statusIcon(status),
                        size: 16,
                        color: _statusColor(status),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _statusText(status),
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12,
                          color: _statusColor(status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.medication_liquid, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'الجرعة: ${posologie == 1 ? 'حبة واحدة' : '$posologie حبات'}',
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              'موعد مقرر: $scheduledTime',
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy').format(DateTime.parse(scheduledDate)),
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (status == 'taken' && actualTime.isNotEmpty)
                          Row(
                            children: [
                              Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
                              const SizedBox(width: 4),
                              Text(
                                'تم في: $actualTime',
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 13,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}