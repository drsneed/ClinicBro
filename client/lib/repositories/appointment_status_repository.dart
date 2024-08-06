import 'dart:convert';
import '../models/appointment_status.dart'; // Import your AppointmentStatus model
import '../services/data_service.dart';

class AppointmentStatusRepository {
  static final AppointmentStatusRepository _instance =
      AppointmentStatusRepository._internal();
  factory AppointmentStatusRepository() => _instance;
  AppointmentStatusRepository._internal();

  Future<AppointmentStatus?> createAppointmentStatus(
      AppointmentStatus appointmentStatus) async {
    final response = await DataService().post(
      '/appointment_statuses',
      body: jsonEncode(appointmentStatus.toJson()),
    );

    if (response.statusCode == 201) {
      return AppointmentStatus.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<AppointmentStatus?> getAppointmentStatus(int id) async {
    final response = await DataService().get('/appointment_statuses/$id');
    if (response.statusCode == 200) {
      return AppointmentStatus.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<AppointmentStatus?> updateAppointmentStatus(
      AppointmentStatus appointmentStatus) async {
    final response = await DataService().put(
      '/appointment_statuses/${appointmentStatus.id}',
      body: jsonEncode(appointmentStatus.toJson()),
    );

    if (response.statusCode == 200) {
      return AppointmentStatus.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<bool> deleteAppointmentStatus(int id) async {
    final response = await DataService().delete('/appointment_statuses/$id');
    return response.statusCode == 204;
  }

  Future<List<AppointmentStatus>> getAllAppointmentStatuses() async {
    final response = await DataService().get('/appointment_statuses');
    if (response.statusCode == 200) {
      List<dynamic> appointmentStatusesJson = jsonDecode(response.body);
      return appointmentStatusesJson
          .map((json) => AppointmentStatus.fromJson(json))
          .toList();
    } else {
      // Handle errors or throw exceptions
      return [];
    }
  }
}
