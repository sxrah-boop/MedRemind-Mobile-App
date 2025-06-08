import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class MedicineApi {
  static const String _baseUrl = 'https://medremind.onrender.com/api/simple-medicines/';

  static Future<List<Map<String, dynamic>>> search(String query) async {
    if (query.isEmpty) return [];

    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      if (idToken == null) return [];

      final response = await http.get(
        Uri.parse('$_baseUrl?search=$query'),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data);
      } else {
        print('❌ API error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Exception during fetch: $e');
      return [];
    }
  }
}
