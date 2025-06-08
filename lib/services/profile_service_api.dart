// lib/services/profile_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ProfileService {
  static Future<Map<String, dynamic>> fetchProfileInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();

    if (token == null) throw Exception('User not authenticated');

    final response = await http.get(
      Uri.parse('https://medremind.onrender.com/api/patient/profile-info/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('[🩺 Profile Status]: ${response.statusCode}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch profile data');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchLinkedDoctors() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();

    if (token == null) throw Exception('User not authenticated');

    final response = await http.get(
      Uri.parse('https://medremind.onrender.com/api/patient/linked-doctors/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('[🩺 Doctors Status]: ${response.statusCode}');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch doctors');
    }
  }
}
