import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat
    show Colors, FloatingActionButton, CircleBorder;
import '../widgets/scheduler/scheduler.dart';
import '../widgets/scheduler/scheduler_controls.dart'; // Import the SchedulerControls widget
import '../widgets/patient_finder.dart'; // Import the PatientFinder widget

class SchedulerScreen extends StatefulWidget {
  @override
  _SchedulerScreenState createState() => _SchedulerScreenState();
}

class _SchedulerScreenState extends State<SchedulerScreen> {
  bool _isFlyoutVisible = false;
  String _viewMode = 'Day'; // Default view mode
  bool _isMultiple = false; // Default view type

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

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Stack(
      children: [
        ScaffoldPage(
          header: PageHeader(
            title: SchedulerControls(
              onViewModeChange: _handleViewModeChange,
              selectedViewMode: _viewMode,
              onViewTypeChange: _handleViewTypeChange,
              isMultiple: _isMultiple,
            ),
          ),
          content: Scheduler(
            viewMode: _viewMode,
            isMultiple: _isMultiple,
            // You can pass additional parameters here if needed
          ),
        ),
        if (isDesktop) _buildDesktopFlyout(),
        if (!isDesktop) _buildMobileFlyout(),
        _buildFloatingActionButton(isDesktop),
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
