import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ThemedIcon extends StatelessWidget {
  final String svgPath;
  final double size; // New parameter for size

  const ThemedIcon({
    Key? key,
    required this.svgPath,
    this.size = 24.0, // Default value if size is not provided
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color =
        theme.brightness == Brightness.dark ? Colors.white : Colors.black;

    return SvgPicture.asset(
      svgPath,
      color: color,
      height: size, // Use the size parameter
      width: size, // Use the size parameter
    );
  }
}
