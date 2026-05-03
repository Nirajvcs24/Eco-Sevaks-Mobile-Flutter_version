class AppEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String type; // 'in-person' or 'virtual'
  final String location;
  final String locationDetails;
  final List<String> tags;
  final String imageUrl;
  final List<String> attendees;
  final String organizerId;
  final String status; // 'approved', 'pending', 'restricted'
  final String? whatToBring;

  AppEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
    required this.location,
    required this.locationDetails,
    required this.tags,
    required this.imageUrl,
    this.attendees = const [],
    required this.organizerId,
    required this.status,
    this.whatToBring,
  });

  factory AppEvent.fromJson(Map<String, dynamic> json) {
    return AppEvent(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      type: json['type'] ?? 'in-person',
      location: json['location'] ?? '',
      locationDetails: json['locationDetails'] ?? '',
      tags: json['tags'] is String
          ? (json['tags'] as String).split(',').where((t) => t.isNotEmpty).toList()
          : List<String>.from(json['tags'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      attendees: List<String>.from(json['attendees']?.map((e) => e.toString()) ?? []),
      organizerId: json['organizer']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      whatToBring: json['whatToBring'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'type': type,
      'location': location,
      'locationDetails': locationDetails,
      'tags': tags,
      'imageUrl': imageUrl,
      'attendees': attendees,
      'organizer': organizerId,
      'status': status,
      'whatToBring': whatToBring,
    };
  }

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isVirtual => type == 'virtual';
}
