class AppointmentItem {
  final int apptId;
  final String title;
  final String status;
  final String patient;
  final String participants;
  final String provider;
  final String location;
  final String color;
  final String apptDate;
  final String apptFrom;
  final String apptTo;
  final String notes;

  AppointmentItem({
    required this.apptId,
    required this.title,
    required this.status,
    required this.patient,
    required this.participants,
    required this.provider,
    required this.location,
    required this.color,
    required this.apptDate,
    required this.apptFrom,
    required this.apptTo,
    required this.notes,
  });

  factory AppointmentItem.fromJson(Map<String, dynamic> json) {
    return AppointmentItem(
      apptId: json['appt_id'],
      title: json['title'],
      status: json['status'],
      participants: json['participants'],
      patient: json['patient'],
      provider: json['provider'],
      location: json['location'],
      color: json['color'],
      apptDate: json['appt_date'],
      apptFrom: json['appt_from'],
      apptTo: json['appt_to'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appt_id': apptId,
      'title': title,
      'status': status,
      'participants': participants,
      'patient': patient,
      'provider': provider,
      'location': location,
      'color': color,
      'appt_date': apptDate,
      'appt_from': apptFrom,
      'appt_to': apptTo,
      'notes': notes,
    };
  }
}
