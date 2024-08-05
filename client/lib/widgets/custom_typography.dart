import 'package:fluent_ui/fluent_ui.dart';

class CustomTypography {
  static Typography getTypography({Brightness? brightness}) {
    final color = brightness == Brightness.light
        ? const Color(0xE4000000) // Dark color for light mode
        : Colors.white; // White color for dark mode

    return Typography.raw(
      display: TextStyle(
        fontFamily: 'Inter Thin',
        fontSize: 68,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Inter Thin',
        fontSize: 40,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      title: TextStyle(
        fontFamily: 'Inter Thin',
        fontSize: 28,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      subtitle: TextStyle(
        fontFamily: 'Inter Thin',
        fontSize: 20,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter Thin',
        fontSize: 18,
        color: color,
        fontWeight: FontWeight.normal,
      ),
      bodyStrong: TextStyle(
        fontFamily: 'Inter Thin',
        fontSize: 14,
        color: color,
        fontWeight: FontWeight.w600,
      ),
      body: TextStyle(
        fontFamily: 'Inter Thin',
        fontSize: 14,
        color: color,
        fontWeight: FontWeight.normal,
      ),
      caption: TextStyle(
        fontFamily: 'Inter Thin',
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.normal,
      ),
    );
  }
}
