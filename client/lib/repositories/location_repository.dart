import 'dart:convert';
import '../models/location.dart'; // Import your Location model
import '../models/operating_schedule.dart';
import '../services/data_service.dart';

class LocationRepository {
  static final LocationRepository _instance = LocationRepository._internal();
  factory LocationRepository() => _instance;
  LocationRepository._internal();

  Future<Location?> createLocation(Location location) async {
    final response = await DataService().post(
      '/locations',
      body: jsonEncode(location.toJson()),
    );

    if (response.statusCode == 201) {
      return Location.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<Location?> getLocation(int id) async {
    final response = await DataService().get('/locations/$id');
    if (response.statusCode == 200) {
      return Location.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<Location?> updateLocation(Location location) async {
    final response = await DataService().put(
      '/locations/${location.id}',
      body: jsonEncode(location.toJson()),
    );

    if (response.statusCode == 200) {
      return Location.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }

  Future<bool> deleteLocation(int id) async {
    final response = await DataService().delete('/locations/$id');
    return response.statusCode == 204;
  }

  Future<List<Location>> getAllLocations({bool includeInactive = false}) async {
    final queryParams = <String, String>{};
    if (includeInactive) {
      queryParams['include_inactive'] = 'true';
    }
    final response =
        await DataService().get('/locations', queryParams: queryParams);
    if (response.statusCode == 200) {
      List<dynamic> locationsJson = jsonDecode(response.body);
      return locationsJson.map((json) => Location.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  // Get hours of operation for a location
  Future<OperatingSchedule?> getHoursOfOperation(int locationId) async {
    final response =
        await DataService().get('/operating-schedule?location_id=$locationId');
    if (response.statusCode == 200) {
      return OperatingSchedule.fromJson(jsonDecode(response.body));
    } else {
      return null;
    }
  }
}
