import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../models/appointment_item.dart';
import '../repositories/appointment_repository.dart';
import '../utils/logger.dart';
import '../widgets/scheduler/appointment_details_popup.dart';
import '../widgets/scheduler/appointment_edit_dialog.dart';
import '../widgets/scheduler/edit_appointment_dialog.dart';

class OverlayManager {
  OverlayEntry? _currentOverlay;

  void clearCurrentOverlay() {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }
  }

  void showEditAppointmentDialog(
    BuildContext context,
    int appointmentId,
    void Function() onRefresh,
  ) async {
    final repo = AppointmentRepository();
    final viewModel = await repo.getEditAppointmentData(appointmentId);

    if (!context.mounted) {
      // The context is no longer valid, so we do nothing
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600), // Set max width
            child: EditAppointmentDialog(
              viewModel: viewModel,
              onSave: (Appointment updatedAppointment) async {
                try {
                  final updatedAppointmentFromServer =
                      await repo.updateAppointment(updatedAppointment);
                  if (updatedAppointmentFromServer != null) {
                    onRefresh();
                  } else {
                    // Handle the error
                    // e.g., show a message to the user
                  }
                } catch (e) {
                  // Handle any other exceptions
                  // e.g., show a message to the user
                }
              },
            ),
          ),
        );
      },
    );
  }

  void showAppointmentDetailsPopup(
      BuildContext context,
      AppointmentItem appointment,
      Offset position,
      void Function(int) onEditAppointment) {
    final overlay = Overlay.of(context);
    clearCurrentOverlay();

    _currentOverlay = OverlayEntry(
      builder: (context) => AppointmentDetailsPopup(
        appointment: appointment,
        position: position,
        onEdit: () {
          clearCurrentOverlay();
          onEditAppointment(appointment.apptId);
        },
      ),
    );

    overlay.insert(_currentOverlay!);
  }
}
