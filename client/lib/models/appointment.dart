import 'package:flutter/material.dart' show TimeOfDay;

import 'appointment_status.dart';
import 'appointment_type.dart';
import 'location.dart';
import 'patient.dart';
import 'user.dart';

class Appointment {
  final int id;
  String title;
  bool isEvent;
  DateTime apptDate;
  TimeOfDay apptFrom;
  TimeOfDay apptTo;
  String notes;
  final int patientId;
  int providerId;
  int appointmentTypeId;
  int appointmentStatusId;
  int locationId;

  Patient? patient;
  User? provider;
  AppointmentType? appointmentType;
  AppointmentStatus? appointmentStatus;
  Location? location;

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
    this.patient,
    this.provider,
    this.appointmentType,
    this.appointmentStatus,
    this.location,
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
      patient:
          json['patient'] != null ? Patient.fromJson(json['patient']) : null,
      provider:
          json['provider'] != null ? User.fromJson(json['provider']) : null,
      appointmentType: json['appointment_type'] != null
          ? AppointmentType.fromJson(json['appointment_type'])
          : null,
      appointmentStatus: json['appointment_status'] != null
          ? AppointmentStatus.fromJson(json['appointment_status'])
          : null,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
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
