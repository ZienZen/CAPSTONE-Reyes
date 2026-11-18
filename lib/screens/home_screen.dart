import 'package:flutter/material.dart';

import '../data/seed_events.dart';
import '../services/event_service.dart';
import '../services/student_session.dart';
import 'events_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'student_id_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _studentId;
  bool _loading = true;
  final _events = EventService();

  @override
  void initState() {
    super.initState();
    seedEventsIfEmpty(FirebaseFirestore.instance);
    StudentSession.load().then((id) {
      if (!mounted) return;
      setState(() {
        _studentId = id;
        _loading = false;
      });
    });
  }

  Future<void> _setId(String id) async {
    await StudentSession.save(id);
    setState(() => _studentId = id);
  }

  Future<void> _signOut() async {
    await StudentSession.clear();
    setState(() => _studentId = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_studentId == null) {
      return StudentIdScreen(onSubmit: _setId);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('School Events'),
        actions: [
          IconButton(
            tooltip: 'Change student ID',
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
          ),
        ],
      ),
      body: EventsList(service: _events),
    );
  }
}
