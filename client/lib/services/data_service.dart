import 'dart:typed_data';
import 'package:http/http.dart' as http;

class DataService {
  static final DataService _instance = DataService._internal();
  static const String baseUrl = 'http://192.168.1.34:33420';
  factory DataService() => _instance;
  DataService._internal();

  String? _jwtToken;
  String? get jwtToken => _jwtToken;
  void setToken(String? token) {
    _jwtToken = token;
  }

  Future<http.Response> post(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? queryParams,
  }) async {
    return request('POST', path,
        body: body, headers: headers, queryParams: queryParams);
  }

  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    return request('GET', path, headers: headers, queryParams: queryParams);
  }

  Future<http.Response> put(
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? queryParams,
  }) async {
    return request('PUT', path,
        body: body, headers: headers, queryParams: queryParams);
  }

  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    return request('DELETE', path, headers: headers, queryParams: queryParams);
  }

  Future<http.Response> request(
    String method,
    String path, {
    Map<String, String>? headers,
    Object? body,
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(path, queryParams);
    final requestHeaders = {
      'Content-Type': 'application/json',
      if (_jwtToken != null) 'Authorization': 'Bearer $_jwtToken',
      ...?headers,
    };

    switch (method.toUpperCase()) {
      case 'GET':
        return await http.get(uri, headers: requestHeaders);
      case 'POST':
        return await http.post(uri, headers: requestHeaders, body: body);
      case 'PUT':
        return await http.put(uri, headers: requestHeaders, body: body);
      case 'DELETE':
        return await http.delete(uri, headers: requestHeaders);
      default:
        throw Exception('Unsupported HTTP method');
    }
  }

  Uri _buildUri(String path, Map<String, String>? queryParams) {
    final uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  Future<http.Response> postFile(
    String path, {
    required Uint8List file,
    required String filename,
    Map<String, String>? fields,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    var request = http.MultipartRequest('POST', url);

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      file,
      filename: filename,
    ));

    if (fields != null) {
      request.fields.addAll(fields);
    }

    request.headers.addAll({
      'Authorization': 'Bearer $_jwtToken',
    });

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  Future<http.Response> putFile(
    String path, {
    required Uint8List file,
    required String filename,
  }) async {
    final url = Uri.parse('$baseUrl$path');
    var request = http.MultipartRequest('PUT', url);

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      file,
      filename: filename,
    ));

    request.headers.addAll({
      'Authorization': 'Bearer $_jwtToken',
    });

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }
}
