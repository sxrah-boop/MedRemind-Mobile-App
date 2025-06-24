import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatbotService {
static const String _apiUrl = 'https://medchatbot-dmr8.onrender.com/chat';

  /// Sends a message and gets the chatbot's reply
  static Future<String?> sendMessage(String message, {String userId = "1"}) async {
    print('🔹 [ChatbotService] Preparing to send message...');
    print('📨 Message: "$message" | user_id: "$userId"');
    print('🌐 Endpoint: $_apiUrl');

    final body = jsonEncode({
      'user_id': userId,
      'message': message,
    });

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );

      print('📥 Status Code: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> data = json.decode(response.body);
          final reply = data['reply']?.toString();
          print('✅ Reply from chatbot: $reply');
          return reply;
        } catch (e) {
          print('❌ JSON parsing failed: $e');
          return null;
        }
      } else {
        print('❌ Server error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Exception during request: $e');
      return null;
    }
  }
}
