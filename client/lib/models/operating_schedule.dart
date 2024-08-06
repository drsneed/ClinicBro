import 'package:flutter/material.dart' show TimeOfDay;

class OperatingSchedule {
  final int locationId;
  final int? userId;
  final TimeOfDay hoursSunFrom;
  final TimeOfDay hoursSunTo;
  final TimeOfDay hoursMonFrom;
  final TimeOfDay hoursMonTo;
  final TimeOfDay hoursTueFrom;
  final TimeOfDay hoursTueTo;
  final TimeOfDay hoursWedFrom;
  final TimeOfDay hoursWedTo;
  final TimeOfDay hoursThuFrom;
  final TimeOfDay hoursThuTo;
  final TimeOfDay hoursFriFrom;
  final TimeOfDay hoursFriTo;
  final TimeOfDay hoursSatFrom;
  final TimeOfDay hoursSatTo;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final int? createdUserId;
  final int? updatedUserId;

  OperatingSchedule({
    required this.locationId,
    this.userId,
    required this.hoursSunFrom,
    required this.hoursSunTo,
    required this.hoursMonFrom,
    required this.hoursMonTo,
    required this.hoursTueFrom,
    required this.hoursTueTo,
    required this.hoursWedFrom,
    required this.hoursWedTo,
    required this.hoursThuFrom,
    required this.hoursThuTo,
    required this.hoursFriFrom,
    required this.hoursFriTo,
    required this.hoursSatFrom,
    required this.hoursSatTo,
    required this.dateCreated,
    required this.dateUpdated,
    this.createdUserId,
    this.updatedUserId,
  });

  factory OperatingSchedule.fromJson(Map<String, dynamic> json) {
    return OperatingSchedule(
      locationId: json['location_id'],
      userId: json['user_id'],
      hoursSunFrom: _parseTime(json['hours_sun_from']),
      hoursSunTo: _parseTime(json['hours_sun_to']),
      hoursMonFrom: _parseTime(json['hours_mon_from']),
      hoursMonTo: _parseTime(json['hours_mon_to']),
      hoursTueFrom: _parseTime(json['hours_tue_from']),
      hoursTueTo: _parseTime(json['hours_tue_to']),
      hoursWedFrom: _parseTime(json['hours_wed_from']),
      hoursWedTo: _parseTime(json['hours_wed_to']),
      hoursThuFrom: _parseTime(json['hours_thu_from']),
      hoursThuTo: _parseTime(json['hours_thu_to']),
      hoursFriFrom: _parseTime(json['hours_fri_from']),
      hoursFriTo: _parseTime(json['hours_fri_to']),
      hoursSatFrom: _parseTime(json['hours_sat_from']),
      hoursSatTo: _parseTime(json['hours_sat_to']),
      dateCreated: DateTime.parse(json['date_created']),
      dateUpdated: DateTime.parse(json['date_updated']),
      createdUserId: json['created_user_id'],
      updatedUserId: json['updated_user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'user_id': userId,
      'hours_sun_from': _formatTime(hoursSunFrom),
      'hours_sun_to': _formatTime(hoursSunTo),
      'hours_mon_from': _formatTime(hoursMonFrom),
      'hours_mon_to': _formatTime(hoursMonTo),
      'hours_tue_from': _formatTime(hoursTueFrom),
      'hours_tue_to': _formatTime(hoursTueTo),
      'hours_wed_from': _formatTime(hoursWedFrom),
      'hours_wed_to': _formatTime(hoursWedTo),
      'hours_thu_from': _formatTime(hoursThuFrom),
      'hours_thu_to': _formatTime(hoursThuTo),
      'hours_fri_from': _formatTime(hoursFriFrom),
      'hours_fri_to': _formatTime(hoursFriTo),
      'hours_sat_from': _formatTime(hoursSatFrom),
      'hours_sat_to': _formatTime(hoursSatTo),
      'date_created': dateCreated.toIso8601String(),
      'date_updated': dateUpdated.toIso8601String(),
      'created_user_id': createdUserId,
      'updated_user_id': updatedUserId,
    };
  }

  // Helper function to parse time from string
  static TimeOfDay _parseTime(String timeString) {
    final time =
        TimeOfDay.fromDateTime(DateTime.parse('1970-01-01 $timeString'));
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
