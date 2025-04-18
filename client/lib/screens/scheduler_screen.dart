import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat
    show Colors, FloatingActionButton, CircleBorder, CircularProgressIndicator;
import '../models/appointment_item.dart';
import '../repositories/appointment_repository.dart';
import '../utils/logger.dart';
import '../managers/overlay_manager.dart';
import '../widgets/scheduler/navigation_panel.dart';
import '../widgets/scheduler/scheduler.dart';
import '../widgets/scheduler/scheduler_carousel.dart';

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
  final GlobalKey<SchedulerNavigationPanelState> _navigationPanelKey =
      GlobalKey<SchedulerNavigationPanelState>();

  String _viewMode = 'Month'; // Default view mode
  bool _isMultiple = false; // Default view type
  bool _showNavigation = false; // Default months navigation visibility
  DateTime _centerDate = DateTime.now();
  List<AppointmentItem> _appointments = [];
  DateTime? _cachedStartDate;
  DateTime? _cachedEndDate;
  List<AppointmentItem> _cachedAppointments = [];
  bool _isLoading = false;

  final _overlayManager = OverlayManager();

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

  void _onDateChanged(DateTime newDate) {
    if (newDate.year != _centerDate.year ||
        newDate.month != _centerDate.month ||
        newDate.day != _centerDate.day) {
      setState(() {
        _centerDate = newDate;
        _loadAppointments();
      });
    }
  }

  void _loadAppointments() async {
    // Determine the new date range
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

    // Check if the new date range overlaps with the cached range
    if (_cachedStartDate != null &&
        _cachedEndDate != null &&
        startDate.isBefore(_cachedEndDate!) &&
        endDate.isAfter(_cachedStartDate!)) {
      // Use cached data if overlapping
      setState(() {
        _appointments = _cachedAppointments;
        _isLoading = false; // Set loading to false when using cached data
      });
    } else {
      // Fetch from the server
      setState(() {
        _isLoading = true; // Start loading
      });

      final logger = Logger();
      final apptRepository = AppointmentRepository();
      logger.log(Level.INFO,
          "attempting to fetch appointments from $startDate to $endDate");
      final appointments =
          await apptRepository.getAppointmentItemsInRange(startDate, endDate);

      setState(() {
        _appointments = appointments;
        _cachedStartDate = startDate;
        _cachedEndDate = endDate;
        _cachedAppointments = appointments;
        _isLoading = false; // Stop loading
        logger.log(Level.INFO, "loaded ${_appointments.length} appointments");
      });
    }
  }

  // Method to handle refresh
  void _refreshAppointments() {
    setState(() {
      // Clear cached data
      _cachedStartDate = null;
      _cachedEndDate = null;
      _cachedAppointments = [];
      _appointments = []; // Clear current appointments
      _isLoading = true; // Start loading indicator
    });
    _loadAppointments();
    // Force the SchedulerNavigationPanel to refresh
    print('attempting to refresh navigation panel');
    _navigationPanelKey.currentState?.refresh();
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
    _overlayManager.clearCurrentOverlay();
    return Row(
      children: [
        // Vertical panel on the left
        if (_showNavigation)
          SchedulerNavigationPanel(
            key: _navigationPanelKey,
            isVisible: _showNavigation,
            centerDate: _centerDate,
            onDateChanged: _onDateChanged,
            selectedDates: _getSelectedDates(),
          ),
        Expanded(
          child: Stack(
            children: [
              ScaffoldPage(
                header: SchedulerCarousel(
                  onViewModeChange: _handleViewModeChange,
                  selectedViewMode: _viewMode,
                  onViewTypeChange: _handleViewTypeChange,
                  isMultiple: _isMultiple,
                  onShowNavigationChange: _handleShowNavigationChange,
                  showNavigation: _showNavigation,
                  onRefresh: _refreshAppointments, // Pass refresh callback here
                ),
                content: _isLoading
                    ? Center(
                        child: SizedBox(
                          width: 100, // Set the width as per your requirement
                          height: 100, // Set the height as per your requirement
                          child: mat.CircularProgressIndicator(
                            strokeWidth: 8,
                          ),
                        ),
                      )
                    : Scheduler(
                        viewMode: _viewMode,
                        isMultiple: _isMultiple,
                        centerDate: _centerDate,
                        onDateChanged: _onDateChanged,
                        onRefresh: _refreshAppointments,
                        appointments: _appointments,
                        overlayManager: _overlayManager,
                        onEditAppointment:
                            _onEditAppointment, // Pass the callback
                        // Additional parameters
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onEditAppointment(int appointmentId) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _overlayManager.showEditAppointmentDialog(
            context, appointmentId, _refreshAppointments);
      }
    });
  }
}
