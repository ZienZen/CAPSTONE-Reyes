import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolEvent {
  final String id;
  final String title;
  final String description;
  final String location;
  final DateTime startsAt;
  final int attendeeCount;

  const SchoolEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.startsAt,
    required this.attendeeCount,
  });

  factory SchoolEvent.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return SchoolEvent(
      id: doc.id,
      title: d['title'] as String,
      description: d['description'] as String,
      location: d['location'] as String,
      startsAt: (d['startsAt'] as Timestamp).toDate(),
      attendeeCount: (d['attendeeCount'] as num?)?.toInt() ?? 0,
    );
  }
}
