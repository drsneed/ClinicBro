// patient_tab_manager.dart
import 'package:flutter/foundation.dart';

class PatientTab {
  final int id;
  final String name;

  PatientTab({required this.id, required this.name});
}

class PatientTabManager extends ChangeNotifier {
  List<PatientTab> _openTabs = [];
  int? _selectedTabId;

  List<PatientTab> get openTabs => _openTabs;
  int? get selectedTabId => _selectedTabId;

  void openTab(int patientId, String patientName) {
    if (!_openTabs.any((tab) => tab.id == patientId)) {
      _openTabs.add(PatientTab(id: patientId, name: patientName));
      if (_openTabs.first.id == patientId) {
        selectTab(patientId);
      }
      //_selectedTabId = patientId;
      notifyListeners();
    } else {
      //selectTab(patientId);
    }
  }

  void closeTab(int patientId) {
    _openTabs.removeWhere((tab) => tab.id == patientId);
    if (_selectedTabId == patientId) {
      _selectedTabId = _openTabs.isNotEmpty ? _openTabs.last.id : null;
    }
    notifyListeners();
  }

  void selectTab(int patientId) {
    if (_openTabs.any((tab) => tab.id == patientId)) {
      print('selecting tab for patient $patientId');
      _selectedTabId = patientId;
    } else {
      _selectedTabId = null;
    }
    notifyListeners();
  }

  void reorderTabs(List<int> newOrder) {
    final newTabs = newOrder
        .map((id) => _openTabs.firstWhere((tab) => tab.id == id))
        .toList();
    _openTabs = newTabs;
    notifyListeners();
  }
}
