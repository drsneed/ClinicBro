import 'package:flutter/material.dart';

import '../models/appointment_item.dart';
import '../widgets/scheduler/appointment_details_popup.dart';
import '../widgets/scheduler/appointment_edit_dialog.dart';

class OverlayManager {
  OverlayEntry? _currentOverlay;

  void clearCurrentOverlay() {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }
  }

  void _launchEditDialog(BuildContext context, AppointmentItem appointment) {
    clearCurrentOverlay();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AppointmentEditDialog(appointment: appointment);
      },
    );
  }

  void showAppointmentDetailsPopup(
      BuildContext context, AppointmentItem appointment, Offset position) {
    final overlay = Overlay.of(context);
    clearCurrentOverlay();
    _currentOverlay = OverlayEntry(
      builder: (context) => AppointmentDetailsPopup(
        appointment: appointment,
        position: position,
        onEdit: () => _launchEditDialog(context, appointment),
      ),
    );

    overlay.insert(_currentOverlay!);
  }
}
