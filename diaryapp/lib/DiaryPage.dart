import 'package:diaryapp/NotesPage.dart';
import 'package:diaryapp/services/NoteService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'icon_list.dart';

class DiaryPage extends StatefulWidget {
  DiaryPage();

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NoteService _noteService = NoteService();

  String _selectedMood = 'neutral'; // Valeur par défaut

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
                    ),
                    TextField(
                      controller: textController,
                      decoration: const InputDecoration(labelText: 'Text'),
                      maxLines: 3,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              // Révoquer les autorisations Google
              final GoogleSignIn googleSignIn = GoogleSignIn();
              await googleSignIn.signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Welcome to your Diary'),
            Expanded(child: NotesPage()),
            ElevatedButton(
              onPressed: _addNote,
              child: const Text("New diary entry"),
            ),
            const SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }
}
