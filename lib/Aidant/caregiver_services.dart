import 'dart:convert';
import 'package:http/http.dart' as http;

class CaregiverService {
  static const String baseUrl = 'https://medremind.onrender.com'; // Replace with your actual API base URL
  
  /// Check if caregiver has completed their profile
  /// Returns true if profile is complete, false if needs completion
  
  static Future<bool> checkCaregiverProfileStatus(String firebaseIdToken) async {
    try {
      print('[CaregiverService] Checking profile status...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/api/aidant/profile-status/'),
        headers: {
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
      );
      
      print('[CaregiverService] Response status: ${response.statusCode}');
      print('[CaregiverService] Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Assuming your API returns something like {"has_profile": true/false}
        // Adjust the key based on your actual API response structure
        return data['has_profile'] ?? false;
      } else if (response.statusCode == 404) {
        // User doesn't exist in caregiver system yet
        return false;
      } else {
        throw Exception('Failed to check profile status: ${response.statusCode}');
      }
    } catch (e) {
      print('[CaregiverService] Error: $e');
      throw Exception('Network error while checking profile status: $e');
    }
  }
  
  /// Verify caregiver with backend (similar to patient verification)
  /// You might need this if you have a separate caregiver verification endpoint
  static Future<String> verifyCaregiverWithBackend(String firebaseIdToken) async {
    try {
      print('[CaregiverService] Verifying caregiver with backend...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/api/aidant/verify/'), // Adjust endpoint as needed
        headers: {
          'Authorization': 'Bearer $firebaseIdToken',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'firebase_token': firebaseIdToken,
        }),
      );
      
      print('[CaregiverService] Verify response status: ${response.statusCode}');
      print('[CaregiverService] Verify response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['uid'] ?? data['user_id'] ?? 'unknown';
      } else {
        throw Exception('Failed to verify caregiver: ${response.statusCode}');
      }
    } catch (e) {
      print('[CaregiverService] Verify error: $e');
      throw Exception('Network error while verifying caregiver: $e');
    }
  }
}