import 'package:capstone_reyes/main.dart';
import 'package:capstone_reyes/models/event.dart';
import 'package:capstone_reyes/services/event_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// In-memory stand-in so tests never touch the network.
class FakeEventService extends EventService {
  final Map<String, SchoolEvent> events = {
    'a': SchoolEvent(
      id: 'a',
      title: 'Science Fair',
      description: 'Projects on display.',
      location: 'Lab',
      startsAt: DateTime(2026, 12, 10, 9),
    ),
  };
  final Map<String, Set<String>> rsvps = {};
  int _n = 0;

  @override
  Future<List<SchoolEvent>> fetchEvents() async => events.values.toList();

  @override
  Future<Map<String, Set<String>>> fetchRsvps() async =>
      rsvps.map((k, v) => MapEntry(k, {...v}));

  @override
  Future<String> createEvent(SchoolEvent e) async {
    final id = 'n${_n++}';
    events[id] = SchoolEvent(
        id: id,
        title: e.title,
        description: e.description,
        location: e.location,
        startsAt: e.startsAt);
    return id;
  }

  @override
  Future<void> updateEvent(SchoolEvent e) async => events[e.id] = e;

  @override
  Future<void> deleteEvent(String id) async {
    events.remove(id);
    rsvps.remove(id);
  }

  @override
  Future<void> setRsvp(String eventId, String studentId, bool going) async {
    final s = rsvps.putIfAbsent(eventId, () => {});
    going ? s.add(studentId) : s.remove(studentId);
  }
}

void main() {
  testWidgets('Shows the student ID screen first', (tester) async {
    await tester.pumpWidget(EventApp(service: FakeEventService()));
    await tester.pumpAndSettle();

    expect(find.text('School Events'), findsOneWidget);
    expect(find.text('Student ID'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('Sign in, RSVP, and open event details', (tester) async {
    await tester.pumpWidget(EventApp(service: FakeEventService(), initialStudentId: '2024-001'));
    await tester.pumpAndSettle();

    expect(find.text('Science Fair'), findsOneWidget);
    expect(find.text('0 attending'), findsOneWidget);

    await tester.tap(find.text('RSVP'));
    await tester.pumpAndSettle();
    expect(find.text('1 attending'), findsOneWidget);
    expect(find.text('My Events (1)'), findsOneWidget);

    await tester.tap(find.text('Science Fair'));
    await tester.pumpAndSettle();
    expect(find.text('Event details'), findsOneWidget);
    expect(find.text('2024-001 (you)'), findsOneWidget);
  });
}
