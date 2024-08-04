import 'dart:convert';
import 'dart:typed_data';
import '../models/user.dart';
import '../services/data_service.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  factory UserRepository() => _instance;
  UserRepository._internal();

  Future<User?> createUser(User user) async {
    final response = await DataService().post(
      '/user',
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

  Future<bool> delete(int id) async {
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

// Create or update avatar
  Future<bool> createOrUpdateAvatar(int userId, Uint8List imageData) async {
    final response = await DataService().postFile(
      '/avatar',
      file: imageData,
      filename: 'avatar.png',
      fields: {'user_id': userId.toString()},
    );
    return response.statusCode == 200;
  }

  String getAvatarUrl(int userId) {
    return 'avatar://$userId';
  }

  // Get user avatar
  Future<Uint8List?> getAvatar(int userId) async {
    final response = await DataService().get('/avatar/$userId');
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  // Update avatar
  Future<bool> updateAvatar(int userId, Uint8List imageData) async {
    final response = await DataService().putFile(
      '/avatar/$userId',
      file: imageData,
      filename: 'avatar.png',
    );
    return response.statusCode == 200;
  }

  // Delete avatar
  Future<bool> deleteAvatar(int userId) async {
    final response = await DataService().delete('/avatar/$userId');
    return response.statusCode == 200;
  }

  // Example of a protected endpoint call
  Future<Map<String, dynamic>?> callProtectedEndpoint() async {
    final response = await DataService().get('/protected-endpoint');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }
}
