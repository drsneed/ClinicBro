class AppointmentType {
  final int id;
  final bool active;
  final String name;
  final String? description;
  final String color;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final int? createdUserId;
  final int? updatedUserId;

  AppointmentType({
    required this.id,
    required this.active,
    required this.name,
    this.description,
    required this.color,
    required this.dateCreated,
    required this.dateUpdated,
    this.createdUserId,
    this.updatedUserId,
  });

  factory AppointmentType.fromJson(Map<String, dynamic> json) {
    return AppointmentType(
      id: json['id'],
      active: json['active'],
      name: json['name'],
      description: json['description'],
      color: json['color'],
      dateCreated: DateTime.parse(json['date_created']),
      dateUpdated: DateTime.parse(json['date_updated']),
      createdUserId: json['created_user_id'],
      updatedUserId: json['updated_user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'active': active,
      'name': name,
      'description': description,
      'color': color,
      'date_created': dateCreated.toIso8601String(),
      'date_updated': dateUpdated.toIso8601String(),
      'created_user_id': createdUserId,
      'updated_user_id': updatedUserId,
    };
  }
}
