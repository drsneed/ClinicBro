class PatientItem {
  final int id;
  final bool active;
  final String firstName;
  final String fullName;
  final DateTime? dateOfBirth;
  PatientItem({
    required this.id,
    required this.active,
    required this.firstName,
    required this.fullName,
    this.dateOfBirth,
  });

  factory PatientItem.fromJson(Map<String, dynamic> json) {
    return PatientItem(
      id: json['id'],
      active: json['active'],
      firstName: json['first_name'],
      fullName: json['full_name'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
    );
  }

  String initials() {
    return firstName[0] + fullName[0];
  }
}
