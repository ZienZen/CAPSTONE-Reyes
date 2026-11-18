// CAPSTONE_REYES - School Event RSVP App
// Core: event list, RSVP button, attendee count, "My Events" tab
// Cut: no QR check-in, no calendar export, no real auth (student ID input only)
// Data: dummy in-memory data for now (no Firebase). Resets when the app restarts.

import 'package:flutter/material.dart';

void main() => runApp(const EventApp());

// ---------------------------------------------------------------- Model

class SchoolEvent {
  final String id;
  final String title;
  final String date;
  final String location;
  final String description;

  SchoolEvent({
    required this.id,
    required this.title,
    required this.date,
    required this.location,
    required this.description,
  });

  factory SchoolEvent.fromJson(String id, Map<String, dynamic> j) => SchoolEvent(
        id: id,
        title: j['title'] ?? '',
        date: j['date'] ?? '',
        location: j['location'] ?? '',
        description: j['description'] ?? '',
      );
}

// Dummy event data.
const Map<String, Map<String, String>> seedEvents = {
  'evt1': {
    'title': 'Foundation Day Celebration',
    'date': 'Dec 5, 2026 - 8:00 AM',
    'location': 'School Gymnasium',
    'description': 'Parade, booths, and performances for the whole school.',
  },
  'evt2': {
    'title': 'Science & Tech Fair',
    'date': 'Dec 10, 2026 - 9:00 AM',
    'location': 'Science Building',
    'description': 'Student projects and experiments on display.',
  },
  'evt3': {
    'title': 'Christmas Program',
    'date': 'Dec 18, 2026 - 1:00 PM',
    'location': 'Covered Court',
    'description': 'Caroling, skits, and the class gift exchange.',
  },
  'evt4': {
    'title': 'Intramurals Opening',
    'date': 'Jan 12, 2027 - 7:30 AM',
    'location': 'School Oval',
    'description': 'Opening ceremony and first games of the intramurals.',
  },
  'evt5': {
    'title': 'Career Orientation Day',
    'date': 'Jan 20, 2027 - 10:00 AM',
    'location': 'Auditorium',
    'description': 'Guest speakers talk about college courses and careers.',
  },
};

// ---------------------------------------------------------------- Dummy data store

class Db {
  // { eventId: { studentId: true } } - a few dummy RSVPs so counts are not zero.
  static final Map<String, Map<String, dynamic>> _rsvps = {
    'evt1': {'2024-002': true, '2024-003': true, '2024-004': true},
    'evt2': {'2024-002': true},
    'evt3': {'2024-003': true, '2024-005': true},
  };

  static Future<List<SchoolEvent>> fetchEvents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final list = seedEvents.entries
        .map((e) => SchoolEvent.fromJson(e.key, Map<String, dynamic>.from(e.value)))
        .toList();
    list.sort((a, b) => a.id.compareTo(b.id));
    return list;
  }

  static Future<Map<String, Map<String, dynamic>>> fetchRsvps() async {
    return _rsvps.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v)));
  }

  static Future<void> setRsvp(String eventId, String studentId, bool going) async {
    final map = _rsvps.putIfAbsent(eventId, () => {});
    if (going) {
      map[studentId] = true;
    } else {
      map.remove(studentId);
    }
  }
}

// ---------------------------------------------------------------- App

class EventApp extends StatelessWidget {
  const EventApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Events',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const StudentIdPage(),
    );
  }
}

// ---------------------------------------------------------------- Student ID screen (no auth)

class StudentIdPage extends StatefulWidget {
  const StudentIdPage({super.key});

  @override
  State<StudentIdPage> createState() => _StudentIdPageState();
}

class _StudentIdPageState extends State<StudentIdPage> {
  final _controller = TextEditingController();
  String? _error;

  void _continue() {
    final id = _controller.text.trim();
    if (id.isEmpty) {
      setState(() => _error = 'Please enter your student ID');
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage(studentId: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event, size: 72, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('School Events', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Student ID',
                      border: const OutlineInputBorder(),
                      errorText: _error,
                    ),
                    onSubmitted: (_) => _continue(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(onPressed: _continue, child: const Text('Continue')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Home (tabs)

class HomePage extends StatefulWidget {
  final String studentId;
  const HomePage({super.key, required this.studentId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<SchoolEvent> _events = [];
  Map<String, Map<String, dynamic>> _rsvps = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _events.isEmpty;
      _error = null;
    });
    try {
      final events = await Db.fetchEvents();
      final rsvps = await Db.fetchRsvps();
      if (!mounted) return;
      setState(() {
        _events = events;
        _rsvps = rsvps;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  bool _isGoing(String eventId) => _rsvps[eventId]?.containsKey(widget.studentId) ?? false;

  int _count(String eventId) => _rsvps[eventId]?.length ?? 0;

  Future<void> _toggle(SchoolEvent e) async {
    final going = !_isGoing(e.id);
    // Update the screen right away, then save to the store.
    setState(() {
      final map = Map<String, dynamic>.from(_rsvps[e.id] ?? {});
      going ? map[widget.studentId] = true : map.remove(widget.studentId);
      _rsvps = {..._rsvps, e.id: map};
    });
    try {
      await Db.setRsvp(e.id, widget.studentId, going);
    } catch (err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$err')));
      _load(); // roll back to the real data
    }
  }

  Widget _eventList(List<SchoolEvent> events, {required String emptyText}) {
    if (events.isEmpty) {
      return RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          children: [
            SizedBox(height: 200, child: Center(child: Text(emptyText))),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: events.length,
        itemBuilder: (_, i) => EventCard(
          event: events[i],
          going: _isGoing(events[i].id),
          count: _count(events[i].id),
          onToggle: () => _toggle(events[i]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myEvents = _events.where((e) => _isGoing(e.id)).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('School Events'),
          actions: [
            Center(child: Text('ID: ${widget.studentId}')),
            IconButton(
              tooltip: 'Switch student',
              icon: const Icon(Icons.logout),
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const StudentIdPage()),
              ),
            ),
          ],
          bottom: TabBar(
            tabs: [
              const Tab(text: 'All Events'),
              Tab(text: 'My Events (${myEvents.length})'),
            ],
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(onPressed: _load, child: const Text('Retry')),
                        ],
                      ),
                    ),
                  )
                : TabBarView(
                    children: [
                      _eventList(_events, emptyText: 'No events yet'),
                      _eventList(myEvents, emptyText: "You haven't RSVP'd to any events yet"),
                    ],
                  ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Event card

class EventCard extends StatelessWidget {
  final SchoolEvent event;
  final bool going;
  final int count;
  final VoidCallback onToggle;

  const EventCard({
    super.key,
    required this.event,
    required this.going,
    required this.count,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: text.titleLarge),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.schedule, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(event.date)),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.place, size: 16),
              const SizedBox(width: 6),
              Expanded(child: Text(event.location)),
            ]),
            const SizedBox(height: 8),
            Text(event.description),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.people, size: 18),
                const SizedBox(width: 6),
                Text('$count attending'),
                const Spacer(),
                going
                    ? FilledButton.tonalIcon(
                        onPressed: onToggle,
                        icon: const Icon(Icons.check),
                        label: const Text("Going"),
                      )
                    : FilledButton(onPressed: onToggle, child: const Text('RSVP')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
