import 'package:flutter/material.dart';

/// Screen 1: enter a student ID (no real auth).
class StudentIdScreen extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  const StudentIdScreen({super.key, required this.onSubmit});

  @override
  State<StudentIdScreen> createState() => _StudentIdScreenState();
}

class _StudentIdScreenState extends State<StudentIdScreen> {
  final _controller = TextEditingController();
  String? _error;

  // Firebase keys can't contain . $ # [ ] /
  static final _valid = RegExp(r'^[A-Za-z0-9_-]+$');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _continue() {
    final id = _controller.text.trim();
    if (id.isEmpty) {
      setState(() => _error = 'Please enter your student ID');
      return;
    }
    if (!_valid.hasMatch(id)) {
      setState(() => _error = 'Use only letters, numbers, - and _');
      return;
    }
    widget.onSubmit(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
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
