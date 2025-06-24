import 'package:flutter/material.dart';
import 'package:hopeless/services/alternatives_fetch_service.dart';
import 'package:hopeless/notification-reminders/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  final Map<String, String> payload;

  const NotificationScreen({super.key, required this.payload});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  Future<List<Map<String, dynamic>>> _alternativesFuture = Future.value([]);
  PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;

  // Clean color palette
  static const Color primaryBlue = Color(0xFF112A54);
  static const Color lightBlue = Color(0xFFC5D3EF);
  static const Color backgroundColor = Color(0xFFFBFCFD);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    final medicineIdStr = widget.payload['medicineId'];
    final medicineId = int.tryParse(medicineIdStr ?? '');
    _alternativesFuture =
        medicineId != null
            ? AlternativesService.fetchAlternatives(medicineId)
            : Future.value([]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  Future<void> _handleTakenButtonPress() async {
  try {
    final payload = widget.payload;
    final rawHoraireId = payload['horaireId'];
    final rawNotificationId = payload['notificationId'];
    final rawHoraire = payload['horaire'];

    debugPrint('🟢 "Taken" button pressed from screen');
    debugPrint('📦 Raw horaireId = $rawHoraireId');

    final horaireId = int.parse(rawHoraireId ?? '');
    
    // Check if already processed today
    if (NotificationService.isDoseProcessedToday(horaireId)) {
      debugPrint('⚠️ Dose already processed today, navigating to home');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ تم تأكيد هذه الجرعة مسبقاً اليوم'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
      return;
    }

    final notificationId = int.parse(rawNotificationId ?? '');
    final horaire = (rawHoraire ?? '').length == 5 
        ? '$rawHoraire:00' 
        : (rawHoraire ?? '');

    debugPrint('✅ Processing dose confirmation...');

    await NotificationService.handleDoseConfirmation(
      horaireId: horaireId,
      scheduledTimeStr: horaire,
      notificationId: notificationId,
    );

    // Mark as processed using the public method
    NotificationService.markDoseAsProcessed(horaireId);

    debugPrint('🎉 Dose confirmation completed. Navigating to /home');

    Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    
  } catch (e, s) {
    debugPrint('❌ Error in "Taken" button: $e');
    debugPrint('📍Stack trace:\n$s');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('⚠️ حدث خطأ أثناء تأكيد الجرعة'),
        backgroundColor: Colors.red,
      ),
    );
  }
}



  String _translateMeal(String? relation) {
    switch (relation) {
      case 'before_meal':
        return 'قبل الأكل';
      case 'with_meal':
        return 'مع الأكل';
      case 'after_meal':
        return 'بعد الأكل';
      case 'mid_meal':
        return 'منتصف الأكل';
      case 'empty_stomach':
        return 'على معدة فارغة';
      default:
        return 'بدون تحديد';
    }
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 223, 234, 255),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselIndicator(int itemCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        itemCount,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index ? primaryBlue : const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  String _getImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty || imageUrl == 'https://via.placeholder.com/64') {
      return 'assets/images/formentin.png'; // Default fallback image
    }
    return imageUrl;
  }

  Widget _buildCarouselItem(Map<String, dynamic> item, bool isMain) {
    final img = _getImageUrl(item['image']);
    final isAsset = img.startsWith('assets/');
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border:Border.all(color: lightBlue),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.blue.shade50.withOpacity(0.3),
          ],
        ),
    
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.shade50.withOpacity(0.1),
                    Colors.white,
                    Colors.blue.shade50.withOpacity(0.2),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Medicine image with soft container
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: isAsset
                            ? Image.asset(
                                img,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => _buildErrorWidget(),
                              )
                            : Image.network(
                                img,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/formentin.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                      ),
                    ),
                    
                    const SizedBox(height: 5),
                    
                    // Medicine name
                    Text(
                      item['brand_name'] ?? 'دواء غير معروف',
                      style: TextStyle(
                        color: primaryBlue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    if (item['dci'] != null && item['dci'].toString().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        item['dci'],
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // Badge for alternative/main medicine
          if (!isMain)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 193, 216, 255),
                  borderRadius: BorderRadius.circular(20),
                 
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.swap_horiz_rounded,  color: Color.fromARGB(255, 4, 21, 108), size: 14),
                    SizedBox(width: 4),
                    Text(
                      'بديل',
                      style: TextStyle(
                        color: Color.fromARGB(255, 4, 21, 108),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (isMain)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                color: const Color.fromARGB(255, 36, 72, 133),
                  borderRadius: BorderRadius.circular(20),
                  
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'الدواء الأساسي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100.withOpacity(0.5),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_rounded,
              size: 48,
              color: primaryBlue.withOpacity(0.7),
            ),
            const SizedBox(height: 8),
            Text(
              'صورة الدواء',
              style: TextStyle(
                color: primaryBlue.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final payload = widget.payload;
    final name = payload['medicineName'] ?? 'دواء غير معروف';
    final dose = payload['dose'] ?? '';
    final time = payload['horaire'] ?? '';
    final instructions = payload['instructions'] ?? '';
    final image = payload['image'] ?? '';
    final meal = _translateMeal(payload['mealRelation']);
    final horaireId = payload['horaireId'];
    print('testtt$horaireId');

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'تذكير الدواء',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 140),
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _alternativesFuture,
                builder: (context, snapshot) {
                  final List<Map<String, dynamic>> alternatives =
                      snapshot.data ?? [];

                  final allItems = [
                    {
                      'image': image,
                      'brand_name': name,
                      'dci': '',
                      'isMain': true,
                    },
                    ...alternatives
                        .where(
                          (alt) =>
                              alt['image'] != null &&
                              alt['image'].toString().isNotEmpty,
                        )
                        .map(
                          (alt) => {
                            'image': alt['image'],
                            'brand_name': alt['brand_name'],
                            'dci': alt['dci'],
                            'isMain': false,
                          },
                        ),
                  ];

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Enhanced Carousel
                        Container(
                          height: 280,
                          margin: const EdgeInsets.only(top: 20),
                          child: PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() {
                                _currentPage = index;
                              });
                            },
                            itemCount: allItems.length,
                            itemBuilder: (_, index) {
                              final item = allItems[index];
                              final isMain = item['isMain'] == true;
                              return _buildCarouselItem(item, isMain);
                            },
                          ),
                        ),

                        // Carousel Indicator
                        if (allItems.length > 1) ...[
                          const SizedBox(height: 20),
                          _buildCarouselIndicator(allItems.length),
                        ],

                        const SizedBox(height: 32),

                        // Medicine Information
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 20),

                              if (dose.isNotEmpty)
                                _infoTile(
                                  Icons.medication,
                                  'الجرعة',
                                  dose == '1' ? 'حبة واحدة' : '$dose حبات',
                                ),
                              if (time.isNotEmpty)
                                _infoTile(
                                  Icons.schedule,
                                  'الوقت',
                                  time.length >= 5 ? time.substring(0, 5) : time,
                                ),
                              _infoTile(Icons.restaurant, 'علاقة بالوجبة', meal),
                              if (instructions.isNotEmpty)
                                _infoTile(
                                  Icons.info_outline,
                                  'ملاحظات إضافية',
                                  instructions,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Fixed Bottom Buttons
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  border: Border(
                    top: BorderSide(color: const Color(0xFFE5E7EB), width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    ElevatedButton(
  onPressed: _handleTakenButtonPress,
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 25, 49, 100),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
  ),
  child: const Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.check_circle_outline, size: 20),
      SizedBox(width: 8),
      Text(
        'تم أخذ الدواء',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    ],
  ),
),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () async {
                        await NotificationService.scheduleRemindLaterNotification(
                          payload,
                        );
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (_) => false,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: textSecondary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: textSecondary,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.schedule, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'ذكرني لاحقًا (10 دقائق)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
