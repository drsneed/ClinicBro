class Patient {
  final int id;
  final bool active;
  final String firstName;
  final String? middleName;
  final String lastName;
  final DateTime? dateOfBirth;
  final DateTime? dateOfDeath;
  final String? email;
  final String? phone;
  final String? password;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? notes;
  final bool canCall;
  final bool canText;
  final bool canEmail;
  final int locationId;
  final int userId;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final int? createdUserId;
  final int? updatedUserId;

  // Getter for fullName
  String get fullName {
    // Check if middleName is null or empty, then format accordingly
    if (middleName == null || middleName!.isEmpty) {
      return '$lastName, $firstName';
    } else {
      return '$lastName, $firstName $middleName';
    }
  }

  Patient({
    required this.id,
    required this.active,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.dateOfBirth,
    this.dateOfDeath,
    this.email,
    this.phone,
    this.password,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.zipCode,
    this.notes,
    required this.canCall,
    required this.canText,
    required this.canEmail,
    required this.locationId,
    required this.userId,
    required this.dateCreated,
    required this.dateUpdated,
    this.createdUserId,
    this.updatedUserId,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      active: json['active'],
      firstName: json['first_name'],
      middleName: json['middle_name'],
      lastName: json['last_name'],
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      dateOfDeath: json['date_of_death'] != null
          ? DateTime.parse(json['date_of_death'])
          : null,
      email: json['email'],
      phone: json['phone'],
      password: json['password'],
      address1: json['address_1'],
      address2: json['address_2'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
      notes: json['notes'],
      canCall: json['can_call'],
      canText: json['can_text'],
      canEmail: json['can_email'],
      locationId: json['location_id'],
      userId: json['provider_id'],
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
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'date_of_death': dateOfDeath?.toIso8601String(),
      'email': email,
      'phone': phone,
      'password': password,
      'address_1': address1,
      'address_2': address2,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'notes': notes,
      'can_call': canCall,
      'can_text': canText,
      'can_email': canEmail,
      'location_id': locationId,
      'user_id': userId,
      'date_created': dateCreated.toIso8601String(),
      'date_updated': dateUpdated.toIso8601String(),
      'created_user_id': createdUserId,
      'updated_user_id': updatedUserId,
    };
  }
}
