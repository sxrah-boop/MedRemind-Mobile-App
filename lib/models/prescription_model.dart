class Schedule {
  final int? id; // ✅ Make id nullable
  final String horaire;
  final int posologie;

  const Schedule({
    this.id, // ✅ Nullable in constructor
    required this.horaire,
    required this.posologie,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        id: json['id'] != null ? json['id'] as int : null, // ✅ Safe parsing
        horaire: json['horaire'] ?? '', // ✅ Default to empty string if missing
        posologie: json['posologie'] ?? 0, // ✅ Default to 0 if missing
      );
}

class Prescription {
  final int id;
  final List<String> frequencyPerWeek;
  final List<Schedule> schedules;
  final String mealRelation;
  final int frequencyPerDay;
  final String status;
  final int medicineId;
  final String medicineName;
  final String medicineDci;
  final String medicineDosage;
  final String medicineType;
  final Uri medicineImage;
  final String instructions;
  final String? doctor; // ✅ Optional

  const Prescription({
    required this.id,
    required this.frequencyPerWeek,
    required this.schedules,
    required this.mealRelation,
    required this.frequencyPerDay,
    required this.status,
    required this.medicineId,
    required this.medicineName,
    required this.medicineDosage,
    required this.medicineDci,
    required this.medicineType,
    required this.medicineImage,
    required this.instructions,
    this.doctor, 

  });

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
        id: json['id'] as int,
        frequencyPerWeek: List<String>.from(json['frequency_per_week'] ?? []), // ✅ Safe default to empty list
        schedules: (json['schedules'] as List? ?? []) // ✅ Null-safe schedules
            .map((s) => Schedule.fromJson(s))
            .toList(),
        mealRelation: json['meal_relation'] ?? '', // ✅ Fallback
        frequencyPerDay: json['frequency_per_day'] ?? 0, // ✅ Fallback
        status: json['status'] ?? 'active', // ✅ Fallback
        medicineId: int.tryParse(json['medicine_id'].toString()) ?? -1,
        medicineName: json['medicine_brand'] ?? 'اسم غير متوفر', // ✅ Fallback
        medicineDci: json['medicine_dci'] ?? 'اسم غير متوفر', // ✅ Fallback
        medicineType: json['medicine_type'] ?? '', // ✅ Fallback
        medicineImage: json['image'] != null
    ? Uri.parse(json['image'])
    : Uri(), // Keep empty Uri if no image
        instructions: json['instructions'] ?? '', // ✅ Fallback
        doctor: json['doctor']?.toString(), 
        medicineDosage:json['medicine_dosage'], 
      );
}
