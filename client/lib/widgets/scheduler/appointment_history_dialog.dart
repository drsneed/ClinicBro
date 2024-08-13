import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import '../../models/appointment.dart'; // Adjust the import based on your project structure
import '../../repositories/appointment_repository.dart'; // Adjust this import based on your project structure

class AppointmentHistoryDialog extends StatefulWidget {
  final int patientId;

  const AppointmentHistoryDialog({
    super.key,
    required this.patientId,
  });

  @override
  _AppointmentHistoryDialogState createState() =>
      _AppointmentHistoryDialogState();
}

class _AppointmentHistoryDialogState extends State<AppointmentHistoryDialog> {
  late Future<List<Appointment>> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = _fetchAppointmentHistory();
  }

  Future<List<Appointment>> _fetchAppointmentHistory() async {
    try {
      final appointments = await AppointmentRepository()
          .getAllAppointments(patientId: widget.patientId);
      return appointments;
    } catch (e) {
      print('Error fetching appointment history: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: const Text('Appointment History'),
      content: FutureBuilder<List<Appointment>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == mat.ConnectionState.waiting) {
            return const Center(child: ProgressRing());
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text('Error fetching appointment history.'));
          }

          final appointments = snapshot.data ?? [];

          if (appointments.isEmpty) {
            return const Center(child: Text('No appointments found.'));
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return ListTile(
                title: Text(appointment.title ?? ''),
                subtitle: Text('Date: ${appointment.apptDate}'),
                trailing: Text(
                    'From: ${appointment.apptFrom} - To: ${appointment.apptTo}'),
              );
            },
          );
        },
      ),
      actions: [
        Button(
          child: const Text('Close'),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
