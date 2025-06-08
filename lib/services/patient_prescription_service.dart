// File: patient_prescription_service.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';


class PrescriptionResult {
  final bool success;
  final bool conflict;
  final int? prescriptionId;
  final Map<String, dynamic>? existingPrescription;

  PrescriptionResult({
    required this.success,
    this.conflict = false,
    this.prescriptionId,
    this.existingPrescription,
  });
}

class PrescriptionService {
  static const String _baseUrl = 'https://medremind.onrender.com/api';

  static Future<PrescriptionResult> submitPrescription({
    required int medicineId,
    required String startDate,
    required String endDate,
    required int frequencyPerDay,
    required List<String> frequencyPerWeek,
    required String mealRelation,
    required String instructions,
    File? imageFile,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      if (idToken == null) throw Exception('User not authenticated');

      final dio = Dio();
      final formData = FormData();

      formData.fields.addAll([
        MapEntry('medicine_id', medicineId.toString()),
        MapEntry('start_date', startDate),
        MapEntry('end_date', endDate),
        MapEntry('frequency_per_day', frequencyPerDay.toString()),
        MapEntry('meal_relation', mealRelation),
        if (instructions.isNotEmpty) MapEntry('instructions', instructions),
      ]);

      for (final day in frequencyPerWeek) {
        formData.fields.add(MapEntry('frequency_per_week', day));
      }

      if (imageFile != null) {
        final fileName = imageFile.path.split('/').last;
        formData.files.add(
          MapEntry(
            'personal_medicine_image',
            await MultipartFile.fromFile(imageFile.path, filename: fileName),
          ),
        );
      }

      final response = await dio.post(
        '$_baseUrl/prescription/submit/',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $idToken',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        final data = response.data;
        final presId = data['prescription']?['id'];
        return PrescriptionResult(success: true, prescriptionId: presId);
      } else if (response.statusCode == 409) {
        return PrescriptionResult(
          success: false,
          conflict: true,
          existingPrescription: response.data['existing_prescription'],
        );
      } else {
        return PrescriptionResult(success: false);
      }
    } catch (e) {
      print('❌ Prescription submission failed: $e');
      return PrescriptionResult(success: false);
    }
  }

  static Future<String?> fetchMedicineImageUrl(int id) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final idToken = await user?.getIdToken();
      if (idToken == null) return null;

      final dio = Dio();
      final response = await dio.get(
        '$_baseUrl/medicine-image/$id/',
        options: Options(headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        return response.data['image_url'];
      } else {
        return null;
      }
    } catch (e) {
      print('❌ Error fetching medicine image: $e');
      return null;
    }
  }
static Future<Response> submitScheduleWithResponse({
    required int prescriptionId,
    required List<Map<String, dynamic>> scheduleEntries,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    final idToken = await user?.getIdToken();
    if (idToken == null) throw Exception('User not authenticated');

    final dio = Dio();
    final response = await dio.post(
      '$_baseUrl/prescription/$prescriptionId/add-schedules/',
      data: {'schedules': scheduleEntries},
      options: Options(
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        validateStatus: (_) => true,
      ),
    );

    print('📨 Schedule response: ${response.statusCode}');
    print('📄 Body: ${response.data}');

    return response;
  }

  static Future<bool> submitSchedule({
    required int prescriptionId,
    required List<Map<String, dynamic>> scheduleEntries,
  }) async {
    try {
      final response = await submitScheduleWithResponse(
        prescriptionId: prescriptionId,
        scheduleEntries: scheduleEntries,
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('❌ Schedule submission failed: $e');
      return false;
    }
 
  }




}
