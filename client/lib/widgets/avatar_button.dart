import 'package:flutter/material.dart';
import 'authenticated_image_provider.dart';
import 'package:fluent_ui/fluent_ui.dart' show Button, ContentDialog;

class AvatarButton extends StatelessWidget {
  final VoidCallback onAccountSettings;
  final VoidCallback onSignOut;

  const AvatarButton({
    Key? key,
    required this.onAccountSettings,
    required this.onSignOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the current theme brightness
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Set background color based on the theme mode
    final menuBackgroundColor = isDarkMode ? Colors.grey[850] : Colors.white;

    return Material(
      color: Colors.transparent, // Makes sure the background is transparent
      child: PopupMenuTheme(
        data: PopupMenuThemeData(
          color: menuBackgroundColor, // Use the determined color
        ),
        child: PopupMenuButton<String>(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: CircleAvatar(
              backgroundImage: AuthenticatedImageProvider(),
              radius: 12,
            ),
          ),
          onSelected: (String result) {
            if (result == 'account_settings') {
              onAccountSettings();
            } else if (result == 'sign_out') {
              _confirmSignOut(context); // Show confirmation dialog
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'account_settings',
              child: Row(
                children: <Widget>[
                  Icon(Icons.account_circle), // Icon for account settings
                  SizedBox(width: 8), // Space between icon and text
                  Text('Account Settings'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'sign_out',
              child: Row(
                children: <Widget>[
                  Icon(Icons.exit_to_app), // Icon for sign out
                  SizedBox(width: 8), // Space between icon and text
                  Text('Sign Out'),
                ],
              ),
            ),
          ],
          offset: Offset(0, 50), // Adjust the vertical offset as needed
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ContentDialog(
          title: Text('Confirm Sign Out'),
          content: Text('Are you sure you want to sign out?'),
          actions: <Widget>[
            Button(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            Button(
              child: Text('Sign Out'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                onSignOut(); // Execute the sign-out process
              },
            ),
          ],
        );
      },
    );
  }
}
