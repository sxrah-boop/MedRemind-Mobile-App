import 'dart:convert';
import 'package:hopeless/screens/Auth/PhoneLoginScreen.dart';
import 'package:http/http.dart' as http;
import 'package:hopeless/services/auth_storage.dart';

class AuthService {
  // Verifies Firebase ID token with the backend and saves UID
  static Future<String?> verifyWithBackend(String idToken) async {
    print('[🔐] Sending Firebase ID Token to backend...');

    final response = await http.post(
      Uri.parse('https://medremind.onrender.com/api/auth/firebase/verify/'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );

    print('[🌐] Backend Response Status: ${response.statusCode}');
    print('[📝] Backend Response Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final uid = data['uid'];
      print('[✅] UID received from backend: $uid');

      await AuthStorage.saveUid(uid);
      print('[💾] UID saved locally');
      return uid;
    } else {
      print('[❌] Server error: ${response.statusCode}');
      throw Exception("Server Error: ${response.statusCode}");
    }
  }

  // Checks whether the user has completed their profile using Firebase ID token
static Future<bool> checkUserStatusWithIdToken(String token, {required UserType userType}) async {
  final url = userType == UserType.patient
      ? 'https://medremind.onrender.com/api/patient/profile-status/'
      : 'https://medremind.onrender.com/api/aidant/profile-status/';

  final response = await http.get(
    Uri.parse(url),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['has_profile'] == true;
  } else {
    throw Exception("Failed to check profile status");
  }
}

  // Completes the user profile
  static Future<void> completeUserProfile({
    required String fullname,
    required String birthDate,
    required String gender,
    required String address,
    required String idToken,
    required String phoneNumber,
  }) async {
    print('[📤] Sending complete profile data to backend...');

    final response = await http.post(
      Uri.parse('https://medremind.onrender.com/api/patient/complete-profile/'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phone_number': phoneNumber,
        'full_name': fullname,
        'birth_date': birthDate,
        'gender': gender,
        'address': address,
      }),
    );

    print('[🌐] Complete Profile Response: ${response.statusCode}');
    print('[📝] Response Body: ${response.body}');

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to complete user profile');
    }
  }
}
