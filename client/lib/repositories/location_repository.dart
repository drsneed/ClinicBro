import 'dart:convert';
import '../models/location.dart'; // Import your Location model
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
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<Location?> getLocation(int id) async {
    final response = await DataService().get('/locations/$id');
    if (response.statusCode == 200) {
      return Location.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
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
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<bool> deleteLocation(int id) async {
    final response = await DataService().delete('/locations/$id');
    return response.statusCode == 204;
  }

  Future<List<Location>> getAllLocations() async {
    final response = await DataService().get('/locations');
    if (response.statusCode == 200) {
      List<dynamic> locationsJson = jsonDecode(response.body);
      return locationsJson.map((json) => Location.fromJson(json)).toList();
    } else {
      // Handle errors or throw exceptions
      return [];
    }
  }
}
