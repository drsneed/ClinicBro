import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart' as internal;

typedef Level = internal.Level;

class Logger {
  static final Logger _instance = Logger._internal();
  factory Logger() => _instance;
  Logger._internal();

  final internal.Logger _logger = internal.Logger('ClinicBro');

  void init() {
    internal.Logger.root.level = internal.Level.ALL;
    internal.Logger.root.onRecord.listen((record) {
      if (kDebugMode) {
        print('${record.level.name}: ${record.time}: ${record.message}');
      }
    });
  }

  void log(Level level, String message) {
    _logger.log(level, message);
  }
}
