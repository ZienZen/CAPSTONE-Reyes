import 'package:cloud_firestore/cloud_firestore.dart';

/// Hardcoded events. Written to Firestore once if the collection is empty.
final List<Map<String, dynamic>> seedEvents = [
  {
    'id': 'welcome-assembly',
    'title': 'Welcome Assembly',
    'description': 'Kick off the school year with announcements and club showcases.',
    'location': 'Main Gymnasium',
    'startsAt': DateTime(2026, 12, 1, 9, 0),
  },
  {
    'id': 'science-fair',
    'title': 'Science Fair',
    'description': 'Student projects on display. Come vote for the People\'s Choice award.',
    'location': 'Science Building Atrium',
    'startsAt': DateTime(2026, 12, 4, 13, 0),
  },
  {
    'id': 'basketball-finals',
    'title': 'Inter-class Basketball Finals',
    'description': 'Cheer on your class in the championship game.',
    'location': 'Main Gymnasium',
    'startsAt': DateTime(2026, 12, 8, 16, 30),
  },
  {
    'id': 'career-talk',
    'title': 'Career Talk: Tech Industry',
    'description': 'Alumni panel on getting started in software and IT.',
    'location': 'Auditorium',
    'startsAt': DateTime(2026, 12, 10, 14, 0),
  },
  {
    'id': 'christmas-party',
    'title': 'Christmas Party',
    'description': 'Games, food and performances to close out the term.',
    'location': 'School Quadrangle',
    'startsAt': DateTime(2026, 12, 18, 15, 0),
  },
];

Future<void> seedEventsIfEmpty(FirebaseFirestore db) async {
  final existing = await db.collection('events').limit(1).get();
  if (existing.docs.isNotEmpty) return;
  final batch = db.batch();
  for (final e in seedEvents) {
    batch.set(db.collection('events').doc(e['id'] as String), {
      'title': e['title'],
      'description': e['description'],
      'location': e['location'],
      'startsAt': Timestamp.fromDate(e['startsAt'] as DateTime),
      'attendeeCount': 0,
    });
  }
  await batch.commit();
}
