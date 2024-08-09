import 'package:flutter/material.dart' show TimeOfDay;

class Appointment {
  final int id;
  final String title;
  final bool isEvent;
  final DateTime apptDate;
  final TimeOfDay apptFrom;
  final TimeOfDay apptTo;
  final String notes;
  final int patientId;
  final int providerId;
  final int appointmentTypeId;
  final int appointmentStatusId;
  final int locationId;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final int createdUserId;
  final int updatedUserId;

  Appointment({
    required this.id,
    required this.title,
    required this.isEvent,
    required this.apptDate,
    required this.apptFrom,
    required this.apptTo,
    required this.notes,
    required this.patientId,
    required this.providerId,
    required this.appointmentTypeId,
    required this.appointmentStatusId,
    required this.locationId,
    required this.dateCreated,
    required this.dateUpdated,
    required this.createdUserId,
    required this.updatedUserId,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      title: json['title'],
      isEvent: json['is_event'],
      apptDate: DateTime.parse(json['appt_date']),
      apptFrom: _parseTime(json['appt_from']),
      apptTo: _parseTime(json['appt_to']),
      notes: json['notes'],
      patientId: json['patient_id'],
      providerId: json['provider_id'],
      appointmentTypeId: json['appointment_type_id'],
      appointmentStatusId: json['appointment_status_id'],
      locationId: json['location_id'],
      dateCreated: DateTime.parse(json['date_created']),
      dateUpdated: DateTime.parse(json['date_updated']),
      createdUserId: json['created_user_id'],
      updatedUserId: json['updated_user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_event': isEvent,
      'appt_date': apptDate.toIso8601String().split('T')[0], // Only date part
      'appt_from': _formatTime(apptFrom),
      'appt_to': _formatTime(apptTo),
      'notes': notes,
      'patient_id': patientId,
      'provider_id': providerId,
      'appointment_type_id': appointmentTypeId,
      'appointment_status_id': appointmentStatusId,
      'location_id': locationId,
      'date_created': dateCreated.toIso8601String(),
      'date_updated': dateUpdated.toIso8601String(),
      'created_user_id': createdUserId,
      'updated_user_id': updatedUserId,
    };
  }

  // Helper function to parse time from string
  static TimeOfDay _parseTime(String timeString) {
    final time =
        TimeOfDay.fromDateTime(DateTime.parse('1970-01-01T$timeString'));
    return time;
  }

  // Helper function to format time to string
  static String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return dateTime.toIso8601String().split('T')[1].split('.')[0];
  }
}
