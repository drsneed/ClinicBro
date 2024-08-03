import 'package:fluent_ui/fluent_ui.dart';
import 'custom_title_bar.dart';
import 'themed_icon.dart';
import 'data_service.dart'; // Import your API service

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final DataService _dataService = DataService('http://192.168.1.34:33420');

  Future<void> _signIn() async {
    final username = _usernameController.text;
    final password = _passwordController.text;
    final token = await _dataService.authenticateUser(username, password);
    if (token != null && token.isNotEmpty) {
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
    return NavigationView(
      appBar: NavigationAppBar(
        title: CustomTitleBar(
          showBackButton: false,
          title: Text('Sign In'),
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
