class Schedule {
  final int id; // ✅ Add this
  final String horaire;
  final int posologie;

  const Schedule({
    required this.id, // ✅ Include in constructor
    required this.horaire,
    required this.posologie,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        id: json['id'], // ✅ Parse ID
        horaire: json['horaire'],
        posologie: json['posologie'],
      );
}

class Prescription {
  final int id;
  final List<String> frequencyPerWeek;
  final List<Schedule> schedules;
  final String mealRelation;
  final int frequencyPerDay;
  final String status;
  final String medicineName;
  final String medicineType;
  final String medicineImage;
  final String instructions;
  final String? doctor; // ✅ Optional

  const Prescription({
    required this.id,
    required this.frequencyPerWeek,
    required this.schedules,
    required this.mealRelation,
    required this.frequencyPerDay,
    required this.status,
    required this.medicineName,
    required this.medicineType,
    required this.medicineImage,
    required this.instructions,
    this.doctor, // ✅ Optional
  });

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
        id: json['id'],
        frequencyPerWeek: List<String>.from(json['frequency_per_week']),
        schedules: (json['schedules'] as List)
            .map((s) => Schedule.fromJson(s))
            .toList(),
        mealRelation: json['meal_relation'] ?? '',
        frequencyPerDay: json['frequency_per_day'],
        status: json['status'] ?? 'active',
        medicineName: json['medicine_name'] ?? 'اسم غير متوفر',
        medicineType: json['medicine_type'] ?? '',
        medicineImage: json['medicine_image'] ?? 'https://via.placeholder.com/64',
        instructions: json['instructions'] ?? '',
        doctor: json['doctor']?.toString(),
 // ✅ may be null
      );
}
