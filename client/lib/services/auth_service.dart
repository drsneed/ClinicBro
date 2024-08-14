import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../managers/preferences_manager.dart';
import '../repositories/user_repository.dart';
import 'data_service.dart';
import '../managers/user_manager.dart';
import 'package:dotenv/dotenv.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  String? _currentOrgId;
  String? get currentOrgId => _currentOrgId;

  final UserManager _userManager = UserManager();
  final PreferencesManager _preferencesManager = PreferencesManager();

  String getClientApiKey() {
    var env = DotEnv()..load();
    assert(env.isDefined('CLIENT_API_KEY'), 'Missing CLIENT_API_KEY env var');
    final String clientApiKey = env['CLIENT_API_KEY'] ?? '';
    print('clientApiKey = $clientApiKey');

    return clientApiKey;
  }

  void signOut() {
    DataService().setToken(null);
    UserManager().setCurrentUser(null);
    _currentOrgId = null;
  }

  Future<bool> signIn(String orgId, String username, String password) async {
    final dataService = DataService();
    final response = await dataService.post(
      '/authenticate-user',
      headers: {'X-CLIENT-API-KEY': getClientApiKey()},
      body:
          jsonEncode({'org_id': orgId, 'name': username, 'password': password}),
    );
    if (response.statusCode != 200) return false;
    final responseData = jsonDecode(response.body);
    final token = responseData['token'];
    final userId = responseData['user_id'];
    dataService.setToken(token);
    _currentOrgId = orgId; // Store the org_id

    // Fetch user details and update UserManager
    final user = await UserRepository().getUser(userId);
    if (user != null) {
      _userManager.setCurrentUser(user);
      // Load user preferences
      await _preferencesManager.reloadUserPreferences(user.id);
    }
    return true;
  }

  Future<void> resetToken(String password) async {
    if (_currentOrgId == null) {
      throw Exception("No organization ID found. Please sign in again.");
    }
    final currentUser = _userManager.currentUser;
    if (currentUser == null) {
      throw Exception("No current user found. Cannot reset token.");
    }
    final dataService = DataService();
    final response = await dataService.post(
      '/authenticate-user',
      headers: {'X-CLIENT-API-KEY': getClientApiKey()},
      body: jsonEncode({
        'org_id': _currentOrgId,
        'name': currentUser.name,
        'password': password,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception("Failed to reset token.");
    }
    final responseData = jsonDecode(response.body);
    final token = responseData['token'];
    dataService.setToken(token);
  }

  Future<bool> validateServer() async {
    try {
      final dataService = DataService();
      final response = await dataService.get('/validate-server',
          headers: {'X-CLIENT-API-KEY': getClientApiKey()});
      if (response.statusCode == 200) {
        final responseString = jsonDecode(response.body);
        return responseString == "ClinicBro-Server";
      } else {
        return false;
      }
    } on http.ClientException catch (e) {
      return false;
    } on SocketException catch (e) {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> validateOrganization(String orgId) async {
    final dataService = DataService();
    final response = await dataService.post(
      '/validate-organization',
      headers: {'X-CLIENT-API-KEY': getClientApiKey()},
      body: jsonEncode({'org_id': orgId}),
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      return responseData['valid'] ==
          true; // Adjust based on your server response
    } else {
      return false;
    }
  }
}
