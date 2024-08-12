import 'appointment.dart';
import 'location.dart';
import 'appointment_type.dart';
import 'appointment_status.dart';
import 'user.dart';

class EditAppointmentData {
  final Appointment appointment;
  final List<Location> locations;
  final List<AppointmentType> appointmentTypes;
  final List<AppointmentStatus> appointmentStatuses;
  final List<User> providers;

  EditAppointmentData({
    required this.appointment,
    required this.locations,
    required this.appointmentTypes,
    required this.appointmentStatuses,
    required this.providers,
  });

  factory EditAppointmentData.fromJson(Map<String, dynamic> json) {
    return EditAppointmentData(
      appointment: Appointment.fromJson(json['appointment']),
      locations: (json['locations'] as List<dynamic>)
          .map((loc) => Location.fromJson(loc))
          .toList(),
      appointmentTypes: (json['appointment_types'] as List<dynamic>)
          .map((at) => AppointmentType.fromJson(at))
          .toList(),
      appointmentStatuses: (json['appointment_statuses'] as List<dynamic>)
          .map((as) => AppointmentStatus.fromJson(as))
          .toList(),
      providers: (json['providers'] as List<dynamic>)
          .map((prov) => User.fromJson(prov))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appointment': appointment.toJson(),
      'locations': locations.map((loc) => loc.toJson()).toList(),
      'appointment_types': appointmentTypes.map((at) => at.toJson()).toList(),
      'appointment_statuses':
          appointmentStatuses.map((as) => as.toJson()).toList(),
      'providers': providers.map((prov) => prov.toJson()).toList(),
    };
  }
}
