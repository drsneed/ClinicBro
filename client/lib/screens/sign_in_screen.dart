import 'package:fluent_ui/fluent_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../services/data_service.dart';
import '../widgets/custom_title_bar.dart';
import '../widgets/themed_icon.dart';
import 'dart:io' show Platform;

class SignInScreen extends StatefulWidget {
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

  Future<void> _validateOrgIdAndServerUrl() async {
    final serverUrl = _serverUrlController.text;
    DataService().setBaseUrl(serverUrl);
    // TODO: Implement validation logic
    // For now, we'll just assume it's valid
    setState(() {
      _showCredentials = true;
    });
    await _saveData();
  }

  Future<void> _signIn() async {
    final orgId = _orgIdController.text;
    final username = _usernameController.text;
    final password = _passwordController.text;
    final authService = AuthService();
    if (await authService.signIn(orgId, username, password)) {
      await _saveData();
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      showDialog(
        context: context,
        builder: (context) => ContentDialog(
          title: Text('Authentication Error'),
          content: Text('Invalid credentials or server information'),
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
          : NavigationAppBar(
              title: CustomTitleBar(
                showBackButton: false,
                showAvatarButton: false,
                title: Text('Sign In'),
                onAccountSettings: () {
                  // Navigate to account settings page
                },
                onSignOut: () {
                  // Handle sign out logic
                },
              ),
              automaticallyImplyLeading: false,
            ),
      content: ScaffoldPage(
        content: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 300),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ThemedIcon(svgPath: 'assets/icon/app_icon.svg', size: 48),
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
                SizedBox(height: 20),
                if (!_showCredentials) ...[
                  TextBox(
                    controller: _serverUrlController,
                    placeholder: 'Server URL',
                  ),
                  SizedBox(height: 10),
                  TextBox(
                    controller: _orgIdController,
                    placeholder: 'Organization ID',
                  ),
                ] else ...[
                  TextBox(
                    controller: _usernameController,
                    placeholder: 'User Name',
                  ),
                  SizedBox(height: 10),
                  PasswordBox(
                    controller: _passwordController,
                    placeholder: 'Password',
                    onSubmitted: (value) {
                      _signIn();
                    },
                  ),
                  SizedBox(height: 10),
                  Checkbox(
                    checked: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                    content: Text('Remember Me'),
                  ),
                ],
                SizedBox(height: 20),
                FilledButton(
                  onPressed:
                      _showCredentials ? _signIn : _validateOrgIdAndServerUrl,
                  child: Text(_showCredentials ? 'Sign In' : 'Continue'),
                ),
                if (_showCredentials) ...[
                  SizedBox(height: 10),
                  Button(
                    onPressed: _goBack,
                    child: Text('Back'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
