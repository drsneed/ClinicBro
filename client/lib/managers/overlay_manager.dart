import 'package:flutter/material.dart';

import '../models/appointment_item.dart';
import '../widgets/scheduler/appointment_details_popup.dart';

class OverlayManager {
  OverlayEntry? _currentOverlay;

  void clearCurrentOverlay() {
    if (_currentOverlay != null) {
      _currentOverlay!.remove();
      _currentOverlay = null;
    }
  }

  void showAppointmentDetailsPopup(
      BuildContext context, AppointmentItem appointment, Offset position) {
    final overlay = Overlay.of(context);
    clearCurrentOverlay();
    _currentOverlay = OverlayEntry(
      builder: (context) => AppointmentDetailsPopup(
        appointment: appointment,
        position: position,
      ),
    );

    overlay.insert(_currentOverlay!);
  }
}
