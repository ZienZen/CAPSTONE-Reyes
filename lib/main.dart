// CAPSTONE_REYES - School Event RSVP App
// Data: Firebase Realtime Database (REST). Events have full CRUD; students RSVP by ID.
// Flow: Student ID -> Home (All / My Events) -> Event detail -> Create / Edit event.

import 'package:material_ui/material_ui.dart';

import 'screens/home_screen.dart';
import 'screens/student_id_screen.dart';
import 'services/event_service.dart';
import 'services/event_store.dart';
import 'services/student_session.dart';

void main() => runApp(const EventApp());

class EventApp extends StatelessWidget {
  /// Pass a [service] to run the app against a fake (used by tests).
  final EventService? service;
  final String? initialStudentId;
  const EventApp({super.key, this.service, this.initialStudentId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Events',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: _Root(service: service ?? EventService(), initialStudentId: initialStudentId),
    );
  }
}

class _Root extends StatefulWidget {
  final EventService service;
  final String? initialStudentId;
  const _Root({required this.service, this.initialStudentId});

  @override
  State<_Root> createState() => _RootState();
}

class _RootState extends State<_Root> {
  EventStore? _store;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    String? id = widget.initialStudentId;
    if (id == null) {
      try {
        id = await StudentSession.load();
      } catch (_) {
        id = null;
      }
    }
    if (!mounted) return;
    setState(() {
      _store = id == null ? null : EventStore(widget.service, id);
      _loading = false;
    });
  }

  Future<void> _signIn(String id) async {
    try {
      await StudentSession.save(id);
    } catch (_) {}
    setState(() => _store = EventStore(widget.service, id));
  }

  Future<void> _signOut() async {
    try {
      await StudentSession.clear();
    } catch (_) {}
    setState(() => _store = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final store = _store;
    if (store == null) return StudentIdScreen(onSubmit: _signIn);
    return HomeScreen(key: ValueKey(store.studentId), store: store, onSignOut: _signOut);
  }
}
