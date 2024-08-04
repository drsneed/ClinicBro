import 'package:flutter/material.dart';
import 'authenticated_image_provider.dart';

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
    return Material(
      color: Colors.transparent, // Makes sure the background is transparent
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
            onSignOut();
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'account_settings',
            child: Text('Account Settings'),
          ),
          const PopupMenuItem<String>(
            value: 'sign_out',
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
