import 'package:diaryapp/services/NoteService.dart';
import 'package:diaryapp/utils/dialog_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  String _selectedMood = 'neutral'; // Valeur par défaut

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
    setState(() {
      _isLoading = false;
    });
  }

  void _showAddNoteDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('New Diary Entry'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      maxLength: 50,
                    ),
                    TextField(
                      controller: textController,
                      decoration: const InputDecoration(labelText: 'Text'),
                      maxLines: 3,
                      maxLength: 500,
                    ),
                    const SizedBox(height: 10),
                    const Text('Select your mood:'),
                    DropdownButton<String>(
                      value: _selectedMood,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedMood = newValue ?? 'neutral';
                        });
                      },
                      items: moodIcons.keys
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text('${moodIcons[value]} $value'),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () async {
                    if (titleController.text.isNotEmpty &&
                        textController.text.isNotEmpty) {
                      await _noteService.addNote(
                        titleController.text,
                        textController.text,
                        _selectedMood, // Sauvegarde l'émoticône sélectionnée
                      );
                      _loadNotes();
                      Navigator.of(context).pop();
                    } else {
                      // Vous pouvez ajouter une alerte ici pour indiquer que les champs sont requis
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addNote() async {
    // Récupérer l'utilisateur actuellement connecté
    User? currentUser = _auth.currentUser;

    // Vérifiez si l'utilisateur est bien connecté
    if (currentUser != null) {
      _selectedMood =
          'neutral'; // Réinitialiser la valeur par défaut avant d'afficher le dialogue
      _showAddNoteDialog();
    } else {
      print("No user is signed in");
    }
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
    showNoteDetailsDialog(
        context, note, noteKey, _noteService, _confirmDelete, _loadNotes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueGrey.shade800,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your last diary :',
                style:
                    TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
              Flexible(
                child: Text(
                  '(total entries: ${_noteService.notes.length})',
                  maxLines: 3,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                      fontSize: 14.5),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              onPressed: _loadNotes,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _noteService.notes.isEmpty
                ? const Center(child: Text('No notes found'))
                : Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _noteService.notes.length,
                          itemBuilder: (context, index) {
                            final note = _noteService.notes[index];
                            final String noteKey = note['key'];

                            final DateTime date =
                                DateTime.fromMillisecondsSinceEpoch(
                                    note['date'] as int);
                            final String formattedDate =
                                DateFormat('dd/MM/yyyy').format(date);

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 15),
                              child: InkWell(
                                focusColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                splashColor: Colors.transparent,
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
                                              style:
                                                  const TextStyle(fontSize: 22),
                                            ),
                                            const SizedBox(
                                                height:
                                                    4), // Espace entre le titre et la date
                                            Text(
                                              formattedDate,
                                              style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey),
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
                                      const SizedBox(width: 42),
                                      // Espace entre l'émoticône et le bouton de suppression
                                      IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.blueGrey),
                                        onPressed: () async {
                                          final confirm =
                                              await _confirmDelete(context);
                                          if (confirm == true) {
                                            await _noteService
                                                .deleteNote(noteKey);
                                            await _loadNotes();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _addNote,
                        child: const Text("New diary entry"),
                      ),
                    ],
                  ));
  }
}
