import 'package:fluent_ui/fluent_ui.dart';

class PatientChartScreen extends StatelessWidget {
  final int patientId;

  const PatientChartScreen({Key? key, required this.patientId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Center(
        child: Text('Patient Chart for ID: $patientId'),
      ),
    );
  }
}
