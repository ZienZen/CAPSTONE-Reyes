import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/event.dart';

class EventService {
  final FirebaseFirestore _db;
  EventService([FirebaseFirestore? db]) : _db = db ?? FirebaseFirestore.instance;

  Stream<List<SchoolEvent>> watchEvents() {
    return _db
        .collection('events')
        .orderBy('startsAt')
        .snapshots()
        .map((s) => s.docs.map(SchoolEvent.fromDoc).toList());
  }
}
