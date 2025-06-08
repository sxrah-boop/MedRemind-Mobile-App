// import 'package:dio/dio.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class SchedulingService {
//   static const String _baseUrl = 'https://medremind.onrender.com/api';

//   static Future<bool> submitSchedule({
//     required int prescriptionId,
//     required List<Map<String, dynamic>> scheduleEntries,
//   }) async {
//     try {
//       final user = FirebaseAuth.instance.currentUser;
//       final idToken = await user?.getIdToken();
//       if (idToken == null) throw Exception('User not authenticated');

//       final dio = Dio();

//       // 👇 Body only contains "schedules": [ {horaire, posologie}, ... ]
//       final payload = {
//         "schedules": scheduleEntries,
//       };

//       final url = '$_baseUrl/prescription/$prescriptionId/add-schedules/';

//       final response = await dio.post(
//         url,
//         data: payload,
//         options: Options(
//           headers: {
//             'Authorization': 'Bearer $idToken',
//             'Content-Type': 'application/json',
//           },
//         ),
//       );

//       print('📡 POST $url');
//       print('📦 Sent payload: $payload');
//       print('✅ Response: ${response.statusCode}');
//       print('📨 Body: ${response.data}');

//       return response.statusCode == 201;
//     } catch (e, stackTrace) {
//       print('❌ Schedule submission failed: $e');
//       print('📉 Stack trace: $stackTrace');
//       return false;
//     }
//   }
// }
