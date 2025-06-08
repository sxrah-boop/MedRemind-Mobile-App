import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hopeless/models/history_model.dart';
import 'package:http/http.dart' as http;

class HistoryService {
  static Future<List<HistoryEntry>> fetchHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await http.get(
      Uri.parse('https://medremind.onrender.com/api/prise/history/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('[📥 History API Status]: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('Failed to load history');
    }

    final List data = jsonDecode(response.body);
    return data.map((json) => HistoryEntry.fromJson(json)).toList();
  }
}
