import 'dart:convert';
import '../repositories/user_repository.dart';
import 'data_service.dart';
import '../managers/user_manager.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  void signOut() {
    DataService().setToken(null);
    UserManager().setCurrentUser(null);
  }

  Future<bool> signIn(String username, String password) async {
    final dataService = DataService();
    final response = await dataService.post(
      '/authenticate',
      body: jsonEncode({'name': username, 'password': password}),
    );
    if (response.statusCode != 200) return false;
    final responseData = jsonDecode(response.body);
    final token = responseData['token'];
    final userId = responseData['user_id'];
    dataService.setToken(token);
    // Fetch user details and update UserManager
    final user = await UserRepository().getUser(userId);
    if (user != null) {
      UserManager().setCurrentUser(user);
    }
    return true;
  }
}
