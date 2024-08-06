import 'dart:convert';
import '../models/appointment_type.dart'; // Import your AppointmentType model
import '../services/data_service.dart';

class AppointmentTypeRepository {
  static final AppointmentTypeRepository _instance =
      AppointmentTypeRepository._internal();
  factory AppointmentTypeRepository() => _instance;
  AppointmentTypeRepository._internal();

  Future<AppointmentType?> createAppointmentType(
      AppointmentType appointmentType) async {
    final response = await DataService().post(
      '/appointment_types',
      body: jsonEncode(appointmentType.toJson()),
    );

    if (response.statusCode == 201) {
      return AppointmentType.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<AppointmentType?> getAppointmentType(int id) async {
    final response = await DataService().get('/appointment_types/$id');
    if (response.statusCode == 200) {
      return AppointmentType.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<AppointmentType?> updateAppointmentType(
      AppointmentType appointmentType) async {
    final response = await DataService().put(
      '/appointment_types/${appointmentType.id}',
      body: jsonEncode(appointmentType.toJson()),
    );

    if (response.statusCode == 200) {
      return AppointmentType.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<bool> deleteAppointmentType(int id) async {
    final response = await DataService().delete('/appointment_types/$id');
    return response.statusCode == 204;
  }

  Future<List<AppointmentType>> getAllAppointmentTypes() async {
    final response = await DataService().get('/appointment_types');
    if (response.statusCode == 200) {
      List<dynamic> appointmentTypesJson = jsonDecode(response.body);
      return appointmentTypesJson
          .map((json) => AppointmentType.fromJson(json))
          .toList();
    } else {
      // Handle errors or throw exceptions
      return [];
    }
  }
}
