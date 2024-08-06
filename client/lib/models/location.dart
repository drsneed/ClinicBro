import 'dart:convert';

class Location {
  final int id;
  final bool? active;
  final String name;
  final String? phone;
  final String? address1;
  final String? address2;
  final String? city;
  final String? state;
  final String? zipCode;
  final DateTime dateCreated;
  final DateTime dateUpdated;
  final int? createdUserId;
  final int? updatedUserId;

  Location({
    required this.id,
    this.active,
    required this.name,
    this.phone,
    this.address1,
    this.address2,
    this.city,
    this.state,
    this.zipCode,
    required this.dateCreated,
    required this.dateUpdated,
    this.createdUserId,
    this.updatedUserId,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      active: json['active'],
      name: json['name'],
      phone: json['phone'],
      address1: json['address_1'],
      address2: json['address_2'],
      city: json['city'],
      state: json['state'],
      zipCode: json['zip_code'],
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
      'phone': phone,
      'address_1': address1,
      'address_2': address2,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'date_created': dateCreated.toIso8601String(),
      'date_updated': dateUpdated.toIso8601String(),
      'created_user_id': createdUserId,
      'updated_user_id': updatedUserId,
    };
  }
}
