import 'package:fluent_ui/fluent_ui.dart';

class ViewModeButton extends StatefulWidget {
  final String viewMode;
  final IconData icon;
  final String text;
  final bool isSelected;
  final void Function() onTap;

  const ViewModeButton({
    Key? key,
    required this.viewMode,
    required this.icon,
    required this.text,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  _ViewModeButtonState createState() => _ViewModeButtonState();
}

class _ViewModeButtonState extends State<ViewModeButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? FluentTheme.of(context).accentColor
                : _isHovered
                    ? FluentTheme.of(context).accentColor.withOpacity(0.2)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isSelected
                  ? FluentTheme.of(context).accentColor
                  : Colors
                      .transparent, // Make border transparent when not selected
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: widget.isSelected
                    ? Colors.white
                    : FluentTheme.of(context).inactiveColor,
              ),
              SizedBox(width: 8),
              Text(
                widget.text,
                style: FluentTheme.of(context).typography.body?.copyWith(
                          color: widget.isSelected
                              ? Colors.white
                              : FluentTheme.of(context).inactiveColor,
                        ) ??
                    TextStyle(
                        color: FluentTheme.of(context)
                            .accentColor), // Fallback to theme color if null
              ),
            ],
          ),
        ),
      ),
    );
  }
}
