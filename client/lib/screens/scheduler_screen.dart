import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat
    show Colors, FloatingActionButton, CircleBorder;
import '../models/appointment_item.dart';
import '../repositories/appointment_repository.dart';
import '../utils/logger.dart';
import '../widgets/scheduler/navigation_panel.dart';
import '../widgets/scheduler/scheduler.dart';
import '../widgets/scheduler/scheduler_carousel.dart';
import '../widgets/patient_finder.dart'; // Import the PatientFinder widget

class SchedulerScreen extends StatefulWidget {
  final bool isMobile;
  const SchedulerScreen({
    Key? key,
    required this.isMobile,
  }) : super(key: key);
  @override
  _SchedulerScreenState createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  bool _isFlyoutVisible = false;
  String _viewMode = 'Day'; // Default view mode
  bool _isMultiple = false; // Default view type
  bool _showNavigation = false; // Default months navigation visibility
  DateTime _centerDate = DateTime.now(); // Add this line
  List<AppointmentItem> _appointments = [];
  void _toggleFlyout() {
    setState(() {
      _isFlyoutVisible = !_isFlyoutVisible;
    });
  }

  void _handleViewModeChange(String viewMode) {
    setState(() {
      _viewMode = viewMode;
    });
  }

  void _handleViewTypeChange(bool isMultiple) {
    setState(() {
      _isMultiple = isMultiple;
    });
  }

  void _handleShowNavigationChange(bool showNavigation) {
    setState(() {
      _showNavigation = showNavigation;
    });
  }

  void onDateChanged(DateTime newDate) {
    setState(() {
      _centerDate = newDate;
      _loadAppointments();
    });
  }

  void _loadAppointments() async {
    final logger = Logger();
    int startYear = _centerDate.year;
    int startMonth = _centerDate.month - 1;
    if (startMonth == 0) {
      startYear -= 1;
      startMonth = 12;
    }
    final startDate = DateTime(startYear, startMonth, 1);

    int endYear = _centerDate.year;
    int endMonth = _centerDate.month + 2;
    if (endMonth > 12) {
      endYear += 1;
      endMonth -= 12;
    }
    final endDate = DateTime(endYear, endMonth, 0);

    final apptRepository = AppointmentRepository();
    logger.log(Level.INFO,
        "attempting to fetch appointments from $startDate to $endDate");
    final appointments =
        await apptRepository.getAppointmentsInRange(startDate, endDate);
    setState(() {
      _appointments = appointments;
      logger.log(Level.INFO, "loaded ${_appointments.length} appointments");
    });
  }

  List<DateTime> _getSelectedDates() {
    switch (_viewMode) {
      case 'Day':
        return [_centerDate];
      case 'Week':
        final startDate = DateTime(_centerDate.year, _centerDate.month,
            _centerDate.day - _centerDate.weekday);
        return List.generate(7, (index) {
          return DateTime(
              startDate.year, startDate.month, startDate.day + index);
        });
      case 'Month':
        List<DateTime> result = [];
        var date = DateTime(_centerDate.year, _centerDate.month, 1);
        while (date.month == _centerDate.month) {
          result.add(date);
          date = DateTime(date.year, date.month, date.day + 1);
        }
        return result;
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = !widget.isMobile;
    print('building scheduler screen for date $_centerDate');
    return Row(
      children: [
        // Vertical panel on the left
        if (_showNavigation)
          SchedulerNavigationPanel(
            isVisible: _showNavigation,
            centerDate: _centerDate,
            onDateChanged: onDateChanged,
            selectedDates: _getSelectedDates(),
          ),

        Expanded(
          child: Stack(
            children: [
              ScaffoldPage(
                header: PageHeader(
                  title: SchedulerCarousel(
                    onViewModeChange: _handleViewModeChange,
                    selectedViewMode: _viewMode,
                    onViewTypeChange: _handleViewTypeChange,
                    isMultiple: _isMultiple,
                    onShowNavigationChange: _handleShowNavigationChange,
                    showNavigation: _showNavigation,
                  ),
                ),
                content: Scheduler(
                  viewMode: _viewMode,
                  isMultiple: _isMultiple,
                  centerDate: _centerDate,
                  onDateChanged: onDateChanged,
                  appointments: _appointments,
                  // Additional parameters
                ),
              ),
              if (isDesktop) _buildDesktopFlyout(),
              if (!isDesktop) _buildMobileFlyout(),
              _buildFloatingActionButton(isDesktop),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopFlyout() {
    return Positioned(
      top: 0,
      right: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        width: _isFlyoutVisible ? 400 : 0,
        child: Container(
          color: FluentTheme.of(context).micaBackgroundColor,
          child: _isFlyoutVisible
              ? PatientFinder()
              : null, // Use PatientFinder here
        ),
      ),
    );
  }

  Widget _buildMobileFlyout() {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      left: 0,
      right: 0,
      bottom: _isFlyoutVisible ? 0 : -200,
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          color: FluentTheme.of(context).micaBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: mat.Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: PatientFinder(), // Use PatientFinder here
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isDesktop) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      right: isDesktop
          ? (_isFlyoutVisible ? 416 : 16)
          : 16, // Move right if flyout visible
      bottom: !isDesktop
          ? (_isFlyoutVisible ? 216 : 16)
          : 16, // Move up if flyout visible
      child: SizedBox(
        width: isDesktop ? 40 : 64,
        height: isDesktop ? 40 : 64,
        child: mat.FloatingActionButton(
          child: Icon(
            _isFlyoutVisible
                ? (isDesktop
                    ? FluentIcons.chevron_right
                    : FluentIcons.chevron_down)
                : FluentIcons.people,
            color: mat.Colors.white,
            size: isDesktop ? 20 : 24,
          ),
          backgroundColor: mat.Colors.blue,
          shape: mat.CircleBorder(),
          onPressed: _toggleFlyout,
          tooltip: _isFlyoutVisible ? 'Hide Patients' : 'Show Patients',
        ),
      ),
    );
  }
}
