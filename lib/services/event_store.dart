import 'package:flutter/foundation.dart';

import '../models/event.dart';
import 'event_service.dart';

/// App state shared by every screen: events, RSVPs and the signed-in student.
class EventStore extends ChangeNotifier {
  final EventService service;
  final String studentId;

  EventStore(this.service, this.studentId);

  List<SchoolEvent> events = [];
  Map<String, Set<String>> rsvps = {};
  bool loading = true;
  String? error;

  bool isGoing(String eventId) => rsvps[eventId]?.contains(studentId) ?? false;
  int count(String eventId) => rsvps[eventId]?.length ?? 0;
  List<String> attendees(String eventId) => (rsvps[eventId] ?? {}).toList()..sort();
  List<SchoolEvent> get myEvents => events.where((e) => isGoing(e.id)).toList();

  SchoolEvent? byId(String id) {
    for (final e in events) {
      if (e.id == id) return e;
    }
    return null;
  }

  Future<void> load() async {
    loading = events.isEmpty;
    error = null;
    notifyListeners();
    try {
      final results = await Future.wait([service.fetchEvents(), service.fetchRsvps()]);
      events = results[0] as List<SchoolEvent>;
      rsvps = results[1] as Map<String, Set<String>>;
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> add(SchoolEvent e) async {
    await service.createEvent(e);
    await load();
  }

  Future<void> update(SchoolEvent e) async {
    await service.updateEvent(e);
    await load();
  }

  Future<void> remove(String id) async {
    await service.deleteEvent(id);
    await load();
  }

  Future<void> seedSamples() async {
    await service.seedSamples();
    await load();
  }

  /// Updates the screen right away, then saves; rolls back if the save fails.
  Future<void> toggleRsvp(String eventId) async {
    final going = !isGoing(eventId);
    final before = rsvps;
    final set = {...(rsvps[eventId] ?? <String>{})};
    going ? set.add(studentId) : set.remove(studentId);
    rsvps = {...rsvps, eventId: set};
    notifyListeners();
    try {
      await service.setRsvp(eventId, studentId, going);
    } catch (_) {
      rsvps = before;
      notifyListeners();
      rethrow;
    }
  }
}
