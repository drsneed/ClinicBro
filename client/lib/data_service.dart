import 'dart:convert';
import 'package:http/http.dart' as http;

class DataService {
  final String baseUrl;

  DataService(this.baseUrl);

  Future<String?> authenticateUser(String username, String password) async {
    final url = Uri.parse('$baseUrl/client-api/authenticate.json');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      print('response = ' + response.body);
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
}
