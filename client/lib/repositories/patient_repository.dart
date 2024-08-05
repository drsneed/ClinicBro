import 'dart:convert';
import 'dart:typed_data';
import '../models/patient.dart';
import '../services/data_service.dart';

class PatientRepository {
  static final PatientRepository _instance = PatientRepository._internal();
  factory PatientRepository() => _instance;
  PatientRepository._internal();

  Future<Patient?> createPatient(Patient patient) async {
    final response = await DataService().post(
      '/patients',
      body: jsonEncode(patient.toJson()),
    );

    if (response.statusCode == 201) {
      return Patient.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<Patient?> getPatient(int id) async {
    final response = await DataService().get('/patients/$id');
    if (response.statusCode == 200) {
      return Patient.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<Patient?> updatePatient(Patient patient) async {
    final response = await DataService().put(
      '/patients/${patient.id}',
      body: jsonEncode(patient.toJson()),
    );

    if (response.statusCode == 200) {
      return Patient.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  Future<bool> deletePatient(int id) async {
    final response = await DataService().delete('/patients/$id');
    return response.statusCode == 204;
  }

  Future<List<Patient>> getAllPatients() async {
    final response = await DataService().get('/patients');
    if (response.statusCode == 200) {
      List<dynamic> patientsJson = jsonDecode(response.body);
      return patientsJson.map((json) => Patient.fromJson(json)).toList();
    } else {
      // Handle errors or throw exceptions
      return [];
    }
  }

  // Create or update avatar for a patient
  Future<bool> createOrUpdateAvatar(int patientId, Uint8List imageData) async {
    final response = await DataService().postFile(
      '/avatars',
      file: imageData,
      filename: 'avatar.png',
      fields: {
        'type': 'patient',
        'entity_id': patientId.toString(),
      },
    );
    return response.statusCode == 200;
  }

  // Get patient avatar
  Future<Uint8List?> getAvatar(int patientId) async {
    final response = await DataService().get('/avatars/patient/$patientId');
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      // Handle errors or throw exceptions
      return null;
    }
  }

  // Update avatar for a patient
  Future<bool> updateAvatar(int patientId, Uint8List imageData) async {
    final response = await DataService().putFile(
      '/avatars/patient/$patientId',
      file: imageData,
      filename: 'avatar.png',
    );
    return response.statusCode == 200;
  }

  // Delete avatar for a patient
  Future<bool> deleteAvatar(int patientId) async {
    final response = await DataService().delete('/avatars/patient/$patientId');
    return response.statusCode == 200;
  }
}
