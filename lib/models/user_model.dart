class AppUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> joinedEvents;
  final List<String> createdEvents;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.joinedEvents = const [],
    this.createdEvents = const [],
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
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
      'joinedEvents': joinedEvents,
      'createdEvents': createdEvents,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isOrganizer => role == 'organizer' || role == 'admin';
}
