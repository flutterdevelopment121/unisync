import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Add this import
import 'dart:convert';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  String? _result;
  bool _loading = false;
  TextEditingController _controller = TextEditingController();

  Future<void> _insertTimetableRows(List<Map<String, dynamic>> rows) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _result = 'User not authenticated.';
      });
      return;
    }
    setState(() => _loading = true);

    final dataWithUser = rows.map((row) => {
      ...row,
      'user_id': user.id,
    }).toList();

    final response = await Supabase.instance.client
        .from('timetable')
        .insert(dataWithUser)
        .select();

    setState(() {
      _loading = false;
      _result = response.toString();
    });
  }

  void _parseTimetable() async {
    final lines = _controller.text.split('\n');
    final parsed = lines
        .map((line) {
          final parts = line.split(',');
          if (parts.length == 5) {
            return {
              'day': parts[0].trim(),
              'time': parts[1].trim(),
              'subject': parts[2].trim(),
              'teacher': parts[3].trim(),
              'duration': parts[4].trim(),
            };
          }
          return null;
        })
        .where((row) => row != null)
        .toList();

    await _insertTimetableRows(parsed.cast<Map<String, dynamic>>());
  }

  @override
  Widget build(BuildContext context) {
    const chatGptPrompt = '''
Please convert this timetable to the following format (one entry per line):
Day, Time, Subject, Teacher, Duration

Notes:
- Combine consecutive classes with the same subject into 2 or 3-hour blocks.
- Include all periods, including the last slot (2:35–3:30 PM).
- Ensure teacher names and subject codes are preserved.

Example output:
Monday, 9:00, CST 401 - Artificial Intelligence, Ms. Rini A P, 1 hour
Monday, 12:45, CSQ 413 - Seminar, Ms. Jiji A J, 3 hours
''';

    return Scaffold(
      appBar: AppBar(title: const Text('Timetable Entry')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      "Tip: Use ChatGPT to convert your timetable into this format.\n\n$chatGptPrompt",
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.copy,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    tooltip: 'Copy prompt',
                    onPressed: () {
                      Clipboard.setData(
                        const ClipboardData(text: chatGptPrompt),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Prompt copied!')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 10,
              decoration: const InputDecoration(
                hintText:
                    'Paste timetable here:\nDay, Time, Subject, Teacher, Duration',
                border: OutlineInputBorder(),
              ),
            ),
            ElevatedButton(
              onPressed: _loading ? null : _parseTimetable,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Save to Database'),
            ),
            if (_result != null)
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _result ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
