import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PrescriptionEditDeleteService {
  static const String _baseUrl = 'https://medremind.onrender.com/api';

  static Future<bool> deletePrescription(int id) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await Dio().delete(
        '$_baseUrl/prescription/$id/delete/',
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      print('[🗑️ DELETE Status]: ${response.statusCode}');
      print('[🧾 DELETE Body]: ${response.data}');

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ Delete Exception: $e');
      return false;
    }
  }

 static Future<bool> updatePrescription({
  required int prescriptionId,
  required int frequencyPerDay,
  required List<String> frequencyPerWeek,
  required String mealRelation,
  required String instructions,
}) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();
    if (idToken == null) throw Exception('User not authenticated');

    final dio = Dio();

    final formData = FormData.fromMap({
      'frequency_per_day': frequencyPerDay.toString(),
      'meal_relation': mealRelation,
      if (instructions.isNotEmpty) 'instructions': instructions,
    });

    // Append repeated frequency_per_week fields just like in submit
    for (final day in frequencyPerWeek) {
      formData.fields.add(MapEntry('frequency_per_week', day));
    }

    print('[📤 PATCH Updating Prescription]: $prescriptionId');
    print('[📦 PATCH Data]: ${formData.fields}');

    final response = await dio.patch(
      '$_baseUrl/prescription/$prescriptionId/edit/',
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'multipart/form-data',
        },
        validateStatus: (_) => true,
      ),
    );

    print('[PATCH 🔧 Status]: ${response.statusCode}');
    print('[📥 PATCH Response]: ${response.data}');

    if (response.statusCode == 200) return true;

    if (response.statusCode == 409) {
      print('⚠️ Prescription already exists (409 Conflict)');
    }

    return false;
  } catch (e) {
    print('❌ Exception in PATCH prescription: $e');
    return false;
  }
}


  static Future<bool> updateSchedules(int prescriptionId, List<Map<String, dynamic>> schedules) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken();
      if (token == null) throw Exception('User not authenticated');

      print('[📤 Updating Schedules]: $schedules');

      final response = await Dio().put(
        '$_baseUrl/prescription/$prescriptionId/update-schedules/',
        data: {'schedules': schedules},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          validateStatus: (_) => true,
        ),
      );

      print('[PUT 🕒 SCHEDULE Status]: ${response.statusCode}');
      print('[📥 PUT SCHEDULE Response]: ${response.data}');

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Update Schedules Exception: $e');
      return false;
    }
  }
}
