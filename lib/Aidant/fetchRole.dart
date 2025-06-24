import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchUserRole(String token) async {
  final url = Uri.parse('https://medremind.onrender.com/api/user/role/');

  try {
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('✅ User role fetched: $data');
      return data;
    } else {
      print('❌ Failed to fetch user role: ${response.statusCode}');
      throw Exception('Failed to fetch user role');
    }
  } catch (e) {
    print('⚠️ Error fetching user role: $e');
    rethrow;
  }
}