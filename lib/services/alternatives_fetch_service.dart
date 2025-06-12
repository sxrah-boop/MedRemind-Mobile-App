import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AlternativesService {
  static const String baseUrl = 'https://medremind.onrender.com/api/medicines/';

  static Future<List<Map<String, dynamic>>> fetchAlternatives(int medicineId) async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();

    if (token == null) {
      throw Exception('User not authenticated');
    }

    final url = Uri.parse('$baseUrl$medicineId/alternatives/');
    print('🌐 Fetching alternatives from: $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token', // ⬅️ Automatic token
        'Accept': 'application/json',
      },
    );

    print('🔄 Response Status Code: ${response.statusCode}');

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      print('🧾 Response Body (First 1): ${data.isNotEmpty ? data[0] : 'No data'}');
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      print('❌ Failed to fetch alternatives: ${response.statusCode}');
      throw Exception('Failed to load alternatives');
    }
  }
}
