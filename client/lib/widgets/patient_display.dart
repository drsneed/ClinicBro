import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:intl/intl.dart';
import '../models/patient_item.dart';

class PatientDisplay extends StatelessWidget {
  final PatientItem patient;
  final VoidCallback? onDragStart; // Add this line
  const PatientDisplay({Key? key, required this.patient, this.onDragStart})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final dob = patient.dateOfBirth != null
        ? dateFormatter.format(patient.dateOfBirth!)
        : 'N/A';
    final textColor = patient.active
        ? theme.inactiveColor
        : theme.inactiveColor.withOpacity(0.5);

    Widget patientTile = _buildPatientTile(theme, textColor, dob);

    if (patient.active) {
      return Draggable<PatientItem>(
        data: patient,
        onDragStarted: () {
          if (onDragStart != null) {
            onDragStart!(); // Trigger the callback when drag starts
          }
        },
        feedback: mat.Material(
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(8.0),
            color: theme.accentColor.withOpacity(0.8),
            child: Text(
              patient.fullName,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: patientTile,
        ),
        child: patientTile,
      );
    } else {
      return patientTile;
    }
  }

  Widget _buildPatientTile(FluentThemeData theme, Color textColor, String dob) {
    return Container(
      color: Colors.transparent,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: patient.active
              ? theme.accentColor.withOpacity(0.8)
              : theme.inactiveColor.withOpacity(0.5),
          child: Text(
            _getInitials(patient.fullName),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          patient.fullName,
          style: TextStyle(color: textColor),
        ),
        subtitle: Text(
          'DOB: $dob',
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }

  String _getInitials(String fullName) {
    List<String> names = fullName.split(",");
    if (names.isEmpty) return "";
    if (names.length == 1) return names[0].trim()[0].toUpperCase();
    return (names[1].trim()[0] + names.first[0]).toUpperCase();
  }
}
