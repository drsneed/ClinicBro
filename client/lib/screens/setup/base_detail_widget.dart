import 'package:fluent_ui/fluent_ui.dart';

abstract class BaseDetailWidget extends StatefulWidget {
  const BaseDetailWidget({Key? key}) : super(key: key);

  BaseDetailWidgetState createState();
}

abstract class BaseDetailWidgetState<T extends BaseDetailWidget>
    extends State<T> {
  Future<Object?> save();
}
