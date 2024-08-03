// import 'dart:io' show Platform;
// import 'package:fluent_ui/fluent_ui.dart' if (Platform.isAndroid || Platform.isIOS) 'package:flutter/material.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'scheduler.dart';

class SchedulerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: Text('Scheduler'),
      ),
      content: SchedulingControl(isFlyoutVisible: false),
    );
  }
}
