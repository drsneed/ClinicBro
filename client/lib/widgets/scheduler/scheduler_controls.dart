import 'package:fluent_ui/fluent_ui.dart';
import 'filter_dialog.dart';
import 'view_mode_button.dart'; // Import the new file

class SchedulerControls extends StatelessWidget {
  final void Function(String viewMode) onViewModeChange;
  final String selectedViewMode;
  final void Function(bool isMultiple) onViewTypeChange;
  final bool isMultiple;

  const SchedulerControls({
    Key? key,
    required this.onViewModeChange,
    required this.selectedViewMode,
    required this.onViewTypeChange,
    required this.isMultiple,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bodyTextStyle = FluentTheme.of(context).typography.body;

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // View Mode Buttons
        ViewModeButton(
          viewMode: 'Day',
          icon: FluentIcons.calendar_day,
          text: 'Day View',
          isSelected: selectedViewMode == 'Day',
          onTap: () => onViewModeChange('Day'),
        ),
        SizedBox(width: 8),
        ViewModeButton(
          viewMode: '5-Day',
          icon: FluentIcons.calendar_work_week,
          text: '5-Day View',
          isSelected: selectedViewMode == '5-Day',
          onTap: () => onViewModeChange('5-Day'),
        ),
        SizedBox(width: 8),
        ViewModeButton(
          viewMode: 'Week',
          icon: FluentIcons.calendar_week,
          text: 'Week View',
          isSelected: selectedViewMode == 'Week',
          onTap: () => onViewModeChange('Week'),
        ),
        SizedBox(width: 8),
        ViewModeButton(
          viewMode: 'Month',
          icon: FluentIcons.calendar,
          text: 'Month View',
          isSelected: selectedViewMode == 'Month',
          onTap: () => onViewModeChange('Month'),
        ),
        SizedBox(width: 16),
        // View Type Toggle with adjusted size
        SizedBox(
          height: 24, // Adjusted height to make it smaller
          child: ToggleSwitch(
            onChanged: onViewTypeChange,
            checked: isMultiple,
            content: Text(
              isMultiple ? 'Multiple' : 'Single',
              style: FluentTheme.of(context)
                  .typography
                  .body
                  ?.copyWith(fontSize: 12), // Adjust font size
            ),
          ),
        ),
        SizedBox(width: 16),
        _buildFilterButton(context),
      ],
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
            color: FluentTheme.of(context).inactiveBackgroundColor,
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
