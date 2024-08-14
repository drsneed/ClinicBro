import 'package:flutter/material.dart';
import '../../repositories/appointment_type_repository.dart';
import '../../repositories/lookup_repository.dart';
import 'appointment_type_detail_widget.dart';
import 'base_setup_screen.dart';

class AppointmentTypesSetupScreen extends StatefulWidget {
  const AppointmentTypesSetupScreen({super.key});

  @override
  _AppointmentTypesSetupScreenState createState() =>
      _AppointmentTypesSetupScreenState();
}

class _AppointmentTypesSetupScreenState
    extends State<AppointmentTypesSetupScreen> {
  @override
  Widget build(BuildContext context) {
    return BaseSetupScreen(
      fetchItems: () => LookupRepository().lookupAppointmentTypes(true),
      fetchDetailItem: (id) async {
        final repo = AppointmentTypeRepository();
        final appointmentType = await repo.getAppointmentType(id);

        if (appointmentType == null) {
          return const Text('Entity not found :(');
        } else {
          return AppointmentTypeDetail(
            appointmentType: appointmentType,
          );
        }
      },
    );
  }
}
