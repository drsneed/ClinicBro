import 'dart:convert';
import 'dart:typed_data';
import '../models/operating_schedule.dart';
import '../models/patient_item.dart';
import '../models/user.dart';
import '../models/user_preferences.dart';
import '../services/data_service.dart';
import '../utils/logger.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  Future<User?> createUser(User user) async {
    final response = await DataService().post(
      '/users',
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<User?> getUser(int id) async {
    final response = await DataService().get('/users/$id');
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<User?> updateUser(User user) async {
    final response = await DataService().put(
      '/users/${user.id}',
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<bool> deleteUser(int id) async {
    final response = await DataService().delete('/users/$id');
    return response.statusCode == 204;
  }

  Future<List<User>> getAllUsers() async {
    final response = await DataService().get('/users');
    if (response.statusCode == 200) {
      List<dynamic> usersJson = jsonDecode(response.body);
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      // Handle errors or throw exceptions
      return [];
    }
  }

  Future<List<PatientItem>> getRecentPatients() async {
    final response = await DataService().get('/recent-patients');
    if (response.statusCode == 200) {
      List<dynamic> patientsJson = jsonDecode(response.body);
      return patientsJson.map((json) => PatientItem.fromJson(json)).toList();
    } else {
      // Handle errors or throw exceptions
      return [];
    }
  }

  // Create or update avatar for a user
  Future<bool> createOrUpdateAvatar(int userId, Uint8List imageData) async {
    final response = await DataService().postFile(
      '/avatars/user/$userId',
      file: imageData,
      filename: 'avatar.png',
    );
    return response.statusCode == 200;
  }

  // Get user avatar
  Future<Uint8List?> getAvatar(int userId) async {
    final response = await DataService().get('/avatars/user/$userId');
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  // Update avatar for a user
  Future<bool> updateAvatar(int userId, Uint8List imageData) async {
    final response = await DataService().putFile(
      '/avatars/user/$userId',
      file: imageData,
      filename: 'avatar.png',
    );
    return response.statusCode == 200;
  }

  // Delete avatar for a user
  Future<bool> deleteAvatar(int userId) async {
    final response = await DataService().delete('/avatars/user/$userId');
    return response.statusCode == 200;
  }

  // Change user password
  Future<bool> changePassword(
      String currentPassword, String newPassword) async {
    final response = await DataService().post(
      '/change-password',
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
      }),
    );

    return response.statusCode == 200;
  }

  Future<OperatingSchedule?> getOperatingSchedule(int locationId) async {
    final response = await DataService()
        .get('/operating-schedule/current-user?location_id=$locationId');
    if (response.statusCode == 200) {
      return OperatingSchedule.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<UserPreferences?> getUserPreferences(int userId) async {
    final response = await DataService().get('/user-preferences/$userId');
    if (response.statusCode == 200) {
      try {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        return UserPreferences.fromJson(jsonResponse);
      } catch (e) {
        Logger().log(Level.SEVERE, e.toString());
        return null;
      }
    } else {
      return null;
    }
  }

  Future<bool> updateUserPreference(
      int userId, String key, String value) async {
    final response = await DataService().put(
      '/user-preferences/$userId/$key',
      body: jsonEncode({'preference_value': value}),
    );
    return response.statusCode == 200;
  }
}
