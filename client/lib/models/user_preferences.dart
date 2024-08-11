class UserPreference {
  final int userId;
  final String preferenceKey;
  final String preferenceValue;

  UserPreference({
    required this.userId,
    required this.preferenceKey,
    required this.preferenceValue,
  });

  factory UserPreference.fromJson(Map<String, dynamic> json) {
    return UserPreference(
      userId: json['user_id'],
      preferenceKey: json['preference_key'],
      preferenceValue: json['preference_value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'preference_key': preferenceKey,
      'preference_value': preferenceValue,
    };
  }
}

class UserPreferences {
  final List<UserPreference> preferences;

  UserPreferences({
    required this.preferences,
  });

  factory UserPreferences.fromJson(List<dynamic> json) {
    List<UserPreference> preferences =
        json.map((i) => UserPreference.fromJson(i)).toList();
    return UserPreferences(
      preferences: preferences,
    );
  }

  List<dynamic> toJson() {
    return preferences.map((i) => i.toJson()).toList();
  }
}
