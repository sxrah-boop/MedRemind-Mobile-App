import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [
    {
      'isBot': true,
      'text':
          'يُفضّل تناول الميتفورمين مع الطعام لتقليل الآثار الجانبية مثل الغثيان. الجرعات المحددة لك هي وجبة واحدة عند الساعة 11:12 صباحًا ووجبة واحدة عند الساعة 23:12 مساءً.\n\nمن المهم اتباع هذه الجدولة بدقة. إذا واجهت أي أعراض جانبية مثل الغثيان الشديد أو التعب، يجب عليك استشارة الطبيب على الفور.',
    },
    {'isBot': false, 'text': 'واشمن دوا نشرب على 7:30 نسيت'},
    {
      'isBot': true,
      'text':
          'الدواء الذي تتناوله على الساعة 07:30 صباحًا هو جليكلازيد (Gliclazide).',
    },
  ];

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        messages.add({'isBot': false, 'text': text});
      });
      _controller.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Background color
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end, // <-- Right align
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.end, // <-- Right align text
              children: [
                Text(
                  'chatbot - المساعد الطبي الذكي',
                  style: GoogleFonts.ibmPlexSansArabic(
                    textStyle: const TextStyle(
                      color: Color(0xFF1F1F1F),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'موجود دائما',
                  style: GoogleFonts.ibmPlexSansArabic(
                    textStyle: const TextStyle(
                      color: Colors.green,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Image.asset(
              'assets/images/chatbot.png', // Your local bot icon
              width: 50,
              height: 50,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Align(
                  alignment: message['isBot']
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: message['isBot']
                          ? const Color(0xFFEDF6FE) // Light blue
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      message['text'],
                      textAlign: TextAlign.right,
                      style: GoogleFonts.ibmPlexSansArabic(
                        textStyle: const TextStyle(
                          color: Color(0xFF1F1F1F),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'هذا المساعد الذكي في فترة تجريبية ولا يعطي نصائح طبية تعوض الطبيب.\nبعض الإجابات تحتمل الخطأ.',
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSansArabic(
                textStyle: const TextStyle(
                  color: Color(0xFF8A8A8A),
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.white,
            child: Row(
              children: [
                InkWell(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 29, 60, 93),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textAlign: TextAlign.right,
                    style: GoogleFonts.ibmPlexSansArabic(),
                    decoration: InputDecoration(
                      hintText: 'تفضل، واش حاب تعرف اليوم؟',
                      hintStyle: GoogleFonts.ibmPlexSansArabic(
                        textStyle: const TextStyle(color: Color(0xFF8A8A8A)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
