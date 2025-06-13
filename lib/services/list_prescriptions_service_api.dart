import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hopeless/models/prescription_model.dart';

// return prescriptions list
class PrescriptionService {
  
  static Future<List<Prescription>> fetchPrescriptions() async {
    final user = FirebaseAuth.instance.currentUser;
    final token = await user?.getIdToken();
print(token);
    if (token == null) throw Exception('User not authenticated');

    final response = await http.get(
      Uri.parse('https://medremind.onrender.com/api/prescriptions/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('[🔁 API Status]: ${response.statusCode}');
    print('[🧾 API Body]: ${response.body}');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) {
  try {
    final parsed = Prescription.fromJson(e);
    print('[📦 Prescription Parsed]: ${parsed.id} - ${parsed.medicineName}');
    return parsed;
  } catch (err) {
    print('[❌ Parsing Error]: $err\n[❗️Problematic Entry]: $e');
    rethrow;
  }
}).toList();

    } else {
      throw Exception('Failed to load prescriptions');
    }
  }

static Future<Prescription?> getPrescriptionById(int id) async {
  try {
    final prescriptions = await fetchPrescriptions();

    final match = prescriptions.where((p) => p.id == id).toList();
    return match.isNotEmpty ? match.first : null;

  } catch (e) {
    print('❌ Error in getPrescriptionById($id): $e');
    return null;
  }
}

  
}
