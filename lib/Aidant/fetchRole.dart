// import 'dart:convert';
// import 'package:http/http.dart' as http;

// Future<Map<String, dynamic>> fetchUserRole(String token) async {
//   final url = Uri.parse('https://medremind.onrender.com/api/user/role/');

//   try {
//     final response = await http.get(
//       url,
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     );

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       print('✅ User role fetched: $data');
//       return data;
//     } else {
//       print('❌ Failed to fetch user role: ${response.statusCode}');
//       throw Exception('Failed to fetch user role');
//     }
//   } catch (e) {
//     print('⚠️ Error fetching user role: $e');
//     rethrow;
//   }
// }


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, dynamic>?> fetchUserRole([String? token]) async {
  final url = Uri.parse('https://medremind.onrender.com/api/user/role/');
  
  String? authToken = token;
  
  // If no token provided, try to get fresh token from Firebase
  if (authToken == null) {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        authToken = await currentUser.getIdToken(true); // Force refresh
      } catch (e) {
        print('❌ Failed to get fresh token: $e');
        return null;
      }
    } else {
      print('❌ No authenticated user found');
      return null;
    }
  }

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ User role fetched: $data');
      
      // Update stored token based on role
      await _updateStoredToken(authToken!, data['role']);
      
      return data;
    } else if (response.statusCode == 401) {
      print('🔄 Token expired, attempting refresh...');
      
      // Try to refresh token
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          final freshToken = await currentUser.getIdToken(true);
          return await fetchUserRole(freshToken); // Recursive call with fresh token
        } catch (e) {
          print('❌ Failed to refresh token: $e');
          await _clearAllTokens();
          return null;
        }
      } else {
        print('❌ No authenticated user for token refresh');
        await _clearAllTokens();
        return null;
      }
    } else {
      print('❌ Failed to fetch user role: ${response.statusCode}');
      throw Exception('Failed to fetch user role');
    }
  } catch (e) {
    print('⚠️ Error fetching user role: $e');
    return null;
  }
}

Future<void> _updateStoredToken(String token, String role) async {
  final prefs = await SharedPreferences.getInstance();
  
  if (role == 'patient') {
    await prefs.setString('patient_token', token);
    await prefs.remove('caregiver_token');
  } else if (role == 'aidant') {
    await prefs.setString('caregiver_token', token);
    await prefs.remove('patient_token');
  }
}

Future<void> _clearAllTokens() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('patient_token');
  await prefs.remove('caregiver_token');
}