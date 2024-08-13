import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ThemedIcon extends StatelessWidget {
  final String svgPath;
  final double size; // New parameter for size
  final Color? color;
  ThemedIcon({
    Key? key,
    required this.svgPath,
    this.size = 24.0,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      svgPath,
      color: color ?? FluentTheme.of(context).inactiveColor.withOpacity(0.8),
      height: size, // Use the size parameter
      width: size, // Use the size parameter
    );
  }
}
