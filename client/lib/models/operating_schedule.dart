import 'package:flutter/material.dart' show TimeOfDay;

class OperatingSchedule {
  final int locationId;
  final int? userId;
  final TimeOfDay? hoursSunFrom;
  final TimeOfDay? hoursSunTo;
  final TimeOfDay? hoursMonFrom;
  final TimeOfDay? hoursMonTo;
  final TimeOfDay? hoursTueFrom;
  final TimeOfDay? hoursTueTo;
  final TimeOfDay? hoursWedFrom;
  final TimeOfDay? hoursWedTo;
  final TimeOfDay? hoursThuFrom;
  final TimeOfDay? hoursThuTo;
  final TimeOfDay? hoursFriFrom;
  final TimeOfDay? hoursFriTo;
  final TimeOfDay? hoursSatFrom;
  final TimeOfDay? hoursSatTo;
  final DateTime? dateCreated;
  final DateTime? dateUpdated;
  final int? createdUserId;
  final int? updatedUserId;

  OperatingSchedule({
    required this.locationId,
    this.userId,
    this.hoursSunFrom,
    this.hoursSunTo,
    this.hoursMonFrom,
    this.hoursMonTo,
    this.hoursTueFrom,
    this.hoursTueTo,
    this.hoursWedFrom,
    this.hoursWedTo,
    this.hoursThuFrom,
    this.hoursThuTo,
    this.hoursFriFrom,
    this.hoursFriTo,
    this.hoursSatFrom,
    this.hoursSatTo,
    this.dateCreated,
    this.dateUpdated,
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
      dateCreated: json['date_created'] != null
          ? DateTime.parse(json['date_created'])
          : null,
      dateUpdated: json['date_updated'] != null
          ? DateTime.parse(json['date_updated'])
          : null,
      createdUserId: json['created_user_id'],
      updatedUserId: json['updated_user_id'],
    );
  }

  // Method to print the JSON output
  void printJson() {
    final json = toJson();
    print(json);
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
      'created_user_id': createdUserId,
      'updated_user_id': updatedUserId,
    };
  }

  // Helper function to parse time from string
  static TimeOfDay? _parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    final time =
        TimeOfDay.fromDateTime(DateTime.parse('1970-01-01T$timeString'));
    return time;
  }

  // Helper function to format time to string
  static String? _formatTime(TimeOfDay? time) {
    if (time == null) return null;
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return dateTime.toIso8601String().split('T')[1].split('.')[0];
  }

  // Add copyWith method
  OperatingSchedule copyWith({
    int? locationId,
    int? userId,
    TimeOfDay? hoursSunFrom,
    TimeOfDay? hoursSunTo,
    TimeOfDay? hoursMonFrom,
    TimeOfDay? hoursMonTo,
    TimeOfDay? hoursTueFrom,
    TimeOfDay? hoursTueTo,
    TimeOfDay? hoursWedFrom,
    TimeOfDay? hoursWedTo,
    TimeOfDay? hoursThuFrom,
    TimeOfDay? hoursThuTo,
    TimeOfDay? hoursFriFrom,
    TimeOfDay? hoursFriTo,
    TimeOfDay? hoursSatFrom,
    TimeOfDay? hoursSatTo,
    DateTime? dateCreated,
    DateTime? dateUpdated,
    int? createdUserId,
    int? updatedUserId,
  }) {
    return OperatingSchedule(
      locationId: locationId ?? this.locationId,
      userId: userId ?? this.userId,
      hoursSunFrom: hoursSunFrom ?? this.hoursSunFrom,
      hoursSunTo: hoursSunTo ?? this.hoursSunTo,
      hoursMonFrom: hoursMonFrom ?? this.hoursMonFrom,
      hoursMonTo: hoursMonTo ?? this.hoursMonTo,
      hoursTueFrom: hoursTueFrom ?? this.hoursTueFrom,
      hoursTueTo: hoursTueTo ?? this.hoursTueTo,
      hoursWedFrom: hoursWedFrom ?? this.hoursWedFrom,
      hoursWedTo: hoursWedTo ?? this.hoursWedTo,
      hoursThuFrom: hoursThuFrom ?? this.hoursThuFrom,
      hoursThuTo: hoursThuTo ?? this.hoursThuTo,
      hoursFriFrom: hoursFriFrom ?? this.hoursFriFrom,
      hoursFriTo: hoursFriTo ?? this.hoursFriTo,
      hoursSatFrom: hoursSatFrom ?? this.hoursSatFrom,
      hoursSatTo: hoursSatTo ?? this.hoursSatTo,
      dateCreated: dateCreated ?? this.dateCreated,
      dateUpdated: dateUpdated ?? this.dateUpdated,
      createdUserId: createdUserId ?? this.createdUserId,
      updatedUserId: updatedUserId ?? this.updatedUserId,
    );
  }
}
