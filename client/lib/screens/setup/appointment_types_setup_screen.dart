import 'package:flutter/material.dart';

import '../../repositories/lookup_repository.dart';
import 'base_setup_screen.dart';

class AppointmentTypesSetupScreen extends StatelessWidget {
  const AppointmentTypesSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseSetupScreen(
      title: 'Appointment Types Setup',
      fetchItems: () => LookupRepository().lookupAppointmentTypes(true),
    );
  }
}
