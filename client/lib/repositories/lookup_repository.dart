import 'dart:convert';
import '../models/lookup_item.dart';
import '../services/data_service.dart';

class LookupRepository {
  static final LookupRepository _instance = LookupRepository._internal();
  factory LookupRepository() => _instance;
  LookupRepository._internal();

  Future<List<LookupItem>> lookupAppointmentTypes(bool includeInactive) async {
    final response = await DataService().get('/lookup/appointment-types');
    if (response.statusCode == 200) {
      try {
        List<dynamic> lookupItemsJson = jsonDecode(response.body);
        return lookupItemsJson
            .map((json) => LookupItem.fromJson(json))
            .toList();
      } catch (e) {
        // Handle JSON parsing error
        return [];
      }
    } else {
      // Handle errors or throw exceptions
      return [];
    }
  }
}
