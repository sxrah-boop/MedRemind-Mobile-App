import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class ScheduledNotificationsScreen extends StatefulWidget {
  const ScheduledNotificationsScreen({super.key});

  @override
  State<ScheduledNotificationsScreen> createState() =>
      _ScheduledNotificationsScreenState();
}

class _ScheduledNotificationsScreenState
    extends State<ScheduledNotificationsScreen>
    with TickerProviderStateMixin {
  List<NotificationModel> scheduledNotifications = [];
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Clean color palette
  static const Color primaryBlue = Color.fromARGB(255, 18, 47, 97);
  static const Color lightBlue = Color.fromARGB(255, 216, 229, 255);
  static const Color backgroundColor = Color(0xFFFBFCFD);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color successColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadScheduledNotifications();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadScheduledNotifications() async {
    setState(() => isLoading = true);

    try {
      final List<NotificationModel> notifications =
          await AwesomeNotifications().listScheduledNotifications();

      debugPrint('🔍 Total fetched notifications: ${notifications.length}');

      final Map<String, Map<String, dynamic>> groupedMap = {};

      for (final notif in notifications) {
        final payload = notif.content?.payload ?? {};
        final medicine = payload['medicineName'] ?? 'unknown';
        final time = payload['horaire'] ?? 'unknown';
        final day = payload['dayKey'] ?? '';

        final key = '$medicine-$time';
        debugPrint(
          '📦 Processing → medicine: "$medicine", time: "$time", day: "$day", key: "$key"',
        );

        if (!groupedMap.containsKey(key)) {
          debugPrint('➕ New group for key: $key');
          groupedMap[key] = {'model': notif, 'days': <String>{}};
        } else {
          debugPrint('🔁 Adding day "$day" to existing group "$key"');
        }

        (groupedMap[key]!['days'] as Set<String>).add(day);
      }

      setState(() {
        scheduledNotifications =
            groupedMap.values.map((entry) {
              final model = entry['model'] as NotificationModel;
              final days = (entry['days'] as Set<String>).join(', ');

              final Map<String, String> arabicDayMap = {
                'Mon': 'الاثنين',
                'Tue': 'الثلاثاء',
                'Wed': 'الأربعاء',
                'Thu': 'الخميس',
                'Fri': 'الجمعة',
                'Sat': 'السبت',
                'Sun': 'الأحد',
              };
              final arabicDays = (entry['days'] as Set<String>)
                  .map((d) => arabicDayMap[d] ?? d)
                  .join(', ');
              model.content?.payload?['daysList'] = arabicDays;

              debugPrint(
                '📅 Final daysList for "${model.content?.title}": $days',
              );
              return model;
            }).toList();
        isLoading = false;
      });

      debugPrint(
        '✅ Scheduled notifications ready. Total groups: ${scheduledNotifications.length}',
      );

      _animationController.forward();
    } catch (e) {
      debugPrint('❌ Error while loading scheduled notifications: $e');
      setState(() => isLoading = false);
      _showErrorSnackBar('خطأ في تحميل التذكيرات');
    }
  }

  Future<void> _cancelAll() async {
    final confirmed = await _showConfirmationDialog(
      'تأكيد الحذف',
      'هل أنت متأكد من حذف جميع التذكيرات؟',
    );

    if (confirmed) {
      try {
        await AwesomeNotifications().cancelAll();
        setState(() {
          scheduledNotifications.clear();
        });
        _showSuccessSnackBar('تم حذف جميع التذكيرات بنجاح');
      } catch (e) {
        _showErrorSnackBar('خطأ في حذف التذكيرات');
      }
    }
  }
Future<void> _toggleNotification(NotificationModel model, bool enabled) async {
  final payload = model.content?.payload ?? {};
  final targetMedicine = payload['medicineName'];
  final targetHoraire = payload['horaire'];

  try {
    if (enabled) {
      _showInfoSnackBar('سيتم تفعيل التذكير قريباً');
    } else {
      final allNotifications =
          await AwesomeNotifications().listScheduledNotifications();

      final toCancel = allNotifications.where((n) {
        final p = n.content?.payload ?? {};
        return p['medicineName'] == targetMedicine &&
            p['horaire'] == targetHoraire;
      }).toList();

      for (final n in toCancel) {
        await AwesomeNotifications().cancel(n.content!.id!);
      }

      await _loadScheduledNotifications();
     _showSuccessSnackBar('تم إلغاء التذكيرات لـ "$targetMedicine" في الساعة $targetHoraire');

    }
  } catch (e) {
    _showErrorSnackBar('خطأ في حذف المجموعة');
  }
}

  Future<bool> _showConfirmationDialog(String title, String content) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                  fontSize: 18,
                ),
                textAlign: TextAlign.right,
              ),
              content: Text(
                content,
                style: const TextStyle(color: textSecondary, fontSize: 14),
                textAlign: TextAlign.right,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  style: TextButton.styleFrom(
                    foregroundColor: textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('تأكيد'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
void _showSuccessSnackBar(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: successColor,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
    ),
  );
}


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontSize: 14)),
          ],
        ),
        backgroundColor: errorColor,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontSize: 14)),
          ],
        ),
        backgroundColor: primaryBlue,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'التذكيرات المجدولة',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              color: Colors.white,
            ),
          ),
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body:
            isLoading
                ? _buildLoadingState()
                : scheduledNotifications.isEmpty
                ? _buildEmptyState()
                : _buildNotificationsList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
            strokeWidth: 2,
          ),
          SizedBox(height: 16),
          Text(
            'جاري تحميل التذكيرات...',
            style: TextStyle(fontSize: 14, color: textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.notifications_off_outlined,
                  size: 40,
                  color: primaryBlue,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'لا توجد تذكيرات مجدولة',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'عندما تقوم بجدولة التذكيرات، ستظهر هنا',
                style: TextStyle(fontSize: 14, color: textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: _loadScheduledNotifications,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('إعادة تحميل'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryBlue,
                  side: const BorderSide(color: primaryBlue),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Header with cancel all button
          if (scheduledNotifications.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: errorColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'إدارة التذكيرات',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: textPrimary,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'يمكنك إلغاء جميع التذكيرات دفعة واحدة',
                          style: TextStyle(fontSize: 12, color: textSecondary),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _cancelAll,
                    icon: const Icon(Icons.delete_sweep, size: 16),
                    label: const Text('إلغاء الكل'),
                    style: TextButton.styleFrom(
                      foregroundColor: errorColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Notifications list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: scheduledNotifications.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(
                  scheduledNotifications[index],
                  index,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notif, int index) {
    final payload = notif.content?.payload ?? {};
    final medicineName = payload['medicineName'] ?? 'دواء غير معروف';
    final schedule = payload['horaire'] ?? 'غير محدد';
    final imageUrl = payload['image'];
    print('📆 Payload for ${payload['medicineName']}: ${payload['daysList']}');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Medicine image/icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: lightBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      (imageUrl?.startsWith('http') ?? false)
                          ? Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.medication,
                                  color: primaryBlue,
                                  size: 24,
                                ),
                          )
                          : const Icon(
                            Icons.medication,
                            color: primaryBlue,
                            size: 24,
                          ),
                ),
              ),
              const SizedBox(width: 16),

              // Medicine info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicineName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          schedule,
                          style: const TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if ((payload['daysList'] ?? '').toString().isNotEmpty)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              payload['daysList']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'مفعل',
                        style: TextStyle(
                          fontSize: 11,
                          color: successColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Toggle switch
              Switch(
                value: true,
                onChanged: (val) => _toggleNotification(notif, val),
                activeColor: primaryBlue,
                activeTrackColor: lightBlue,
                inactiveThumbColor: const Color(0xFF9CA3AF),
                inactiveTrackColor: const Color(0xFFE5E7EB),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
