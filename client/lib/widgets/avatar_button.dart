import 'dart:typed_data';
import 'package:flutter/material.dart'
    show
        State,
        StatefulWidget,
        VoidCallback,
        Key,
        Widget,
        BuildContext,
        Theme,
        Brightness,
        Color,
        Colors,
        Material,
        PopupMenuButton,
        PopupMenuTheme,
        PopupMenuThemeData,
        Padding,
        EdgeInsets,
        MemoryImage,
        CircleAvatar,
        Icon,
        FutureBuilder,
        ConnectionState,
        PopupMenuItem,
        PopupMenuEntry,
        Row,
        Icons,
        SizedBox,
        Text,
        Offset,
        showDialog,
        Navigator,
        BoxDecoration,
        Container,
        BoxShape,
        BorderRadius;

import 'package:fluent_ui/fluent_ui.dart'
    show Button, FilledButton, ContentDialog, FluentIcons;
import 'dart:ui' as ui;
import '../repositories/user_repository.dart';
import '../managers/user_manager.dart';

class AvatarButton extends StatefulWidget {
  final VoidCallback onAccountSettings;
  final VoidCallback onSignOut;

  const AvatarButton({
    Key? key,
    required this.onAccountSettings,
    required this.onSignOut,
  }) : super(key: key);

  @override
  AvatarButtonState createState() => AvatarButtonState();
}

class AvatarButtonState extends State<AvatarButton> {
  Future<Uint8List?>? _avatarFuture;

  @override
  void initState() {
    super.initState();
    _loadAvatar(); // Load avatar image initially
  }

  // Method to load avatar image
  void _loadAvatar() {
    setState(() {
      _avatarFuture = _fetchAvatarImage();
    });
  }

  // Fetch avatar image from repository
  Future<Uint8List?> _fetchAvatarImage() async {
    try {
      final userId = UserManager().currentUser?.id;
      final bytes = await UserRepository().getAvatar(userId ?? 0);
      return bytes;
    } catch (e) {
      print('Error loading avatar: $e');
      return null;
    }
  }

  // Public method to refresh the avatar
  void refreshAvatar() {
    _loadAvatar();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final menuBackgroundColor = isDarkMode ? Colors.grey[850] : Colors.white;
    final borderColor = isDarkMode
        ? const Color.fromARGB(255, 185, 184, 184)
        : const Color.fromARGB(255, 2, 91, 164);

    return Material(
      color: Colors.transparent,
      child: PopupMenuTheme(
        data: PopupMenuThemeData(
          color: menuBackgroundColor,
        ),
        child: PopupMenuButton<String>(
          onSelected: (String result) {
            if (result == 'account_settings') {
              widget.onAccountSettings();
            } else if (result == 'sign_out') {
              _confirmSignOut(context);
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'account_settings',
              child: Row(
                children: <Widget>[
                  Icon(Icons.account_circle),
                  SizedBox(width: 8),
                  Text('Account Settings'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'sign_out',
              child: Row(
                children: <Widget>[
                  Icon(Icons.exit_to_app),
                  SizedBox(width: 8),
                  Text('Sign Out'),
                ],
              ),
            ),
          ],
          offset: Offset(0, 50),
          child: FutureBuilder<Uint8List?>(
            future: _avatarFuture,
            builder: (context, snapshot) {
              Widget avatarWidget;
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData && snapshot.data != null) {
                  avatarWidget = CircleAvatar(
                    backgroundImage: MemoryImage(snapshot.data!),
                    radius: 12,
                  );
                } else {
                  avatarWidget = const CircleAvatar(
                    radius: 12,
                    child: Icon(FluentIcons.contact, size: 14),
                  );
                }
              } else {
                avatarWidget = const CircleAvatar(
                  radius: 12,
                  child: Icon(FluentIcons.contact, size: 14),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: borderColor,
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(0.5), // Border width
                child: avatarWidget,
              );
            },
          ),
        ),
      ),
    );
  }

  // Confirm sign-out action
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
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              child: Text('Sign Out'),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onSignOut();
              },
            ),
          ],
        );
      },
    );
  }
}
