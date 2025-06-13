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
    // Clean up all YouTube controllers safely
    _disposeControllers();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // Pause all videos when app goes to background
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
          autoPlay: false, // This ensures video doesn't auto-play
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
      appBar: AppBar(
        backgroundColor: const Color(0xFF112A54),
        title: const Text(
          'Education Thérapeutique',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<EducationEntry>>(
        future: _educationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Chargement du contenu...",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          return _buildContentList(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              "Une erreur s'est produite",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _educationFuture = fetchEducationEntries();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Réessayer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              "Aucun contenu disponible",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Le contenu éducatif sera bientôt disponible.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
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
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
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
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Text(
                          entry.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey[900],
                            height: 1.3,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildMetadata(entry),
                    ],
                  ),
                ),
              ],
            ),
            // Content section
            Directionality(
              textDirection: TextDirection.rtl,
              child: HtmlWidget(
                entry.content,
                onTapUrl: (url) async {
                  print("Tapped: $url");
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(
                      Uri.parse(url),
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    print("Could not launch $url");
                  }
                  return true;
                },

                customWidgetBuilder: (element) {
                  if (element.localName == 'oembed') {
                    final videoUrl = element.attributes['url'] ?? '';
                    final videoId = YoutubePlayer.convertUrlToId(videoUrl);
                    if (videoId != null) {
                      return _buildYouTubePlayer(videoId);
                    }
                  }
                  return null;
                },
                textStyle: const TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadata(EducationEntry entry) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.person_outline, size: 14, color: Colors.blue[700]),
          const SizedBox(width: 4),
          Text(
            "Par Docteur:  ${entry.doctorName ?? "rien"}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.access_time, size: 14, color: Colors.blue[700]),
          const SizedBox(width: 4),
          Text(
            formatDate(entry.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouTubePlayer(String videoId) {
    if (_isDisposed) return const SizedBox.shrink();

    final controller = _getOrCreateController(videoId);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),

      // Make video larger
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: YoutubePlayerBuilder(
          onEnterFullScreen: () {
            // Handle fullscreen enter
          },
          onExitFullScreen: () {
            // Handle fullscreen exit
          },
          player: YoutubePlayer(
            controller: controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: Colors.red,
            progressColors: const ProgressBarColors(
              playedColor: Colors.red,
              handleColor: Colors.redAccent,
            ),
            aspectRatio: 16 / 9,
            onReady: () {
              // Video is ready
              print('Video $videoId is ready');
            },
            onEnded: (metaData) {
              // Video ended
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
      'jan',
      'fév',
      'mar',
      'avr',
      'mai',
      'jun',
      'jul',
      'aoû',
      'sep',
      'oct',
      'nov',
      'déc',
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
      title: json['title'] ?? 'Titre non disponible',
      content: json['content'] ?? '',
      createdAt:
          json['created_at'] != null
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
