import 'dart:convert';
import '../models/appointment.dart'; // Import your Appointment model
import '../services/data_service.dart';

class AppointmentRepository {
  static final AppointmentRepository _instance =
      AppointmentRepository._internal();
  factory AppointmentRepository() => _instance;
  AppointmentRepository._internal();

  Future<Appointment?> createAppointment(Appointment appointment) async {
    final response = await DataService().post(
      '/appointments',
      body: jsonEncode(appointment.toJson()),
    );

    if (response.statusCode == 201) {
      return Appointment.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<Appointment?> getAppointment(int id) async {
    final response = await DataService().get('/appointments/$id');
    if (response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<Appointment?> updateAppointment(Appointment appointment) async {
    final response = await DataService().put(
      '/appointments/${appointment.id}',
      body: jsonEncode(appointment.toJson()),
    );

    if (response.statusCode == 200) {
      return Appointment.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<bool> deleteAppointment(int id) async {
    final response = await DataService().delete('/appointments/$id');
    return response.statusCode == 204;
  }

  Future<List<Appointment>> getAllAppointments() async {
    final response = await DataService().get('/appointments');
    if (response.statusCode == 200) {
      List<dynamic> appointmentsJson = jsonDecode(response.body);
      return appointmentsJson
          .map((json) => Appointment.fromJson(json))
          .toList();
    } else {
      // Handle errors or throw exceptions
      return [];
    }
  }

  Future<List<Appointment>> getAppointmentsInRange(
      DateTime startDate, DateTime endDate) async {
    final response = await DataService().get(
      '/appointment-items',
      queryParams: {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> appointmentsJson = jsonDecode(response.body);
      return appointmentsJson
          .map((json) => Appointment.fromJson(json))
          .toList();
    } else {
      // Handle errors or throw exceptions
      return [];
    }
  }
}
