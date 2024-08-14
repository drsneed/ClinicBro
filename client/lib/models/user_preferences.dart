class UserPreferences {
  final Map<String, String> preferences;
  final int userId;
  UserPreferences({
    required this.userId,
    required this.preferences,
  });

  factory UserPreferences.fromJson(int userId, Map<String, dynamic> json) {
    // json is already a Map<String, dynamic> where the keys are the preference keys
    return UserPreferences(
      userId: userId,
      preferences: Map<String, String>.from(json),
    );
  }

  Map<String, dynamic> toJson() {
    return preferences;
  }
}
