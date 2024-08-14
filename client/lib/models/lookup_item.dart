class LookupItem {
  final int id;
  final bool active;
  final String name;
  LookupItem({
    required this.id,
    required this.active,
    required this.name,
  });

  factory LookupItem.fromJson(Map<String, dynamic> json) {
    return LookupItem(
      id: json['id'],
      active: json['active'],
      name: json['name'],
    );
  }
}
