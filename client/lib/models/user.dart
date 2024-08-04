class User {
  final int id;
  final bool active;
  final String name;
  final String? color;
  final bool isProvider;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final String? createdBy;
  final String? updatedBy;

  User({
    required this.id,
    required this.active,
    required this.name,
    required this.color,
    required this.isProvider,
    required this.dateCreated,
    required this.dateUpdated,
    required this.createdBy,
    required this.updatedBy,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      active: json['active'],
      name: json['name'],
      color: json['color'],
      isProvider: json['is_provider'],
      dateCreated: DateTime.parse(json['date_created']),
      dateUpdated: DateTime.parse(json['date_updated']),
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'active': active,
      'name': name,
      'color': color,
      'is_provider': isProvider,
      'date_created': dateCreated.toIso8601String(),
      'date_updated': dateUpdated.toIso8601String(),
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }
}
