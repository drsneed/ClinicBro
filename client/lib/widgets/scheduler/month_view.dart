import 'package:fluent_ui/fluent_ui.dart';
import 'package:intl/intl.dart';

import '../../managers/overlay_manager.dart';
import '../../models/appointment.dart';
import '../../models/appointment_item.dart';
import '../../models/patient_item.dart';
import '../../repositories/appointment_repository.dart';
import '../../utils/calendar_grid.dart';
import '../../utils/logger.dart';
import 'appointment_month_view.dart';
import 'create_appointment_dialog.dart';

class MonthView extends StatefulWidget {
  final DateTime initialDate;
  final Function(DateTime)? onDateSelected;
  final Function(DateTime) onMonthChanged;
  final Function() onRefresh;
  final List<AppointmentItem> appointments;
  final OverlayManager overlayManager;
  final Function(int) onEditAppointment;
  const MonthView({
    Key? key,
    required this.initialDate,
    required this.onMonthChanged,
    required this.onRefresh,
    required this.appointments,
    required this.overlayManager,
    required this.onEditAppointment,
    this.onDateSelected,
  }) : super(key: key);

  @override
  _MonthViewState createState() => _MonthViewState();
}

class _MonthViewState extends State<MonthView> {
  late PageController _pageController;
  late DateTime _currentMonth;
  late CalendarGrid _calendarGrid;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
    _calendarGrid = CalendarGrid(_currentMonth);
    _pageController = PageController(initialPage: 1000);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onMonthChanged(_currentMonth);
    });
  }

  @override
  void didUpdateWidget(MonthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialDate.year != _currentMonth.year ||
        widget.initialDate.month != _currentMonth.month) {
      _updateToMonth(widget.initialDate);
    }
  }

  void _updateToMonth(DateTime newMonth) {
    setState(() {
      _currentMonth = DateTime(newMonth.year, newMonth.month);
      _calendarGrid = CalendarGrid(_currentMonth);
    });
    final newPage = 1000 +
        (newMonth.year - DateTime.now().year) * 12 +
        (newMonth.month - DateTime.now().month);
    _pageController.jumpToPage(newPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    final newMonth =
        DateTime(DateTime.now().year, DateTime.now().month + (page - 1000));
    if (newMonth.year != _currentMonth.year ||
        newMonth.month != _currentMonth.month) {
      setState(() {
        _currentMonth = newMonth;
      });
      widget.onMonthChanged(newMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final cellColor = theme.cardColor;
    final todayBackgroundColor = theme.accentColor;
    const todayColor = Colors.white;
    final borderColor = theme.inactiveColor;
    final textColor = theme.inactiveColor.withOpacity(0.3);
    final currentMonthColor = theme.inactiveColor.withOpacity(0.7);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellWidth = constraints.maxWidth / 7;
          final availableHeight = constraints.maxHeight - 50.0;
          final cellHeight = (availableHeight / _calendarGrid.numberOfRows)
              .clamp(0.0, cellWidth);
          final gridHeight = cellHeight * _calendarGrid.numberOfRows;

          return Column(
            children: [
              _buildWeekdayHeader(cellWidth, textColor),
              Container(
                height: gridHeight + 10,
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, page) {
                    final monthToShow = DateTime(
                      DateTime.now().year,
                      DateTime.now().month + (page - 1000),
                    );
                    return _buildCalendarGrid(
                      cellWidth,
                      cellHeight,
                      cellColor,
                      todayBackgroundColor,
                      todayColor,
                      borderColor,
                      textColor,
                      currentMonthColor,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCalendarGrid(
      double cellWidth,
      double cellHeight,
      Color cellColor,
      Color todayBackgroundColor,
      Color todayColor,
      Color borderColor,
      Color textColor,
      Color currentMonthColor) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: cellWidth / cellHeight,
      ),
      itemCount: _calendarGrid.days.length,
      itemBuilder: (context, index) {
        final date = _calendarGrid.days[index];
        final isCurrentMonth = date.month == _currentMonth.month;
        final isToday = date.year == DateTime.now().year &&
            date.month == DateTime.now().month &&
            date.day == DateTime.now().day;

        final dateAppointments = widget.appointments
            .where(
                (appt) => DateFormat('yyyy-MM-dd').parse(appt.apptDate) == date)
            .toList();

        return DragTarget<PatientItem>(
          onAccept: (PatientItem patient) {
            _showCreateAppointmentDialog(context, patient, date);
          },
          builder: (context, candidateData, rejectedData) {
            final isDraggingOver = candidateData.isNotEmpty;
            return GestureDetector(
              onTap: () {
                if (widget.onDateSelected != null) {
                  widget.onDateSelected!(date);
                }
              },
              child: Container(
                width: cellWidth,
                height: cellHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  color: isToday ? todayBackgroundColor : cellColor,
                ),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isToday
                                  ? todayColor
                                  : (isCurrentMonth
                                      ? currentMonthColor
                                      : textColor),
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                              fontSize: cellWidth * 0.10,
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: dateAppointments.length,
                            itemBuilder: (context, index) {
                              return AppointmentMonthView(
                                appointment: dateAppointments[index],
                                overlayManager: widget.overlayManager,
                                onEditAppointment: widget.onEditAppointment,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    if (isDraggingOver)
                      Container(
                        color: FluentTheme.of(context)
                            .accentColor
                            .withOpacity(0.3),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(FluentIcons.add, size: cellWidth * 0.2),
                              SizedBox(height: 4),
                              Text(
                                'New Appointment',
                                style: TextStyle(fontSize: cellWidth * 0.08),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateAppointmentDialog(
    BuildContext context,
    PatientItem patient,
    DateTime date,
  ) async {
    final logger = Logger();
    final repo = AppointmentRepository();

    logger.log(Level.INFO, 'scheduling patient ${patient.fullName} on $date');

    final viewModel = await repo.getCreateAppointmentData(patient.id);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600), // Set max width
            child: CreateAppointmentDialog(
              viewModel: viewModel,
              date: date,
              onSave: (Appointment newAppointment) async {
                // Validate and save Appointment model
                try {
                  final createdAppointment =
                      await repo.createAppointment(newAppointment);
                  if (createdAppointment != null) {
                    widget.onRefresh();
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

  Widget _buildWeekdayHeader(double cellSize, Color textColor) {
    return Container(
      height: 20,
      child: Row(
        children: List.generate(7, (index) {
          final weekday = ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index];
          return Container(
            width: cellSize,
            child: Center(
              child: Text(
                weekday,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
