import 'package:fluent_ui/fluent_ui.dart';
import '../../models/appointment_item.dart';
import '../../managers/overlay_manager.dart';
import 'appointment_day_view.dart';

class DayView extends StatelessWidget {
  final PageController pageController;
  final Function(int) onPageChanged;
  final List<AppointmentItem> appointments;
  final OverlayManager overlayManager;

  const DayView({
    Key? key,
    required this.pageController,
    required this.onPageChanged,
    required this.appointments,
    required this.overlayManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        final date = DateTime.now().add(Duration(days: index - 1000));
        return _buildDaySchedule(context, date);
      },
    );
  }

  Widget _buildDaySchedule(BuildContext context, DateTime date) {
    final dateAppointments = appointments
        .where((appt) => appt.apptDate == date.toString().split(' ')[0])
        .toList();

    return Container(
      color: FluentTheme.of(context).cardColor,
      child: ListView.builder(
        itemCount: 24,
        itemBuilder: (context, index) {
          String timeString = _formatTime(index);
          return Container(
            height: 60,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: FluentTheme.of(context).inactiveBackgroundColor,
                ),
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 8,
                  child: SizedBox(
                    width: 60,
                    height: 20,
                    child: Text(
                      timeString,
                      textAlign: TextAlign.center,
                      style: FluentTheme.of(context).typography.caption,
                    ),
                  ),
                ),
                Positioned(
                  left: 60,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color:
                              FluentTheme.of(context).inactiveBackgroundColor,
                        ),
                      ),
                    ),
                  ),
                ),
                ..._buildAppointmentsForHour(context, dateAppointments, index),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildAppointmentsForHour(
      BuildContext context, List<AppointmentItem> dateAppointments, int hour) {
    return dateAppointments.where((appt) {
      final apptHour = int.parse(appt.apptFrom.split(':')[0]);
      return apptHour == hour;
    }).map((appt) {
      final apptMinute = int.parse(appt.apptFrom.split(':')[1]);
      final topPosition =
          (apptMinute / 60) * 60; // Scale minutes to the 60px height

      return Positioned(
        left: 65,
        right: 5,
        top: topPosition,
        child: AppointmentDayView(
          appointment: appt,
          overlayManager: overlayManager,
        ),
      );
    }).toList();
  }

  String _formatTime(int index) {
    final hour = index % 24;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12:00 $ampm';
  }
}
