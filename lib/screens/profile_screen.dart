import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hopeless/services/profile_service_api.dart';

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                    return _infoTile(label: '⚠️ خطأ', value: 'تعذر تحميل معلومات الحساب');
                  }

                  final profile = snapshot.data!;
                  return Column(
                    children: [
                      _infoTile(label: 'الاسم', value: profile['full_name']),
                      _infoTile(label: 'تاريخ الميلاد', value: profile['birth_date']),
                      _infoTile(label: 'الجنس', value: profile['gender'] == 'female' ? 'أنثى' : 'ذكر'),
                      _infoTile(label: 'العنوان', value: profile['address']),
                      _infoTile(label: 'رقم التعريف في التطبيق', value: profile['public_id'], canCopy: true),
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
                    children: doctors.map((doc) {
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
              _helperCard(name: 'فاطمة أحمد', id: 'DZ123456789', phone: '0550 123 456'),
              _helperCard(name: 'يوسف علي', id: 'DZ987654321', phone: '0770 654 321'),

              const SizedBox(height: 24),
              _sectionTitle('الإعدادات'),
              _settingTile(icon: Icons.phone, label: 'تغيير رقم الهاتف'),
              _settingTile(icon: Icons.notifications, label: 'إعدادات التذكير'),
              _settingTile(icon: Icons.language, label: 'اللغة'),
              _settingTile(icon: Icons.help_outline, label: 'الدعم'),

              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {},
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

  Widget _infoTile({required String label, required String value, bool canCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: canCopy
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
                  Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (canCopy) const Icon(Icons.copy, size: 16, color: Colors.grey),
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

  Widget _doctorCard({required String name, required String address, required String doctorId}) {
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
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

  Widget _helperCard({required String name, required String id, required String phone}) {
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
          Text('👤 الاسم: $name', style: const TextStyle(fontWeight: FontWeight.w600)),
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
