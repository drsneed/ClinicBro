import 'package:fluent_ui/fluent_ui.dart';
import '../services/auth_service.dart';
import '../widgets/custom_title_bar.dart';
import '../widgets/themed_icon.dart';
import 'dart:io' show Platform;

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final authService = AuthService();
    if (await authService.signIn(username, password)) {
      Navigator.of(context).pushReplacementNamed('/home');
    } else {
      showDialog(
        context: context,
        builder: (context) => ContentDialog(
          title: Text('Authentication Error'),
          content: Text('Invalid username or password'),
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
                    ThemedIcon(
                        svgPath: 'assets/icon/app_icon.svg',
                        size: 48), // Your app icon
                    SizedBox(width: 8), // Space between the icon and text
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
                SizedBox(height: 20),
                FilledButton(
                  onPressed: _signIn,
                  child: Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
