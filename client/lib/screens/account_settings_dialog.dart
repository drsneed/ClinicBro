import 'dart:typed_data';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:image_picker/image_picker.dart';
import '../managers/user_manager.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import 'dart:io'; // For File
import 'package:flutter/material.dart'
    show CircularProgressIndicator, ScaffoldMessenger, SnackBar, Theme;
import 'package:image/image.dart' as img;

class AccountSettingsDialog extends StatefulWidget {
  final VoidCallback onAvatarChanged; // Callback to refresh avatar

  const AccountSettingsDialog({Key? key, required this.onAvatarChanged})
      : super(key: key);

  @override
  _AccountSettingsDialogState createState() => _AccountSettingsDialogState();
}

class _AccountSettingsDialogState extends State<AccountSettingsDialog> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final reenterNewPasswordController = TextEditingController();

  Future<void> _handleChangePassword() async {
    final oldPassword = oldPasswordController.text;
    final newPassword = newPasswordController.text;
    final reenteredPassword = reenterNewPasswordController.text;

    if (newPassword != reenteredPassword) {
      showDialog(
        context: context,
        builder: (BuildContext context) => ContentDialog(
          title: Text('Error'),
          content: Text('New passwords do not match.'),
          actions: [
            Button(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
      return;
    }

    final success =
        await UserRepository().changePassword(oldPassword, newPassword);

    if (success) {
      try {
        await AuthService().resetToken(newPassword);
      } catch (e) {
        showDialog(
          context: context,
          builder: (BuildContext context) => ContentDialog(
            title: Text('Error'),
            content: Text('Failed to reset token.'),
            actions: [
              Button(
                child: Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
        return;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) => ContentDialog(
          title: Text('Success'),
          content: Text('Password changed successfully.'),
          actions: [
            Button(
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );

      oldPasswordController.clear();
      newPasswordController.clear();
      reenterNewPasswordController.clear();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => ContentDialog(
          title: Text('Error'),
          content: Text('Failed to change password.'),
          actions: [
            Button(
              child: Text('OK'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _handleEditAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final userId = UserManager().currentUser?.id;

      if (userId != null) {
        final imageData = await file.readAsBytes();
        img.Image? image = img.decodeImage(imageData);

        if (image != null) {
          img.Image resizedImage =
              img.copyResize(image, width: 100, height: 100);
          final resizedImageData = img.encodePng(resizedImage);

          final success = await UserRepository()
              .createOrUpdateAvatar(userId, resizedImageData);

          if (success) {
            widget.onAvatarChanged(); // Refresh the avatar in the parent
            setState(() {}); // Refresh the dialog state
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Failed to update profile picture')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to decode image')),
          );
        }
      }
    }
  }

  Future<Uint8List?> _loadAvatarImage() async {
    try {
      final userId = UserManager().currentUser?.id;
      final bytes = await UserRepository().getAvatar(userId ?? 0);
      return bytes;
    } catch (e) {
      print('Error loading avatar: $e');
      return null;
    }
  }

  Widget _buildAvatarDisplay() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define fallback colors
    final placeholderColor = isDarkMode
        ? Color(0xFF424242)
        : Color(0xFFF0F0F0); // Non-null fallback colors

    return FutureBuilder<Uint8List?>(
      future: _loadAvatarImage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          final avatarData = snapshot.data;
          if (avatarData != null) {
            return CircleAvatar(
              backgroundImage: MemoryImage(avatarData),
              radius: 50,
            );
          } else {
            // Data is null, show placeholder
            return Container(
              width: 100,
              height: 100,
              color: placeholderColor, // Use fallback color
              child: const Icon(FluentIcons.contact, size: 50),
            );
          }
        } else {
          // Handle unexpected case where neither hasData nor hasError
          return Container(
            width: 100,
            height: 100,
            color: placeholderColor,
            child: const Icon(FluentIcons.contact, size: 50),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final dialogWidth = screenSize.width * (screenSize.width > 600 ? 0.5 : 0.9);

    return ContentDialog(
      constraints: BoxConstraints(
        maxWidth: dialogWidth,
        maxHeight: screenSize.height * 0.8,
      ),
      title: Text('Account Settings'),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expander(
                header: _buildSettingsOption(
                  icon: FluentIcons.diamond_user,
                  label: 'User Profile',
                ),
                content: _buildUserProfileSection(context, _handleEditAvatar),
              ),
              Expander(
                header: _buildSettingsOption(
                  icon: FluentIcons.lock,
                  label: 'Security',
                ),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Change Password'),
                    _buildTextBoxRow('Old Password',
                        isPassword: true, controller: oldPasswordController),
                    _buildTextBoxRow('New Password',
                        isPassword: true, controller: newPasswordController),
                    _buildTextBoxRow('Re-enter New Password',
                        isPassword: true,
                        controller: reenterNewPasswordController),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Button(
                        onPressed: _handleChangePassword,
                        child: const Text('Submit'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 60.0),
            child: Button(
              child: const Text('Close'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsOption({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: <Widget>[
        Icon(icon),
        const SizedBox(width: 10),
        Text(label),
      ],
    );
  }

  Widget _buildTextBoxRow(String label,
      {bool isPassword = false, required TextEditingController controller}) {
    const labelWidth = 150.0;
    const spacing = 16.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text('$label: '),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: TextBox(
              obscureText: isPassword,
              controller: controller,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileSection(
      BuildContext context, Future<void> Function() onEditAvatar) {
    final user = UserManager().currentUser;
    final userName = user?.name ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildReadOnlyTextBox('Name', userName),
        const SizedBox(height: 16),
        _buildProfilePictureSection(context, onEditAvatar),
      ],
    );
  }

  Widget _buildReadOnlyTextBox(String label, String value) {
    const labelWidth = 150.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text('$label: '),
          ),
          Expanded(
            child: TextBox(
              readOnly: true,
              controller: TextEditingController(text: value),
              placeholder: 'N/A',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 150.0,
          child: Text('Color: '),
        ),
        SizedBox(width: 16.0),
        Container(
          width: 30,
          height: 30,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildProfilePictureSection(
      BuildContext context, Future<void> Function() onEditAvatar) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 150.0,
          child: Text('Profile Picture: '),
        ),
        const SizedBox(width: 16.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatarDisplay(),
              SizedBox(height: 10),
              Button(
                child: Text('Change'),
                onPressed: onEditAvatar,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
