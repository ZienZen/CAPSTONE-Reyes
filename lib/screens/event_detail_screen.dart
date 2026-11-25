import 'package:flutter/material.dart';

import '../services/event_store.dart';
import '../utils/format.dart';
import 'event_form_screen.dart';

/// Screen 3: event details, RSVP, attendee list, edit and delete.
class EventDetailScreen extends StatelessWidget {
  final EventStore store;
  final String eventId;
  const EventDetailScreen({super.key, required this.store, required this.eventId});

  Future<void> _delete(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete event?'),
        content: const Text('This also removes all RSVPs for it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await store.remove(eventId);
      nav.pop();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final event = store.byId(eventId);
        if (event == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Event')),
            body: const Center(child: Text('This event no longer exists.')),
          );
        }
        final going = store.isGoing(eventId);
        final attendees = store.attendees(eventId);
        final text = Theme.of(context).textTheme;
        return Scaffold(
          appBar: AppBar(
            title: const Text('Event details'),
            actions: [
              IconButton(
                tooltip: 'Edit',
                icon: const Icon(Icons.edit),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EventFormScreen(store: store, event: event)),
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                icon: const Icon(Icons.delete),
                onPressed: () => _delete(context),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(event.title, style: text.headlineSmall),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.schedule, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(formatEventTime(event.startsAt))),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.place, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(event.location)),
              ]),
              const SizedBox(height: 16),
              Text(event.description),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: going
                    ? FilledButton.tonalIcon(
                        onPressed: () => _toggle(context),
                        icon: const Icon(Icons.check),
                        label: const Text("You're going - tap to cancel"),
                      )
                    : FilledButton(
                        onPressed: () => _toggle(context),
                        child: const Text('RSVP'),
                      ),
              ),
              const SizedBox(height: 24),
              Text('Attendees (${attendees.length})', style: text.titleMedium),
              const SizedBox(height: 8),
              if (attendees.isEmpty)
                const Text('Nobody yet - be the first!')
              else
                for (final id in attendees)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.person),
                    title: Text(id == store.studentId ? '$id (you)' : id),
                  ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggle(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await store.toggleRsvp(eventId);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}
