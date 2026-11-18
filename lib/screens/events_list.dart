import 'package:flutter/material.dart';

import '../models/event.dart';
import '../services/event_service.dart';
import '../utils/format.dart';

class EventsList extends StatelessWidget {
  final EventService service;
  const EventsList({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SchoolEvent>>(
      stream: service.watchEvents(),
      builder: (context, snap) {
        if (snap.hasError) {
          return Center(child: Text('Error: ${snap.error}'));
        }
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final events = snap.data!;
        if (events.isEmpty) {
          return const Center(child: Text('No events yet.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: events.length,
          itemBuilder: (_, i) => EventCard(event: events[i]),
        );
      },
    );
  }
}

class EventCard extends StatelessWidget {
  final SchoolEvent event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title, style: t.titleMedium),
            const SizedBox(height: 4),
            Text(formatEventTime(event.startsAt)),
            Text(event.location),
            const SizedBox(height: 8),
            Text(event.description),
          ],
        ),
      ),
    );
  }
}
