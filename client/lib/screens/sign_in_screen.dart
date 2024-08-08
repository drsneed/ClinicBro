// ignore_for_file: use_build_context_synchronously

import 'package:dotenv/dotenv.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../widgets/custom_title_bar.dart';
import '../widgets/themed_icon.dart';
import 'dart:io' show Platform;

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _serverUrlController = TextEditingController();
  final _orgIdController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _showCredentials = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverUrlController.text = prefs.getString('serverUrl') ?? '';
      _orgIdController.text = prefs.getString('orgId') ?? '';
      _showCredentials = _orgIdController.text.isNotEmpty;
      if (prefs.getBool('rememberMe') ?? false) {
        _usernameController.text = prefs.getString('username') ?? '';
        _rememberMe = true;
      }
    });

    // Validate and set server URL if it's not empty
    final serverUrl = _serverUrlController.text;
    if (serverUrl.isNotEmpty) {
      DataService().setBaseUrl(serverUrl);
      // You might want to add additional logic here to verify if the server URL is valid
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverUrl', _serverUrlController.text);
    await prefs.setString('orgId', _orgIdController.text);
    await prefs.setBool('rememberMe', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('username', _usernameController.text);
    } else {
      await prefs.remove('username');
    }
  }

  void _showInfoBar(String message,
      {InfoBarSeverity severity = InfoBarSeverity.info,
      int durationSeconds = 3}) {
    displayInfoBar(
      context,
      duration: Duration(seconds: durationSeconds),
      builder: (context, close) {
        return InfoBar(
          title: Text(message),
          severity: severity,
          onClose: close,
        );
      },
    );
  }

  Future<void> _validateOrgIdAndServerUrl() async {
    setState(() {
      _isLoading = true;
    });

    final serverUrl = _serverUrlController.text;
    final orgId = _orgIdController.text;
    final dataService = DataService();
    dataService.setBaseUrl(serverUrl);

    // validate server url
    if (!await dataService.validateServer()) {
      _showInfoBar(
          "Server is not available. Please check the URL or your network connection",
          severity: InfoBarSeverity.error,
          durationSeconds: 5);
    } else {
      // validate org id
      if (await AuthService().validateOrganization(orgId)) {
        setState(() {
          _showCredentials = true;
        });
        await _saveData();
      } else {
        _showInfoBar("Invalid Organization ID",
            severity: InfoBarSeverity.error);
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    final orgId = _orgIdController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;
    final authService = AuthService();

    // Only exit loading state in the event of a sign in failure.
    // This prevents what looks like a flicker of the screen as the user
    // is signing in.
    if (await authService.signIn(orgId, username, password)) {
      await _saveData();
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      setState(() {
        _isLoading = false;
      });
      _showInfoBar("Invalid name or password", severity: InfoBarSeverity.error);
    }
  }

  void _goBack() {
    setState(() {
      _showCredentials = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Platform.isAndroid || Platform.isIOS;
    return NavigationView(
      appBar: isMobile
          ? null
          : const NavigationAppBar(
              title: CustomTitleBar(
                showBackButton: false,
                showAvatarButton: false,
                title: Text('Sign In'),
              ),
              automaticallyImplyLeading: false,
            ),
      content: ScaffoldPage(
        content: Stack(
          children: [
            // Main content
            if (!_isLoading)
              Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ThemedIcon(
                            svgPath: 'assets/icon/app_icon.svg',
                            size: 48,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'ClinicBro',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (!_showCredentials) ...[
                        TextBox(
                          controller: _serverUrlController,
                          placeholder: 'Server URL',
                        ),
                        const SizedBox(height: 10),
                        TextBox(
                          controller: _orgIdController,
                          placeholder: 'Organization ID',
                        ),
                      ] else ...[
                        TextBox(
                          controller: _usernameController,
                          placeholder: 'User Name',
                        ),
                        const SizedBox(height: 10),
                        PasswordBox(
                          controller: _passwordController,
                          placeholder: 'Password',
                          onSubmitted: (value) {
                            _signIn();
                          },
                        ),
                        const SizedBox(height: 10),
                        Checkbox(
                          checked: _rememberMe,
                          onChanged: (value) {
                            setState(() {
                              _rememberMe = value!;
                            });
                          },
                          content: const Text('Remember Me'),
                        ),
                      ],
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: _showCredentials
                            ? _signIn
                            : _validateOrgIdAndServerUrl,
                        child: Text(_showCredentials ? 'Sign In' : 'Continue'),
                      ),
                      if (_showCredentials) ...[
                        const SizedBox(height: 10),
                        Button(
                          onPressed: _goBack,
                          child: const Text('Back'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            // Loading indicator
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors
                      .transparent, // Optional: Adds a semi-transparent background
                  child: const Center(
                    child: ProgressRing(
                      strokeWidth: 4,
                      semanticLabel: "Attempting to Connect...",
                      value: null, // null makes it indeterminate
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
