import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

class WeekView extends StatelessWidget {
  final PageController pageController;
  final Function(int) onPageChanged;

  const WeekView({
    Key? key,
    required this.pageController,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      onPageChanged: onPageChanged,
      itemBuilder: (context, index) {
        final startDate =
            DateTime.now().add(Duration(days: (index - 1000) * 7));
        return _buildWeekSchedule(context, startDate);
      },
    );
  }

  Widget _buildWeekSchedule(BuildContext context, DateTime startDate) {
    return Column(
      children: [
        _buildWeekHeader(context, startDate),
        Expanded(
          child: Row(
            children: List.generate(7, (dayIndex) {
              final currentDate = startDate.add(Duration(days: dayIndex));
              return Expanded(
                child: _buildDaySchedule(context, currentDate),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekHeader(BuildContext context, DateTime startDate) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: FluentTheme.of(context).inactiveBackgroundColor,
          ),
        ),
      ),
      child: Row(
        children: List.generate(7, (index) {
          final date = startDate.add(Duration(days: index));
          return Expanded(
            child: Column(
              children: [
                Text(
                  DateFormat('E').format(date),
                  style: FluentTheme.of(context).typography.caption,
                ),
                Text(
                  DateFormat('d').format(date),
                  style: FluentTheme.of(context).typography.bodyLarge,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDaySchedule(BuildContext context, DateTime date) {
    return ListView.builder(
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
                left: 2,
                top: 2,
                child: SizedBox(
                  width: 30,
                  child: Text(
                    timeString,
                    style: FluentTheme.of(context)
                        .typography
                        .caption
                        ?.copyWith(fontSize: 10),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 30,
                child: CustomPaint(
                  size: Size(double.infinity, 1),
                  painter: DashedLinePainter(
                    color: FluentTheme.of(context).inactiveBackgroundColor,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(int index) {
    final hour = index % 24;
    final ampm = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour % 12 == 0 ? 12 : hour % 12;
    return '$hour12$ampm';
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashWidth = 5, dashSpace = 3, startX = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
