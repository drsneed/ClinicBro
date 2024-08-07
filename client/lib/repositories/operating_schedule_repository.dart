import 'dart:convert';
import '../models/operating_schedule.dart'; // Import your OperatingSchedule model
import '../services/data_service.dart';

class OperatingScheduleRepository {
  static final OperatingScheduleRepository _instance =
      OperatingScheduleRepository._internal();
  factory OperatingScheduleRepository() => _instance;
  OperatingScheduleRepository._internal();

  Future<OperatingSchedule?> createOperatingSchedule(
      OperatingSchedule schedule) async {
    final response = await DataService().post(
      '/operating-schedule',
      body: jsonEncode(schedule.toJson()),
    );
    if (response.statusCode == 201) {
      return OperatingSchedule.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<OperatingSchedule?> getOperatingSchedule({
    required int locationId,
    int? userId,
  }) async {
    final uri = Uri(
      path: '/operating-schedule',
      queryParameters: userId != null
          ? {'location_id': locationId.toString(), 'user_id': userId.toString()}
          : {'location_id': locationId.toString()},
    );

    final response = await DataService().get(uri.toString());
    if (response.statusCode == 200) {
      return OperatingSchedule.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<OperatingSchedule?> updateOperatingSchedule(
      OperatingSchedule schedule) async {
    final response = await DataService().put(
      '/operating-schedule',
      body: jsonEncode(schedule.toJson()),
    );

    if (response.statusCode == 200) {
      return OperatingSchedule.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<bool> deleteOperatingSchedule({
    required int locationId,
    int? userId,
  }) async {
    final uri = Uri(
      path: '/operating-schedule',
      queryParameters: userId != null
          ? {'location_id': locationId.toString(), 'user_id': userId.toString()}
          : {'location_id': locationId.toString()},
    );

    final response = await DataService().delete(uri.toString());
    return response.statusCode == 204;
  }
}
