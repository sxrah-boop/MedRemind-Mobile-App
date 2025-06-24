import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class EducationPage extends StatefulWidget {
  @override
  _EducationPageState createState() => _EducationPageState();
}

class _EducationPageState extends State<EducationPage>
    with WidgetsBindingObserver {
  late Future<List<EducationEntry>> _educationFuture;
  final Map<String, YoutubePlayerController> _controllers = {};
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _educationFuture = fetchEducationEntries();
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _disposeControllers();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _controllers.values.forEach((controller) {
        if (controller.value.isPlaying) {
          controller.pause();
        }
      });
    }
  }

  void _disposeControllers() {
    try {
      for (final controller in _controllers.values) {
        if (!_isDisposed) {
          controller.dispose();
        }
      }
      _controllers.clear();
    } catch (e) {
      print('Error disposing controllers: $e');
    }
  }

  Future<List<EducationEntry>> fetchEducationEntries() async {
    try {
      final url = Uri.parse('https://medremind.onrender.com/api/education/');
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();

      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => EducationEntry.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed');
      } else {
        throw Exception(
          'Failed to load educational content: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching education entries: $e');
      rethrow;
    }
  }

  YoutubePlayerController _getOrCreateController(String videoId) {
    if (_isDisposed) return YoutubePlayerController(initialVideoId: videoId);

    if (!_controllers.containsKey(videoId)) {
      _controllers[videoId] = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          showLiveFullscreenButton: false,
          controlsVisibleAtStart: true,
          enableCaption: true,
          forceHD: false,
          hideControls: false,
        ),
      );
    }
    return _controllers[videoId]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'التعليم العلاجي',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        
      ),
      body: FutureBuilder<List<EducationEntry>>(
        future: _educationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyStateWithMedicalInstructions();
          }

          return _buildContentList(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
            ),
          ),
          SizedBox(height: 24),
          Text(
            "جاري تحميل المحتوى...",
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 32,
                color: Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "حدث خطأ في تحميل المحتوى",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "يرجى المحاولة مرة أخرى",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _educationFuture = fetchEducationEntries();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text("إعادة المحاولة"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateWithMedicalInstructions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header section
          Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.medical_information_outlined,
                      size: 40,
                      color: Color(0xFF0EA5E9),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "الإرشادات الطبية",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "معلومات مهمة حول الالتزام العلاجي",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // General Medical Instructions
          _buildInstructionCard(
            title: "الإرشادات العامة للعلاج",
            icon: Icons.health_and_safety_outlined,
            color: const Color(0xFF10B981),
            instructions: [
              "تناول الأدوية في الأوقات المحددة بانتظام",
              "لا تتوقف عن تناول الدواء دون استشارة الطبيب",
              "احفظ الأدوية في مكان آمن وبعيداً عن متناول الأطفال",
              "تابع مع طبيبك بانتظام حسب المواعيد المحددة",
              "أبلغ طبيبك عن أي آثار جانبية تشعر بها",
              "اتبع تعليمات الطبيب بدقة ولا تغير الجرعات بنفسك",
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Diabetes Specific Instructions
          _buildInstructionCard(
            title: "إرشادات خاصة بمرضى السكري",
            icon: Icons.favorite_outline,
            color: const Color(0xFFE11D48),
            instructions: [
              "قم بفحص مستوى السكر في الدم بانتظام",
              "تناول وجبات منتظمة وتجنب تخطي الوجبات",
              "مارس الرياضة بانتظام حسب توصيات طبيبك",
              "احمل معك دائماً سكاكر أو عصير في حالة انخفاض السكر",
              "افحص قدميك يومياً وحافظ على نظافتهما",
              "تناول كمية كافية من الماء واتبع نظاماً غذائياً صحياً",
              "احرص على أخذ لقاح الإنفلونزا سنوياً",
              "تجنب التدخين والكحول",
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Emergency Instructions
          _buildInstructionCard(
            title: "في حالات الطوارئ",
            icon: Icons.warning_amber_outlined,
            color: const Color(0xFFF59E0B),
            instructions: [
              "اتصل بطبيبك فوراً في حالة الشعور بأعراض غير طبيعية",
              "احتفظ بأرقام الطوارئ في مكان واضح",
              "أخبر أفراد عائلتك عن حالتك الصحية وأدويتك",
              "احمل بطاقة طبية تحتوي على معلومات حالتك",
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Refresh button
          Container(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _educationFuture = fetchEducationEntries();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text("تحديث المحتوى"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> instructions,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...instructions.map((instruction) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 8, left: 12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Expanded(
                  child: Text(
                    instruction,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }

  Widget _buildContentList(List<EducationEntry> entries) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {
          _educationFuture = fetchEducationEntries();
        });
      },
      color: const Color(0xFF3B82F6),
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: entries.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _buildEducationCard(entries[index]);
        },
      ),
    );
  }

  Widget _buildEducationCard(EducationEntry entry) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                entry.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  height: 1.4,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Metadata
            _buildCleanMetadata(entry),
            
            const SizedBox(height: 20),
            
            // Content
            Directionality(
              textDirection: TextDirection.rtl,
              child: HtmlWidget(
                entry.content,
                onTapUrl: (url) async {
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                  return true;
                },
                customWidgetBuilder: (element) {
                  if (element.localName == 'oembed') {
                    final videoUrl = element.attributes['url'] ?? '';
                    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
                    if (videoId != null) {
                      return _buildCleanYouTubePlayer(videoId);
                    }
                  }
                  return null;
                },
                textStyle: const TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: Color(0xFF475569),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCleanMetadata(EducationEntry entry) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.person_outline,
                size: 14,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                "د. ${entry.doctorName ?? "غير محدد"}",
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                formatDate(entry.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCleanYouTubePlayer(String videoId) {
    if (_isDisposed) return const SizedBox.shrink();

    final controller = _getOrCreateController(videoId);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: YoutubePlayerBuilder(
          onEnterFullScreen: () {},
          onExitFullScreen: () {},
          player: YoutubePlayer(
            controller: controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: const Color(0xFF3B82F6),
            progressColors: const ProgressBarColors(
              playedColor: Color(0xFF3B82F6),
              handleColor: Color(0xFF1E40AF),
            ),
            aspectRatio: 16 / 9,
            onReady: () {
              print('Video $videoId is ready');
            },
            onEnded: (metaData) {
              print('Video $videoId ended');
            },
          ),
          builder: (context, player) => player,
        ),
      ),
    );
  }

  String formatDate(DateTime dateTime) {
    final months = [
      '',
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];

    return "${dateTime.day} ${months[dateTime.month]} ${dateTime.year}";
  }
}

class EducationEntry {
  final int id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? doctorName;

  EducationEntry({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.doctorName,
  });

  factory EducationEntry.fromJson(Map<String, dynamic> json) {
    return EducationEntry(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'عنوان غير متوفر',
      content: json['content'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      doctorName: json['doctor_name'],
    );
  }

  @override
  String toString() {
    return 'EducationEntry{id: $id, title: $title, doctorName: $doctorName}';
  }
}