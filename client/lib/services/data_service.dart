import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class DataService {
  final String baseUrl;
  DataService(this.baseUrl);

  Future<String?> authenticateUser(String username, String password) async {
    final url = Uri.parse('$baseUrl/client-api/authenticate');
    final response = await http.post(
      url,
      headers: {'Accept': 'application/json'},
      body: jsonEncode({
        'name': username,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        return data['token']; // Adjust based on your response structure
      }
      return null;
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  // Create a new user
  Future<User?> createUser(User user) async {
    final url = Uri.parse('$baseUrl/client-api/user');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  // Read a user by ID
  Future<User?> getUser(int id) async {
    final url = Uri.parse('$baseUrl/client-api/users/$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  // Update a user
  Future<User?> updateUser(User user) async {
    final url = Uri.parse('$baseUrl/client-api/users/${user.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  // Delete a user
  Future<bool> deleteUser(int id) async {
    final url = Uri.parse('$baseUrl/client-api/users/$id');
    final response = await http.delete(url);
    return response.statusCode == 204;
  }

  // Get all users
  Future<List<User>> getAllUsers() async {
    final url = Uri.parse('$baseUrl/client-api/users');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> usersJson = jsonDecode(response.body);
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      // Handle errors or throw exceptions
      return [];
    }
  }
}
