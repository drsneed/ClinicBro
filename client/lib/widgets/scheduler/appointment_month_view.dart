import 'package:fluent_ui/fluent_ui.dart';
import '../../managers/overlay_manager.dart';
import '../../models/appointment_item.dart';

class AppointmentMonthView extends StatelessWidget {
  final AppointmentItem appointment;
  final OverlayManager overlayManager;

  const AppointmentMonthView({
    super.key,
    required this.appointment,
    required this.overlayManager,
  });

  Color _getBackgroundColor(String colorString, BuildContext context) {
    try {
      return Color(int.parse(colorString.replaceAll('#', '0xFF')));
    } catch (e) {
      final isDarkTheme = FluentTheme.of(context).brightness == Brightness.dark;
      // Use the theme's background color if parsing fails
      return isDarkTheme
          ? Color.fromARGB(255, 41, 40, 40)
          : Color.fromARGB(255, 225, 223, 221);
    }
  }

  Color _getTextColor(Color backgroundColor) {
    double grayscale = (0.299 * backgroundColor.red +
            0.587 * backgroundColor.green +
            0.114 * backgroundColor.blue) /
        255;
    return grayscale > 0.5 ? Colors.black : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = _getBackgroundColor(appointment.color, context);
    Color textColor = _getTextColor(backgroundColor);
    final isEvent = appointment.isEvent();

    return GestureDetector(
      onTapUp: (details) {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        final Offset globalPosition =
            renderBox.localToGlobal(details.localPosition);
        overlayManager.showAppointmentDetailsPopup(
            context, appointment, globalPosition);
      },
      child: Container(
        constraints: BoxConstraints(
          maxWidth: double.infinity, // Ensure the container takes full width
        ),
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          appointment.title,
          style: TextStyle(fontSize: 14, color: textColor),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
