class SchoolEvent {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startsAt;

  const SchoolEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startsAt,
  });

  factory SchoolEvent.fromJson(String id, Map<dynamic, dynamic> j) => SchoolEvent(
        id: id,
        title: (j['title'] ?? '').toString(),
        description: (j['description'] ?? '').toString(),
        location: (j['location'] ?? '').toString(),
        startsAt: DateTime.tryParse((j['startsAt'] ?? '').toString()) ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'location': location,
        'startsAt': startsAt.toIso8601String(),
      };
}
