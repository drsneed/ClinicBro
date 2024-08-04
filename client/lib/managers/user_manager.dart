import '../models/user.dart';

class UserManager {
  static final UserManager _instance = UserManager._internal();
  User? _currentUser;

  factory UserManager() => _instance;

  UserManager._internal();

  User? get currentUser => _currentUser;

  void setCurrentUser(User? user) {
    _currentUser = user;
  }
}
