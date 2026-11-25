import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/event_store.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';
import 'event_form_screen.dart';

/// Screen 2: All Events / My Events tabs, RSVP, and the entry point for Add.
class HomeScreen extends StatefulWidget {
  final EventStore store;
  final VoidCallback onSignOut;
  const HomeScreen({super.key, required this.store, required this.onSignOut});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  EventStore get store => widget.store;

  @override
  void initState() {
    super.initState();
    store.load();
  }

  void _toast(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
  }

  Future<void> _toggle(SchoolEvent e) async {
    try {
      await store.toggleRsvp(e.id);
    } catch (err) {
      _toast(err);
    }
  }

  void _open(SchoolEvent e) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EventDetailScreen(store: store, eventId: e.id)),
    );
  }

  Future<void> _seed() async {
    try {
      await store.seedSamples();
    } catch (err) {
      _toast(err);
    }
  }

  Widget _list(List<SchoolEvent> events, {required String emptyText, bool offerSeed = false}) {
    if (events.isEmpty) {
      return RefreshIndicator(
        onRefresh: store.load,
        child: ListView(
          children: [
            const SizedBox(height: 120),
            Center(child: Text(emptyText)),
            if (offerSeed) ...[
              const SizedBox(height: 16),
              Center(
                child: OutlinedButton(
                  onPressed: _seed,
                  child: const Text('Load sample events'),
                ),
              ),
            ],
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: store.load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
        itemCount: events.length,
        itemBuilder: (_, i) {
          final e = events[i];
          return EventCard(
            event: e,
            going: store.isGoing(e.id),
            count: store.count(e.id),
            onTap: () => _open(e),
            onToggle: () => _toggle(e),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final my = store.myEvents;
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('School Events'),
              actions: [
                Center(child: Text('ID: ${store.studentId}')),
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh),
                  onPressed: store.load,
                ),
                IconButton(
                  tooltip: 'Switch student',
                  icon: const Icon(Icons.logout),
                  onPressed: widget.onSignOut,
                ),
              ],
              bottom: TabBar(
                tabs: [
                  const Tab(text: 'All Events'),
                  Tab(text: 'My Events (${my.length})'),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EventFormScreen(store: store)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('New event'),
            ),
            body: store.loading
                ? const Center(child: CircularProgressIndicator())
                : store.error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(store.error!, textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              FilledButton(onPressed: store.load, child: const Text('Retry')),
                            ],
                          ),
                        ),
                      )
                    : TabBarView(
                        children: [
                          _list(store.events, emptyText: 'No events yet', offerSeed: true),
                          _list(my, emptyText: "You haven't RSVP'd to any events yet"),
                        ],
                      ),
          ),
        );
      },
    );
  }
}
