import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as mat;
import 'package:provider/provider.dart';
import '../managers/user_manager.dart';
import '../models/patient_item.dart';
import '../services/auth_service.dart';
import '../widgets/themed_icon.dart';
import '../widgets/title_bar_tab_control.dart';
import 'scheduler_screen.dart';
import 'system_screen.dart';
import 'account_settings_dialog.dart';
import '../widgets/custom_title_bar.dart';
import 'dart:io' show Platform;
import '../widgets/avatar_button.dart';
import 'patient_chart_screen.dart';
import '../managers/patient_tab_manager.dart';
import '../widgets/patient_finder.dart'; // Import the PatientFinder widget

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<int> _history = [];
  final GlobalKey<AvatarButtonState> _avatarButtonKey =
      GlobalKey<AvatarButtonState>();
  String _currentPaneTitle = 'Home';
  late PatientTabManager _patientTabManager;
  bool _isFlyoutVisible = false;
  static const String _patientChartsPaneTitle = 'Charting';
  @override
  void initState() {
    super.initState();
    _patientTabManager = PatientTabManager();
    _patientTabManager
        .addListener(() => setState(() {})); // T tried this but it didn't help
  }

  void _toggleFlyout() {
    setState(() {
      _isFlyoutVisible = !_isFlyoutVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;

    return ChangeNotifierProvider.value(
      value: _patientTabManager,
      child: ScaffoldPage(
        padding: EdgeInsets.zero,
        content: Stack(
          children: [
            NavigationView(
              appBar: NavigationAppBar(
                title: Consumer<PatientTabManager>(
                  builder: (context, patientTabManager, child) {
                    return CustomTitleBar(
                      showBackButton: _history.isNotEmpty,
                      showAvatarButton: true,
                      title: Text(_currentPaneTitle),
                      onBack: () {
                        if (_history.isNotEmpty) {
                          setState(() {
                            _currentIndex = _history.removeLast();
                            _updatePaneTitle();
                          });
                        }
                      },
                      onAccountSettings: () {
                        _showAccountSettingsDialog(context);
                      },
                      onSignOut: () {
                        AuthService().signOut();
                        Navigator.of(context).pushReplacementNamed('/');
                      },
                      avatarButtonKey: _avatarButtonKey,
                      tabButtonData: patientTabManager.openTabs
                          .map((tab) =>
                              TabButtonData(tabId: tab.id, label: tab.name))
                          .toList(),
                      onTabsReordered: (reorderedTabs) {
                        setState(() {
                          _patientTabManager.reorderTabs(
                              reorderedTabs.map((tab) => tab.tabId).toList());
                        });
                      },
                      selectedTabId: patientTabManager.selectedTabId,
                      onTabSelected: (tabId) {
                        patientTabManager.selectTab(tabId);
                        setState(() {
                          _currentIndex = 2; // Use index 2 for Charting
                          _currentPaneTitle = _patientChartsPaneTitle;
                        });
                      },
                      onTabClosed: (tabId) {
                        patientTabManager.closeTab(tabId);
                        if (patientTabManager.openTabs.isEmpty) {
                          setState(() {
                            _currentIndex = 0;
                            _updatePaneTitle();
                          });
                        }
                      },
                      onPatientDropped: (patient) {
                        setState(() {
                          patientTabManager.openTab(
                              patient.id, patient.fullName);
                          _currentIndex = 2; // Switch to patient chart pane
                          _currentPaneTitle = _patientChartsPaneTitle;
                        });
                      },
                    );
                  },
                ),
                automaticallyImplyLeading: false,
              ),
              pane: NavigationPane(
                selected: _currentIndex,
                onChanged: (index) {
                  setState(() {
                    if (_currentIndex != index) {
                      _history.add(_currentIndex);
                      _currentIndex = index;
                      _updatePaneTitle();
                    }
                  });
                },
                displayMode:
                    isMobile ? PaneDisplayMode.auto : PaneDisplayMode.compact,
                items: [
                  PaneItem(
                    icon: Icon(FluentIcons.home),
                    title: Text('Home'),
                    body: _buildHomeContent(),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.calendar),
                    title: Text('Schedule'),
                    body: SchedulerScreen(isMobile: isMobile),
                  ),
                  PaneItem(
                    //icon: Icon(FluentIcons.clipboard_list),
                    icon: ThemedIcon(
                      svgPath: "assets/icon/clipboard.svg",
                      size: 17.0,
                    ),
                    title: const Text(_patientChartsPaneTitle),
                    body: Consumer<PatientTabManager>(
                      builder: (context, patientTabManager, child) {
                        return patientTabManager.selectedTabId != null
                            ? PatientChartScreen(
                                patientId: patientTabManager.selectedTabId!)
                            : Center(child: Text('No patient selected'));
                      },
                    ),
                  ),
                  PaneItem(
                    icon: Icon(FluentIcons.system),
                    title: Text('System'),
                    body: SystemScreen(),
                  ),
                ],
              ),
            ),
            if (_isFlyoutVisible) _buildFlyout(),
            _buildFloatingActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFlyout() {
    final isMobile = Platform.isAndroid || Platform.isIOS;
    return isMobile ? _buildMobileFlyout() : _buildDesktopFlyout();
  }

  void _onOpenPatientChart(PatientItem patientItem) {
    setState(() {
      _patientTabManager.openTab(patientItem.id, patientItem.fullName);
    });
  }

  Widget _buildDesktopFlyout() {
    return Positioned(
      key: const ValueKey('flyout'),
      top: 54,
      right: 0,
      bottom: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        width: _isFlyoutVisible ? 400 : 0,
        child: Container(
          color: FluentTheme.of(context).micaBackgroundColor,
          child: _isFlyoutVisible
              ? PatientFinder(
                  onDragStart: _onPatientDragStart,
                  onOpenChart: _onOpenPatientChart,
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildMobileFlyout() {
    return AnimatedPositioned(
      key: const ValueKey('flyout'),
      duration: Duration(milliseconds: 300),
      left: 0,
      right: 0,
      bottom: _isFlyoutVisible ? 0 : -200,
      height: 200,
      child: Container(
        decoration: BoxDecoration(
          color: FluentTheme.of(context).micaBackgroundColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          boxShadow: [
            BoxShadow(
              color: mat.Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: PatientFinder(
          onDragStart: _onPatientDragStart,
          onOpenChart: _onOpenPatientChart,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    final isDesktop = !(Platform.isAndroid || Platform.isIOS);
    return AnimatedPositioned(
      key: const ValueKey('fab'),
      duration: Duration(milliseconds: 300),
      right: isDesktop
          ? (_isFlyoutVisible ? 416 : 16)
          : 16, // Move right if flyout visible
      bottom: !isDesktop
          ? (_isFlyoutVisible ? 216 : 16)
          : 16, // Move up if flyout visible
      child: SizedBox(
        width: isDesktop ? 40 : 64,
        height: isDesktop ? 40 : 64,
        child: mat.FloatingActionButton(
          child: Icon(
            _isFlyoutVisible
                ? (isDesktop
                    ? FluentIcons.chevron_right
                    : FluentIcons.chevron_down)
                : FluentIcons.people,
            color: mat.Colors.white,
            size: isDesktop ? 20 : 24,
          ),
          backgroundColor: mat.Colors.blue,
          shape: mat.CircleBorder(),
          onPressed: _toggleFlyout,
          tooltip: _isFlyoutVisible ? 'Hide Patients' : 'Show Patients',
        ),
      ),
    );
  }

  void _updatePaneTitle() {
    setState(() {
      _currentPaneTitle = [
        'Home',
        'Schedule',
        _patientChartsPaneTitle,
        'System',
      ][_currentIndex];
    });
  }

  void _showAccountSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AccountSettingsDialog(
          onAvatarChanged: () {
            if (_avatarButtonKey.currentState != null) {
              _avatarButtonKey.currentState!.refreshAvatar();
            }
          },
        );
      },
    );
  }

  Widget _buildHomeContent() {
    return ScaffoldPage(
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome ${UserManager().currentUser?.name ?? 'User'}!'),
          ],
        ),
      ),
    );
  }

  void _onPatientDragStart() {
    setState(() {
      _isFlyoutVisible = false;
    });
  }
}
