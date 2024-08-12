import 'dart:convert';
import '../models/appointment.dart';
import '../models/appointment_item.dart';
import '../models/event_participant.dart';
import '../models/create_appointment_data.dart';
import '../models/edit_appointment_data.dart';
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

  Future<List<Appointment>> getAllAppointments({
    int? patientId,
    int? providerId,
    int? locationId,
    int? appointmentTypeId,
    int? appointmentStatusId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final queryParams = <String, String>{};

    if (patientId != null) {
      queryParams['patient_id'] = patientId.toString();
    }
    if (providerId != null) {
      queryParams['provider_id'] = providerId.toString();
    }
    if (locationId != null) {
      queryParams['location_id'] = locationId.toString();
    }
    if (appointmentTypeId != null) {
      queryParams['appointment_type_id'] = appointmentTypeId.toString();
    }
    if (appointmentStatusId != null) {
      queryParams['appointment_status_id'] = appointmentStatusId.toString();
    }
    if (fromDate != null) {
      queryParams['from_date'] = fromDate.toIso8601String();
    }
    if (toDate != null) {
      queryParams['to_date'] = toDate.toIso8601String();
    }

    final response = await DataService().get(
      '/appointments',
      queryParams: queryParams,
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

  Future<List<AppointmentItem>> getAppointmentItemsInRange(
      DateTime startDate, DateTime endDate) async {
    final response = await DataService().get(
      '/appointment-items',
      queryParams: {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
    );

    if (response.statusCode == 200) {
      var appointmentsJson = jsonDecode(response.body);

      // Ensure appointmentDatesJson is not null and is a list before processing it.
      if (appointmentsJson != null && appointmentsJson is List) {
        return appointmentsJson
            .map((json) => AppointmentItem.fromJson(json))
            .toList();
      }
    }
    return [];
  }

  Future<List<DateTime>> getAppointmentDatesInRange(
      DateTime startDate, DateTime endDate) async {
    final response = await DataService().get(
      '/appointment-dates',
      queryParams: {
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
    );
    if (response.statusCode == 200) {
      var appointmentDatesJson = jsonDecode(response.body);

      // Ensure appointmentDatesJson is not null and is a list before processing it.
      if (appointmentDatesJson != null && appointmentDatesJson is List) {
        return appointmentDatesJson
            .map((json) => DateTime.parse(json))
            .toList();
      }
    }

    return [];
  }

  Future<List<EventParticipant>> getEventParticipants(int appointmentId) async {
    final response = await DataService().get(
      '/event-participants',
      queryParams: {
        'appointment_id': appointmentId.toString(),
      },
    );

    if (response.statusCode == 200) {
      var participantsJson = jsonDecode(response.body);

      // Ensure participantsJson is not null and is a list before processing it.
      if (participantsJson != null && participantsJson is List) {
        return participantsJson
            .map((json) => EventParticipant.fromJson(json))
            .toList();
      }
    }

    return [];
  }

  Future<CreateAppointmentData?> getCreateAppointmentData(int patientId) async {
    final response = await DataService().get(
      '/create-appointment-data',
      queryParams: {
        'patient_id': patientId.toString(),
      },
    );

    if (response.statusCode == 200) {
      return CreateAppointmentData.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<EditAppointmentData?> getEditAppointmentData(int appointmentId) async {
    final response = await DataService().get(
      '/edit-appointment-data',
      queryParams: {
        'appointment_id': appointmentId.toString(),
      },
    );

    if (response.statusCode == 200) {
      return EditAppointmentData.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }
}
