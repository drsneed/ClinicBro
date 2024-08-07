import 'dart:typed_data';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:image_picker/image_picker.dart';
import '../managers/user_manager.dart';
import '../models/location.dart';
import '../models/operating_schedule.dart';
import '../repositories/location_repository.dart';
import '../repositories/operating_schedule_repository.dart';
import '../repositories/user_repository.dart';
import '../services/auth_service.dart';
import 'dart:io'; // For File
import 'package:flutter/material.dart'
    show
        CircularProgressIndicator,
        ScaffoldMessenger,
        SnackBar,
        Theme,
        TimeOfDay;
import 'package:image/image.dart' as img;

import '../widgets/custom_time_picker.dart';
import 'quick_fill_dialog.dart';

class AccountSettingsDialog extends StatefulWidget {
  final VoidCallback onAvatarChanged; // Callback to refresh avatar

  const AccountSettingsDialog({super.key, required this.onAvatarChanged});

  @override
  _AccountSettingsDialogState createState() => _AccountSettingsDialogState();
}

class _AccountSettingsDialogState extends State<AccountSettingsDialog> {
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final reenterNewPasswordController = TextEditingController();
  String? selectedLocation;
  List<Location> _locations = [];
  bool _isLoading = true;
  Uint8List? _cachedAvatarData; // Cached avatar data
  bool _loadedAvatar = false;
  OperatingSchedule? _currentOperatingSchedule;
  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Map<String, Map<String, DateTime?>> workHours = {
    'Monday': {'Start': null, 'End': null},
    'Tuesday': {'Start': null, 'End': null},
    'Wednesday': {'Start': null, 'End': null},
    'Thursday': {'Start': null, 'End': null},
    'Friday': {'Start': null, 'End': null},
    'Saturday': {'Start': null, 'End': null},
    'Sunday': {'Start': null, 'End': null},
  };

  Future<void> _handleSaveWorkHours() async {
    final locationId =
        _locations.firstWhere((loc) => loc.name == selectedLocation).id;
    final userId = UserManager().currentUser?.id;

    if (userId == null) {
      _showInfoBar('User ID is not available.',
          severity: InfoBarSeverity.error);
      return;
    }

    // Create the new schedule
    final updatedSchedule = OperatingSchedule(
      locationId: locationId,
      userId: userId,
      hoursSunFrom: _dateTimeToTimeOfDay(workHours['Sunday']?['Start']),
      hoursSunTo: _dateTimeToTimeOfDay(workHours['Sunday']?['End']),
      hoursMonFrom: _dateTimeToTimeOfDay(workHours['Monday']?['Start']),
      hoursMonTo: _dateTimeToTimeOfDay(workHours['Monday']?['End']),
      hoursTueFrom: _dateTimeToTimeOfDay(workHours['Tuesday']?['Start']),
      hoursTueTo: _dateTimeToTimeOfDay(workHours['Tuesday']?['End']),
      hoursWedFrom: _dateTimeToTimeOfDay(workHours['Wednesday']?['Start']),
      hoursWedTo: _dateTimeToTimeOfDay(workHours['Wednesday']?['End']),
      hoursThuFrom: _dateTimeToTimeOfDay(workHours['Thursday']?['Start']),
      hoursThuTo: _dateTimeToTimeOfDay(workHours['Thursday']?['End']),
      hoursFriFrom: _dateTimeToTimeOfDay(workHours['Friday']?['Start']),
      hoursFriTo: _dateTimeToTimeOfDay(workHours['Friday']?['End']),
      hoursSatFrom: _dateTimeToTimeOfDay(workHours['Saturday']?['Start']),
      hoursSatTo: _dateTimeToTimeOfDay(workHours['Saturday']?['End']),
      dateCreated: DateTime.now(),
      dateUpdated: DateTime.now(),
    );
    bool success;
    if (_currentOperatingSchedule == null) {
      // Create a new schedule if current schedule is null
      _currentOperatingSchedule = await OperatingScheduleRepository()
          .createOperatingSchedule(updatedSchedule);
      success = _currentOperatingSchedule != null;
    } else {
      // Update existing schedule
      OperatingSchedule? updatedScheduleWithId = updatedSchedule.copyWith(
          locationId: _currentOperatingSchedule!.locationId,
          userId: _currentOperatingSchedule!.userId);
      updatedScheduleWithId = await OperatingScheduleRepository()
          .updateOperatingSchedule(updatedScheduleWithId);
      success = updatedScheduleWithId != null;
    }

    if (success) {
      _showInfoBar('Work hours saved successfully.');
    } else {
      _showInfoBar('Failed to save work hours.',
          severity: InfoBarSeverity.error);
    }
  }

  TimeOfDay? _dateTimeToTimeOfDay(DateTime? dateTime) {
    if (dateTime == null) return null;
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  void _showQuickFillDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => QuickFillDialog(
        onFill:
            (List<bool> selectedDays, TimeOfDay startTime, TimeOfDay endTime) {
          setState(() {
            final daysOfWeek = [
              'Sunday',
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday'
            ];

            for (int i = 0; i < daysOfWeek.length; i++) {
              if (selectedDays[i]) {
                workHours[daysOfWeek[i]] = {
                  'Start':
                      DateTime(2024, 1, 1, startTime.hour, startTime.minute),
                  'End': DateTime(2024, 1, 1, endTime.hour, endTime.minute),
                };
              } else {
                // Clear the hours for unchecked days
                workHours[daysOfWeek[i]] = {'Start': null, 'End': null};
              }
            }
          });
        },
      ),
    );
  }

  Widget _buildLocationAndButtons() {
    const double buttonHeight = 34.0;

    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 8,
      runSpacing: 8,
      children: [
        SizedBox(
          width: 300,
          height: buttonHeight,
          child: _buildLocationComboBox(),
        ),
        SizedBox(
          height: buttonHeight,
          child: Button(
            onPressed: _showQuickFillDialog,
            child: const Text('Quick Fill'),
          ),
        ),
        SizedBox(
          height: buttonHeight,
          child: Button(
            onPressed: _clearAllWorkHours,
            child: const Text('Clear All'),
          ),
        ),
      ],
    );
  }

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

  void _showInfoBar(String message,
      {InfoBarSeverity severity = InfoBarSeverity.info}) {
    displayInfoBar(
      context,
      builder: (context, close) {
        return InfoBar(
          title: Text(message),
          severity: severity,
          onClose: close,
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
            setState(() {
              _cachedAvatarData = null; // Invalidate cache to reload the avatar
              _loadedAvatar = false; // Allow new GET request to server
            });
          } else {
            _showInfoBar('Failed to update profile picture',
                severity: InfoBarSeverity.error);
          }
        } else {
          _showInfoBar('Failed to decode image',
              severity: InfoBarSeverity.error);
        }
      }
    }
  }

  Future<Uint8List?> _loadAvatarImage() async {
    if (_cachedAvatarData != null || _loadedAvatar) {
      return _cachedAvatarData; // Return cached data if available
    }

    try {
      _loadedAvatar = true;
      final userId = UserManager().currentUser?.id;
      final bytes = await UserRepository().getAvatar(userId ?? 0);
      setState(() {
        _cachedAvatarData = bytes; // Cache the data
      });
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
                  icon: FluentIcons.calendar,
                  label: 'Work Hours',
                ),
                content: _buildWorkHoursSection(),
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
            constraints: const BoxConstraints(maxWidth: 80.0),
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

  // Method to clear all work hours
  void _clearAllWorkHours() {
    setState(() {
      workHours = {
        'Sunday': {'Start': null, 'End': null},
        'Monday': {'Start': null, 'End': null},
        'Tuesday': {'Start': null, 'End': null},
        'Wednesday': {'Start': null, 'End': null},
        'Thursday': {'Start': null, 'End': null},
        'Friday': {'Start': null, 'End': null},
        'Saturday': {'Start': null, 'End': null},
      };
    });
  }

// Update to _buildWorkHoursSection method
  Widget _buildWorkHoursSection() {
    if (_isLoading) {
      return Center(child: ProgressRing());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLocationAndButtons(),
        const SizedBox(height: 16),
        _buildWeeklySchedule(),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.bottomRight,
          child: Button(
            onPressed: _handleSaveWorkHours,
            child: const Text('Save'),
          ),
        ),
      ],
    );
  }

  void _fillDefaultWorkHours() {
    setState(() {
      // Set work hours for Monday to Friday
      final startOfDay = DateTime(2024, 1, 1, 9, 0);
      final endOfDay = DateTime(2024, 1, 1, 17, 0);
      final daysOfWeek = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday'
      ];

      for (final day in daysOfWeek) {
        workHours[day] = {'Start': startOfDay, 'End': endOfDay};
      }

      // Set work hours for Saturday and Sunday to null
      workHours['Saturday'] = {'Start': null, 'End': null};
      workHours['Sunday'] = {'Start': null, 'End': null};
    });
  }

  Future<void> _loadOperatingScheduleForSelectedLocation() async {
    if (selectedLocation != null) {
      final selectedLocationId =
          _locations.firstWhere((loc) => loc.name == selectedLocation).id;
      final schedule =
          await UserRepository().getOperatingSchedule(selectedLocationId);
      if (schedule != null) {
        setState(() {
          _currentOperatingSchedule = schedule;
          _updateWorkHoursFromSchedule(schedule);
        });
      }
    }
  }

  Future<void> _fetchLocations() async {
    final locationRepository = LocationRepository();
    final locations =
        await locationRepository.getAllLocations(includeInactive: false);
    setState(() {
      _locations = locations;
      if (_locations.isNotEmpty) {
        selectedLocation = _locations.first.name;
        _loadOperatingScheduleForSelectedLocation(); // Load schedule for the first location
      }
      _isLoading = false;
    });
  }

  Widget _buildLocationComboBox() {
    if (_locations.isEmpty) {
      return Center(child: Text('No locations found.'));
    }
    return Row(
      children: [
        Text('Location:'),
        SizedBox(width: 8),
        Expanded(
          child: ComboBox<String>(
            placeholder: Text('Select a location'),
            isExpanded: true,
            items: _locations
                .map((Location location) => ComboBoxItem<String>(
                      value: location.name,
                      child: Text(
                        location.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (String? newLocation) async {
              setState(() {
                selectedLocation = newLocation;
              });

              if (newLocation != null) {
                final selectedLocationId =
                    _locations.firstWhere((loc) => loc.name == newLocation).id;
                final schedule = await UserRepository()
                    .getOperatingSchedule(selectedLocationId);

                if (schedule != null) {
                  setState(() {
                    _currentOperatingSchedule = schedule;
                    _updateWorkHoursFromSchedule(schedule);
                  });
                } else {
                  setState(() {
                    _currentOperatingSchedule = null;
                    _clearWorkHours();
                  });
                }
              }
            },
            value: selectedLocation,
          ),
        ),
      ],
    );
  }

  void _clearWorkHours() {
    setState(() {
      workHours = {
        'Sunday': {'Start': null, 'End': null},
        'Monday': {'Start': null, 'End': null},
        'Tuesday': {'Start': null, 'End': null},
        'Wednesday': {'Start': null, 'End': null},
        'Thursday': {'Start': null, 'End': null},
        'Friday': {'Start': null, 'End': null},
        'Saturday': {'Start': null, 'End': null},
      };
    });
  }

  void _updateWorkHoursFromSchedule(OperatingSchedule schedule) {
    setState(() {
      // Sunday
      if (schedule.hoursSunFrom != null && schedule.hoursSunTo != null) {
        workHours['Sunday'] = {
          'Start': DateTime(2024, 1, 1, schedule.hoursSunFrom!.hour,
              schedule.hoursSunFrom!.minute),
          'End': DateTime(2024, 1, 1, schedule.hoursSunTo!.hour,
              schedule.hoursSunTo!.minute),
        };
      } else {
        workHours['Sunday'] = {'Start': null, 'End': null};
      }

      // Monday
      if (schedule.hoursMonFrom != null && schedule.hoursMonTo != null) {
        workHours['Monday'] = {
          'Start': DateTime(2024, 1, 1, schedule.hoursMonFrom!.hour,
              schedule.hoursMonFrom!.minute),
          'End': DateTime(2024, 1, 1, schedule.hoursMonTo!.hour,
              schedule.hoursMonTo!.minute),
        };
      } else {
        workHours['Monday'] = {'Start': null, 'End': null};
      }

      // Tuesday
      if (schedule.hoursTueFrom != null && schedule.hoursTueTo != null) {
        workHours['Tuesday'] = {
          'Start': DateTime(2024, 1, 1, schedule.hoursTueFrom!.hour,
              schedule.hoursTueFrom!.minute),
          'End': DateTime(2024, 1, 1, schedule.hoursTueTo!.hour,
              schedule.hoursTueTo!.minute),
        };
      } else {
        workHours['Tuesday'] = {'Start': null, 'End': null};
      }

      // Wednesday
      if (schedule.hoursWedFrom != null && schedule.hoursWedTo != null) {
        workHours['Wednesday'] = {
          'Start': DateTime(2024, 1, 1, schedule.hoursWedFrom!.hour,
              schedule.hoursWedFrom!.minute),
          'End': DateTime(2024, 1, 1, schedule.hoursWedTo!.hour,
              schedule.hoursWedTo!.minute),
        };
      } else {
        workHours['Wednesday'] = {'Start': null, 'End': null};
      }

      // Thursday
      if (schedule.hoursThuFrom != null && schedule.hoursThuTo != null) {
        workHours['Thursday'] = {
          'Start': DateTime(2024, 1, 1, schedule.hoursThuFrom!.hour,
              schedule.hoursThuFrom!.minute),
          'End': DateTime(2024, 1, 1, schedule.hoursThuTo!.hour,
              schedule.hoursThuTo!.minute),
        };
      } else {
        workHours['Thursday'] = {'Start': null, 'End': null};
      }

      // Friday
      if (schedule.hoursFriFrom != null && schedule.hoursFriTo != null) {
        workHours['Friday'] = {
          'Start': DateTime(2024, 1, 1, schedule.hoursFriFrom!.hour,
              schedule.hoursFriFrom!.minute),
          'End': DateTime(2024, 1, 1, schedule.hoursFriTo!.hour,
              schedule.hoursFriTo!.minute),
        };
      } else {
        workHours['Friday'] = {'Start': null, 'End': null};
      }

      // Saturday
      if (schedule.hoursSatFrom != null && schedule.hoursSatTo != null) {
        workHours['Saturday'] = {
          'Start': DateTime(2024, 1, 1, schedule.hoursSatFrom!.hour,
              schedule.hoursSatFrom!.minute),
          'End': DateTime(2024, 1, 1, schedule.hoursSatTo!.hour,
              schedule.hoursSatTo!.minute),
        };
      } else {
        workHours['Saturday'] = {'Start': null, 'End': null};
      }
    });
  }

  Widget _buildWeeklySchedule() {
    // Rearrange the days to start with Sunday
    final daysOfWeek = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday'
    ];

    return Column(
      children: daysOfWeek.map((day) => _buildDaySchedule(day)).toList(),
    );
  }

  Widget _buildDaySchedule(String day) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[130]!,
                  width: 1,
                ),
              ),
            ),
            child: Text(
              day,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildTimePicker(day, 'Start'),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildTimePicker(day, 'End'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String day, String label) {
    final time = workHours[day]?[label];

    return Row(
      children: [
        Expanded(
          child: CustomTimePicker(
            contentPadding: EdgeInsets.all(4.0),
            header: label,
            selected: time,
            onChanged: (newTime) {
              if (newTime != null) {
                setState(() {
                  workHours[day]![label] = DateTime(
                    2024,
                    1,
                    1,
                    newTime.hour,
                    newTime.minute,
                  );
                });
              }
            },
            onClear: () {
              setState(() {
                workHours[day]![label] = null;
              });
            },
            showClearButton: true,
            minuteIncrement: 15,
            hourFormat: HourFormat.h,
          ),
        ),
      ],
    );
  }
}
