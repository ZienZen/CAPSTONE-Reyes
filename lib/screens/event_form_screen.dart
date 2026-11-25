import 'package:material_ui/material_ui.dart';

import '../models/event.dart';
import '../services/event_store.dart';
import '../utils/format.dart';

/// Screen 4: create a new event, or edit one when [event] is given.
class EventFormScreen extends StatefulWidget {
  final EventStore store;
  final SchoolEvent? event;
  const EventFormScreen({super.key, required this.store, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _location;
  late final TextEditingController _description;
  late DateTime _startsAt;
  bool _saving = false;

  bool get _editing => widget.event != null;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    _title = TextEditingController(text: e?.title ?? '');
    _location = TextEditingController(text: e?.location ?? '');
    _description = TextEditingController(text: e?.description ?? '');
    final soon = DateTime.now().add(const Duration(days: 7));
    _startsAt = e?.startsAt ?? DateTime(soon.year, soon.month, soon.day, 9);
  }

  @override
  void dispose() {
    _title.dispose();
    _location.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = _startsAt.isBefore(now) ? _startsAt : now;
    final d = await showDatePicker(
      context: context,
      initialDate: _startsAt,
      firstDate: DateTime(first.year, first.month, first.day),
      lastDate: DateTime(now.year + 5),
    );
    if (d == null) return;
    setState(() => _startsAt = DateTime(d.year, d.month, d.day, _startsAt.hour, _startsAt.minute));
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt),
    );
    if (t == null) return;
    setState(() =>
        _startsAt = DateTime(_startsAt.year, _startsAt.month, _startsAt.day, t.hour, t.minute));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    final e = SchoolEvent(
      id: widget.event?.id ?? '',
      title: _title.text.trim(),
      location: _location.text.trim(),
      description: _description.text.trim(),
      startsAt: _startsAt,
    );
    try {
      _editing ? await widget.store.update(e) : await widget.store.add(e);
      nav.pop();
    } catch (err) {
      messenger.showSnackBar(SnackBar(content: Text('$err')));
      if (mounted) setState(() => _saving = false);
    }
  }

  String? _required(String? v, String label) =>
      (v == null || v.trim().isEmpty) ? '$label is required' : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit event' : 'New event')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
              validator: (v) => _required(v, 'Title'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _location,
              decoration:
                  const InputDecoration(labelText: 'Location', border: OutlineInputBorder()),
              validator: (v) => _required(v, 'Location'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _description,
              minLines: 3,
              maxLines: 5,
              decoration:
                  const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              validator: (v) => _required(v, 'Description'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(formatDate(_startsAt)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.access_time),
                    label: Text(formatTime(_startsAt)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_editing ? 'Save changes' : 'Create event'),
            ),
          ],
        ),
      ),
    );
  }
}
