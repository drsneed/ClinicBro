class AppointmentStatus {
  final int id;
  final bool active;
  final String name;
  final String? description;
  final bool show;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final int? createdUserId;
  final int? updatedUserId;

  AppointmentStatus({
    required this.id,
    required this.active,
    required this.name,
    this.description,
    required this.show,
    required this.dateCreated,
    required this.dateUpdated,
    this.createdUserId,
    this.updatedUserId,
  });

  factory AppointmentStatus.fromJson(Map<String, dynamic> json) {
    return AppointmentStatus(
      id: json['id'],
      active: json['active'],
      name: json['name'],
      description: json['description'],
      show: json['show'],
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
      'show': show,
      'date_created': dateCreated.toIso8601String(),
      'date_updated': dateUpdated.toIso8601String(),
      'created_user_id': createdUserId,
      'updated_user_id': updatedUserId,
    };
  }
}
