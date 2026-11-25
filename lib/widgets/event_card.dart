import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/format.dart';

class EventCard extends StatelessWidget {
  final SchoolEvent event;
  final bool going;
  final int count;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const EventCard({
    super.key,
    required this.event,
    required this.going,
    required this.count,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
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
                Expanded(child: Text(formatEventTime(event.startsAt))),
              ]),
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.place, size: 16),
                const SizedBox(width: 6),
                Expanded(child: Text(event.location)),
              ]),
              const SizedBox(height: 8),
              Text(event.description, maxLines: 2, overflow: TextOverflow.ellipsis),
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
                          label: const Text('Going'),
                        )
                      : FilledButton(onPressed: onToggle, child: const Text('RSVP')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
