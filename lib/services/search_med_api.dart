import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class MedicineApi {
  static const String _baseUrl = 'https://medremind.onrender.com/api/simple-medicines/';

  static Future<List<Map<String, dynamic>>> search(String query) async {
    print('🔍 Starting search with query: "$query"');
    
    if (query.isEmpty) {
      print('⚠️ Query is empty, returning empty list');
      return [];
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();

      if (idToken == null) {
        print('❌ No token available, returning empty list');
        return [];
      }

      print('🌐 Making API call to: $_baseUrl');
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        print('📊 Total medicines received: ${data.length}');
        
        final allMedicines = List<Map<String, dynamic>>.from(data);
        
        // Filter by brand_name or dci (these are the correct field names!)
        final filteredResults = allMedicines.where((medicine) {
          final brand = medicine['brand_name']?.toString().toLowerCase() ?? '';
          final dci = medicine['dci']?.toString().toLowerCase() ?? '';
          final searchQuery = query.toLowerCase();
          
          final brandMatch = brand.contains(searchQuery);
          final dciMatch = dci.contains(searchQuery);
          
          // Debug matches
          if (brandMatch || dciMatch) {
            print('✅ Match found - Brand: "$brand", DCI: "$dci", Query: "$searchQuery"');
          }
          
          return brandMatch || dciMatch;
        }).toList();
        
        print('🎯 Filtered results count: ${filteredResults.length}');
        
        return filteredResults;
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