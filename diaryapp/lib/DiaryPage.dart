import 'package:diaryapp/NotesPage.dart';
import 'package:diaryapp/services/NoteService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class DiaryPage extends StatefulWidget {
  DiaryPage();

  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NoteService _noteService = NoteService();

  void _showAddNoteDialog() {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController textController = TextEditingController();
    final TextEditingController iconController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                TextField(
                  controller: iconController,
                  decoration: const InputDecoration(labelText: 'Emoji'),
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
                    iconController.text,
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
  }

  void _addNote() async {
    // Récupérer l'utilisateur actuellement connecté
    User? currentUser = _auth.currentUser;

    // Vérifiez si l'utilisateur est bien connecté
    if (currentUser != null) {
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
