class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final String area;
  final List<String> joinedEvents;
  final List<String> createdEvents;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.area,
    this.joinedEvents = const [],
    this.createdEvents = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      area: json['area'] ?? '',
      joinedEvents: List<String>.from(json['joinedEvents']?.map((e) => e.toString()) ?? []),
      createdEvents: List<String>.from(json['createdEvents']?.map((e) => e.toString()) ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'area': area,
      'joinedEvents': joinedEvents,
      'createdEvents': createdEvents,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isOrganizer => role == 'organizer' || role == 'admin';
}
