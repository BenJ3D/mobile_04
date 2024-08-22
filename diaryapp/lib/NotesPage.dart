import 'package:diaryapp/services/NoteService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'icon_list.dart';

class NotesPage extends StatefulWidget {
  NotesPage();

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final NoteService _noteService = NoteService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _noteService.setUpdateCallback(() {
      if (mounted) {
        setState(() {});
      }
    });
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    await _noteService.fetchNotes();
    setState(() => _isLoading = false);
  }

  Future<bool?> _confirmDelete(BuildContext context) {
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
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _showNoteDetailsDialog(Map<String, dynamic> note, String noteKey) {
    final DateTime date =
        DateTime.fromMillisecondsSinceEpoch(note['date'] as int);
    final String formattedDate = DateFormat('dd/MM/yyyy').format(date);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            note['title'],
            style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
                fontWeight: FontWeight.w600),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('$formattedDate',
                    style: const TextStyle(
                      fontSize: 15,
                    )),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Mood:',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(
                      width: 40,
                    ),
                    Text(
                      '${moodIcons[note['icon']] ?? note['icon']}',
                      style: const TextStyle(fontSize: 32),
                    ), // Afficher l'humeur ou le texte brut
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Text:',
                  style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 5),
                Text(note['text']),
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
                final confirm = await _confirmDelete(context);
                if (confirm == true) {
                  await _noteService.deleteNote(noteKey);
                  _loadNotes();
                  Navigator.of(context).pop(); // Fermer le popup de détails
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your last diary entries'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: _loadNotes,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _noteService.notes.isEmpty
                ? const Center(child: Text('No notes found'))
                : ListView.builder(
                    itemCount: _noteService.notes.length >= 15
                        ? 15
                        : _noteService.notes.length,
                    itemBuilder: (context, index) {
                      final note = _noteService.notes[index];
                      final String noteKey = note['key'];

                      final DateTime date = DateTime.fromMillisecondsSinceEpoch(
                          note['date'] as int);
                      final String formattedDate =
                          DateFormat('dd/MM/yyyy').format(date);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 15),
                        child: InkWell(
                          onTap: () {
                            _showNoteDetailsDialog(note,
                                noteKey); // Afficher les détails de la note
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        note['title'],
                                        style: const TextStyle(fontSize: 22),
                                      ),
                                      const SizedBox(
                                          height:
                                              4), // Espace entre le titre et la date
                                      Text(
                                        formattedDate,
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  moodIcons[note['icon']] ?? note['icon'],
                                  style: const TextStyle(
                                      fontSize:
                                          30), // Taille réduite de l'émoticône
                                ),
                                const SizedBox(
                                    width:
                                        42), // Espace entre l'émoticône et le bouton de suppression
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.blueGrey),
                                  onPressed: () async {
                                    final confirm =
                                        await _confirmDelete(context);
                                    if (confirm == true) {
                                      await _noteService.deleteNote(noteKey);
                                      _loadNotes();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ));
  }
}
