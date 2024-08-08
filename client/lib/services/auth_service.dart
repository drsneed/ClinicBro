import 'dart:convert';
import 'dart:io';
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

  void signOut() {
    DataService().setToken(null);
    UserManager().setCurrentUser(null);
    _currentOrgId = null;
  }

  Future<bool> signIn(String orgId, String username, String password) async {
    final dataService = DataService();
    final response = await dataService.post(
      '/authenticate',
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
      UserManager().setCurrentUser(user);
    }
    return true;
  }

  Future<void> resetToken(String password) async {
    if (_currentOrgId == null) {
      throw Exception("No organization ID found. Please sign in again.");
    }
    final userManager = UserManager();
    final currentUser = userManager.currentUser;
    if (currentUser == null) {
      throw Exception("No current user found. Cannot reset token.");
    }
    final dataService = DataService();
    final response = await dataService.post(
      '/authenticate',
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

  Future<bool> validateOrganization(String orgId) async {
    var env = DotEnv()..load();
    assert(env.isDefined('ORG_VALIDATION_KEY'),
        'Missing ORG_VALIDATION_KEY env var');
    final String apiKey = env['ORG_VALIDATION_KEY'] ?? '';
    print('apiKey = $apiKey');
    final dataService = DataService();
    final response = await dataService.post(
      '/validate-org',
      headers: {'X-CLIENT-API-KEY': apiKey},
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
