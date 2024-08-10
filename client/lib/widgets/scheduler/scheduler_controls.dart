import 'package:fluent_ui/fluent_ui.dart';
import 'filter_dialog.dart';
import 'view_mode_button.dart'; // Import the new file

class SchedulerControls extends StatefulWidget {
  final void Function(String viewMode) onViewModeChange;
  final String selectedViewMode;
  final void Function(bool isMultiple) onViewTypeChange;
  final bool isMultiple;
  final void Function(bool showNavigation) onShowNavigationChange;
  final bool showNavigation;
  final void Function() onRefresh; // Add this line

  const SchedulerControls({
    Key? key,
    required this.onViewModeChange,
    required this.selectedViewMode,
    required this.onViewTypeChange,
    required this.isMultiple,
    required this.onShowNavigationChange,
    required this.showNavigation,
    required this.onRefresh, // Add this line
  }) : super(key: key);

  @override
  _SchedulerControlsState createState() => _SchedulerControlsState();
}

class _SchedulerControlsState extends State<SchedulerControls> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bodyTextStyle = FluentTheme.of(context).typography.body;

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true, // Show scrollbar when needed
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        controller: _scrollController,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // View Mode Buttons (reversed order)
            ViewModeButton(
              viewMode: 'Month',
              icon: FluentIcons.calendar,
              text: 'Month View',
              isSelected: widget.selectedViewMode == 'Month',
              onTap: () => widget.onViewModeChange('Month'),
            ),
            SizedBox(width: 8),
            ViewModeButton(
              viewMode: 'Week',
              icon: FluentIcons.calendar_week,
              text: 'Week View',
              isSelected: widget.selectedViewMode == 'Week',
              onTap: () => widget.onViewModeChange('Week'),
            ),
            SizedBox(width: 8),
            ViewModeButton(
              viewMode: '5-Day',
              icon: FluentIcons.calendar_work_week,
              text: '5-Day View',
              isSelected: widget.selectedViewMode == '5-Day',
              onTap: () => widget.onViewModeChange('5-Day'),
            ),
            SizedBox(width: 8),
            ViewModeButton(
              viewMode: 'Day',
              icon: FluentIcons.calendar_day,
              text: 'Day View',
              isSelected: widget.selectedViewMode == 'Day',
              onTap: () => widget.onViewModeChange('Day'),
            ),
            SizedBox(width: 16),
            // View Type Toggle with adjusted size
            SizedBox(
              height: 24, // Adjusted height to make it smaller
              child: ToggleSwitch(
                onChanged: widget.onViewTypeChange,
                checked: widget.isMultiple,
                content: Text(
                  widget.isMultiple ? 'Multiple' : 'Single',
                  style: FluentTheme.of(context)
                      .typography
                      .body
                      ?.copyWith(fontSize: 12), // Adjust font size
                ),
              ),
            ),
            SizedBox(width: 16),
            SizedBox(
              height: 24, // Adjusted height to make it smaller
              child: ToggleSwitch(
                onChanged: widget.onShowNavigationChange,
                checked: widget.showNavigation,
                content: Text(
                  'Navigation',
                  style: FluentTheme.of(context)
                      .typography
                      .body
                      ?.copyWith(fontSize: 12), // Adjust font size
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(FluentIcons.filter, size: 14),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => FilterDialog(),
              ), // Call the refresh callback
            ), // Updated method
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(FluentIcons.refresh, size: 14),
              onPressed: widget.onRefresh, // Call the refresh callback
            ) // Updated method
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {},
      onExit: (_) {},
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => FilterDialog(),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: FluentTheme.of(context).accentColor,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(FluentIcons.filter,
                  size: 20, color: FluentTheme.of(context).accentColor),
              SizedBox(width: 8),
              Text(
                'Filter',
                style: FluentTheme.of(context).typography.body?.copyWith(
                          color: FluentTheme.of(context).accentColor,
                        ) ??
                    TextStyle(color: FluentTheme.of(context).accentColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
