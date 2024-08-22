import 'package:diaryapp/services/NoteService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your last diary entries'),
        // actions: [
        //   IconButton(
        //     icon: Icon(Icons.refresh),
        //     onPressed: _loadNotes,
        //   ),
        // ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _noteService.notes.isEmpty
              ? const Center(child: Text('No notes found'))
              : ListView.builder(
                  itemCount: _noteService.notes.length >= 5
                      ? 5
                      : _noteService.notes
                          .length, // Utilisez la longueur réelle de la liste
                  itemBuilder: (context, index) {
                    final note = _noteService.notes[index];
                    // Convertir le timestamp en DateTime
                    final DateTime date = DateTime.fromMillisecondsSinceEpoch(
                        note['date'] as int);
                    // Formater la date
                    final String formattedDate =
                        DateFormat('dd/MM/yyyy HH:mm').format(date);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      child: ListTile(
                        title: Text(note['title']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(note['text']),
                            SizedBox(
                                height: 4), // Espace entre le texte et la date
                            Text(
                              formattedDate,
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: Text(note['icon']),
                        onTap: () {
                          // Action on tap
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
