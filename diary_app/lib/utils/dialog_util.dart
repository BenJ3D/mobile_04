import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:diaryapp/services/NoteService.dart';
import '../icon_list.dart';
import 'text_util.dart'; // Importer le fichier utilitaire

void showNoteDetailsDialog(
    BuildContext context,
    Map<String, dynamic> note,
    String noteKey,
    NoteService noteService,
    Future<bool?> Function(BuildContext) confirmDelete,
    VoidCallback refreshNotes) {
  final DateTime date =
      DateTime.fromMillisecondsSinceEpoch(note['date'] as int);
  final String formattedDate = DateFormat('dd/MM/yyyy').format(date);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              buildDetailSection('Date:', formattedDate, color: Colors.black),
              Row(
                children: [
                  const Text(
                    'Mood:',
                    style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.black,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    width: 40,
                  ),
                  Text(
                    '${moodIcons[note['icon']] ?? note['icon']}',
                    style: const TextStyle(fontSize: 36),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              buildDetailSection('Title:', note['title'], color: Colors.black),
              buildDetailSection('Text:', note['text'], color: Colors.black),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              final confirm = await confirmDelete(context);
              if (confirm == true) {
                await noteService.deleteNote(noteKey);
                refreshNotes();
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}

Future<bool?> showDeleteConfirmationDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}
