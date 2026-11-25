import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/event.dart';

class DbException implements Exception {
  final String message;
  DbException(this.message);
  @override
  String toString() => message;
}

/// CRUD against Firebase Realtime Database over its REST API.
///
/// Data layout:
///   /events/{eventId}            -> { title, description, location, startsAt }
///   /rsvps/{eventId}/{studentId} -> true
class EventService {
  final http.Client _client;
  EventService([http.Client? client]) : _client = client ?? http.Client();

  static const _timeout = Duration(seconds: 15);

  Uri _uri(String path) => Uri.parse('$kDatabaseUrl/$path.json');

  Future<dynamic> _send(String method, String path, [Object? body]) async {
    final req = http.Request(method, _uri(path));
    if (body != null) {
      req.headers['Content-Type'] = 'application/json';
      req.body = jsonEncode(body);
    }
    try {
      final res = await http.Response.fromStream(await _client.send(req).timeout(_timeout));
      if (res.statusCode == 401 || res.statusCode == 403) {
        throw DbException(
            'Permission denied. In the Firebase console open Realtime Database > Rules '
            'and allow read/write (".read": true, ".write": true).');
      }
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw DbException('Database error ${res.statusCode}: ${res.body}');
      }
      return res.body.isEmpty ? null : jsonDecode(res.body);
    } on DbException {
      rethrow;
    } catch (e) {
      throw DbException('Could not reach the database. Check your internet connection.\n($e)');
    }
  }

  // ---------------------------------------------------------------- READ

  Future<List<SchoolEvent>> fetchEvents() async {
    final data = await _send('GET', 'events');
    if (data is! Map) return [];
    final list = <SchoolEvent>[];
    data.forEach((key, value) {
      if (value is Map) list.add(SchoolEvent.fromJson(key.toString(), value));
    });
    list.sort((a, b) => a.startsAt.compareTo(b.startsAt));
    return list;
  }

  /// { eventId: { studentId: true } }
  Future<Map<String, Set<String>>> fetchRsvps() async {
    final data = await _send('GET', 'rsvps');
    final out = <String, Set<String>>{};
    if (data is Map) {
      data.forEach((eventId, students) {
        if (students is Map) {
          out[eventId.toString()] = students.keys.map((k) => k.toString()).toSet();
        }
      });
    }
    return out;
  }

  // ---------------------------------------------------------------- CREATE

  Future<String> createEvent(SchoolEvent e) async {
    final res = await _send('POST', 'events', e.toJson());
    return (res as Map)['name'] as String;
  }

  /// Writes the sample events (used from the empty state only).
  Future<void> seedSamples() async {
    final now = DateTime.now();
    DateTime at(int days, int hour, [int minute = 0]) {
      final d = now.add(Duration(days: days));
      return DateTime(d.year, d.month, d.day, hour, minute);
    }

    final samples = [
      ('Foundation Day Celebration', 'Parade, booths, and performances for the whole school.',
          'School Gymnasium', at(7, 8)),
      ('Science & Tech Fair', 'Student projects and experiments on display.', 'Science Building',
          at(12, 9)),
      ('Christmas Program', 'Caroling, skits, and the class gift exchange.', 'Covered Court',
          at(20, 13)),
      ('Intramurals Opening', 'Opening ceremony and first games of the intramurals.',
          'School Oval', at(35, 7, 30)),
      ('Career Orientation Day', 'Guest speakers talk about college courses and careers.',
          'Auditorium', at(42, 10)),
    ];
    for (final s in samples) {
      await createEvent(SchoolEvent(
        id: '',
        title: s.$1,
        description: s.$2,
        location: s.$3,
        startsAt: s.$4,
      ));
    }
  }

  // ---------------------------------------------------------------- UPDATE

  Future<void> updateEvent(SchoolEvent e) => _send('PATCH', 'events/${e.id}', e.toJson());

  Future<void> setRsvp(String eventId, String studentId, bool going) {
    final path = 'rsvps/$eventId/${Uri.encodeComponent(studentId)}';
    return going ? _send('PUT', path, true) : _send('DELETE', path);
  }

  // ---------------------------------------------------------------- DELETE

  Future<void> deleteEvent(String id) async {
    await _send('DELETE', 'events/$id');
    await _send('DELETE', 'rsvps/$id');
  }
}
