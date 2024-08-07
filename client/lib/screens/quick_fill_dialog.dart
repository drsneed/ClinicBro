import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' show TimeOfDay;
import '../widgets/custom_time_picker.dart';

class QuickFillDialog extends StatefulWidget {
  final Function(List<bool>, TimeOfDay, TimeOfDay) onFill;

  const QuickFillDialog({Key? key, required this.onFill}) : super(key: key);

  @override
  _QuickFillDialogState createState() => _QuickFillDialogState();
}

class _QuickFillDialogState extends State<QuickFillDialog> {
  final List<String> _dayLetters = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  late List<bool> _selectedDays;
  TimeOfDay _startTime = TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _endTime = TimeOfDay(hour: 17, minute: 0);

  @override
  void initState() {
    super.initState();
    _selectedDays = List.generate(7, (index) => index > 0 && index < 6);
  }

  @override
  Widget build(BuildContext context) {
    return ContentDialog(
      title: Text('Quick Fill'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(_dayLetters.length, (index) {
              return Checkbox(
                checked: _selectedDays[index],
                onChanged: (value) {
                  setState(() {
                    _selectedDays[index] = value ?? false;
                  });
                },
                content: Text(_dayLetters[index]),
              );
            }),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: CustomTimePicker(
                  header: 'Start Time',
                  selected:
                      DateTime(2024, 1, 1, _startTime.hour, _startTime.minute),
                  onChanged: (newTime) {
                    if (newTime != null) {
                      setState(() {
                        _startTime = TimeOfDay(
                            hour: newTime.hour, minute: newTime.minute);
                      });
                    }
                  },
                  minuteIncrement: 15,
                  hourFormat: HourFormat.h,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: CustomTimePicker(
                  header: 'End Time',
                  selected:
                      DateTime(2024, 1, 1, _endTime.hour, _endTime.minute),
                  onChanged: (newTime) {
                    if (newTime != null) {
                      setState(() {
                        _endTime = TimeOfDay(
                            hour: newTime.hour, minute: newTime.minute);
                      });
                    }
                  },
                  minuteIncrement: 15,
                  hourFormat: HourFormat.h,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Button(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        FilledButton(
          child: Text('Fill'),
          onPressed: () {
            widget.onFill(_selectedDays, _startTime, _endTime);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
