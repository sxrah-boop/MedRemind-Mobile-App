import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hopeless/services/profile_service_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileFuture;
  late Future<List<Map<String, dynamic>>> _doctorsFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService.fetchProfileInfo();
    _doctorsFuture = ProfileService.fetchLinkedDoctors();
  }

  void _showCopiedSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFEAF2FC), Color(0xFFF9FAFB)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
          child: ListView(
            children: [
              Text(
                'الملف الشخصي',
                style: theme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 24),

              _sectionTitle('معلوماتي'),
              FutureBuilder<Map<String, dynamic>>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return _infoTile(
                      label: '⚠️ خطأ',
                      value: 'تعذر تحميل معلومات الحساب',
                    );
                  }

                  final profile = snapshot.data!;
                  return Column(
                    children: [
                      _infoTile(label: 'الاسم', value: profile['full_name']),
                      _infoTile(
                        label: 'تاريخ الميلاد',
                        value: profile['birth_date'],
                      ),
                      _infoTile(
                        label: 'الجنس',
                        value: profile['gender'] == 'female' ? 'أنثى' : 'ذكر',
                      ),
                      _infoTile(label: 'العنوان', value: profile['address']),
                      _infoTile(
                        label: 'رقم التعريف في التطبيق',
                        value: profile['public_id'],
                        canCopy: true,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),
              _sectionTitle('طبيبي'),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _doctorsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Text('⚠️ تعذر تحميل معلومات الطبيب');
                  }

                  final doctors = snapshot.data!;
                  if (doctors.isEmpty) return const Text('لا يوجد طبيب مرتبط');

                  return Column(
                    children:
                        doctors.map((doc) {
                          return _doctorCard(
                            name: doc['full_name'],
                            address: doc['address'] ?? 'غير محدد',
                            doctorId: doc['id'].toString(),
                          );
                        }).toList(),
                  );
                },
              ),

              const SizedBox(height: 24),
              _sectionTitle('المرافقون'),
              _helperCard(
                name: 'فاطمة أحمد',
                id: 'DZ123456789',
                phone: '0550 123 456',
              ),
              _helperCard(
                name: 'يوسف علي',
                id: 'DZ987654321',
                phone: '0770 654 321',
              ),

              const SizedBox(height: 24),
              _sectionTitle('الإعدادات'),
              _settingTile(icon: Icons.phone, label: 'تغيير رقم الهاتف'),
              _settingTile(icon: Icons.notifications, label: 'إعدادات التذكير'),
              _settingTile(icon: Icons.language, label: 'اللغة'),
              _settingTile(icon: Icons.help_outline, label: 'الدعم'),

              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (_) => AlertDialog(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  backgroundColor: Colors.white,
  elevation: 8,
  shadowColor: Colors.black.withOpacity(0.15),
  contentPadding: const EdgeInsets.all(24),
  titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
  actionsPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
  
  title: Row(
    textDirection: TextDirection.rtl,
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.logout_rounded,
          color: Colors.red.shade600,
          size: 24,
        ),
      ),
      const SizedBox(width: 12),
      const Expanded(
        child: Text(
          'تأكيد تسجيل الخروج',
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
            height: 1.2,
          ),
        ),
      ),
    ],
  ),
  
  content: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 8),
      const Text(
        'هل أنت متأكد أنك تريد تسجيل الخروج من التطبيق؟',
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF4A4A4A),
          height: 1.5,
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.amber.shade200,
            width: 1,
          ),
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber.shade700,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'سيتم أيضًا إلغاء جميع التذكيرات المجدولة الخاصة بك.',
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B5B00),
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
  
  actions: [
    Row(
      textDirection: TextDirection.rtl,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              backgroundColor: Colors.grey.shade50,
            ),
            child: const Text(
              'إلغاء',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              shadowColor: Colors.red.withOpacity(0.3),
            ),
            child: const Text(
              ' تسجيل الخروج',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    ),
  ],
)
                  );

                  if (confirmed == true) {
                    try {
                      // 🔕 Cancel all medication reminders
                      await AwesomeNotifications().cancelAll();

                      // 🔐 Firebase sign out
                      await FirebaseAuth.instance.signOut();

                      // 🧹 Clear local storage
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();

                      // 🚪 Navigate to login screen
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/UserTypeSelectionScreen',
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('❌ حدث خطأ أثناء تسجيل الخروج'),
                            backgroundColor: Colors.red.shade600,
                          ),
                        );
                      }
                    }
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('تسجيل الخروج'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
          color: Color(0xFF112A54),
        ),
      ),
    );
  }

  Widget _infoTile({
    required String label,
    required String value,
    bool canCopy = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap:
            canCopy
                ? () {
                  Clipboard.setData(ClipboardData(text: value));
                  _showCopiedSnackBar('تم نسخ المعرف');
                }
                : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey)),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (canCopy)
                    const Icon(Icons.copy, size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingTile({required IconData icon, required String label}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF112A54)),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }

  Widget _doctorCard({
    required String name,
    required String address,
    required String doctorId,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC5D3EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(address, style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: doctorId));
              _showCopiedSnackBar('تم نسخ معرف الطبيب');
            },
            child: Row(
              children: [
                const Icon(Icons.copy, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('معرف الطبيب: $doctorId'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _helperCard({
    required String name,
    required String id,
    required String phone,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC5D3EF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👤 الاسم: $name',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text('📞 الهاتف: $phone'),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: id));
              _showCopiedSnackBar('تم نسخ المعرف');
            },
            child: Row(
              children: [
                const Icon(Icons.copy, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text('المعرف في التطبيق: $id'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
