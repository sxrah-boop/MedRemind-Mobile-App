class HistoryEntry {
  final int id;
  final int prescriptionId;
  final int horaireId;
  final String medicineName;
  final String fullName;
  final String imageUrl;
  final int posologie;
  final String horaireTime;
  final String status;
  final String confirmedAt;

  HistoryEntry({
    required this.id,
    required this.prescriptionId,
    required this.horaireId,
    required this.medicineName,
    required this.fullName,
    required this.imageUrl,
    required this.posologie,
    required this.horaireTime,
    required this.status,
    required this.confirmedAt,
  });

  factory HistoryEntry.fromJson(Map<String, dynamic> json) {
    return HistoryEntry(
      id: json['id'],
      prescriptionId: json['prescription_id'],
      horaireId: json['horaire_id'],
      medicineName: json['medicine_name'] ?? '',
      fullName: json['medicine_full_name'] ?? '',
      imageUrl: json['medicine_image'] ?? '',
      posologie: json['posologie'] ?? 1,
      horaireTime: json['horaire_time'] ?? '',
      status: json['statut'] ?? '',
      confirmedAt: json['confirmed_at'] ?? '',
    );
  }
}
