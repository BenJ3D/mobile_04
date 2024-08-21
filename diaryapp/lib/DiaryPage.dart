import 'package:diaryapp/NotesPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DiaryPage extends StatelessWidget {
  DiaryPage({super.key});

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _addTestData() async {
    // Récupérer l'utilisateur actuellement connecté
    User? currentUser = _auth.currentUser;

    // Vérifiez si l'utilisateur est bien connecté
    if (currentUser != null) {
      String uid = currentUser.uid;
      String usermail = currentUser.email ?? 'example@email.com';
      // String usermail = 'ben.ducrocq@gmail.com';
      String usermailFormat = usermail.replaceAll('.' , '_');

      // Créer une nouvelle note avec une clé unique générée par push()
      DatabaseReference newNoteRef = _database.child('notes').push();

      Map<String, dynamic> newNote = {
        "date": DateTime.now().millisecondsSinceEpoch,
        "icon": "satisfied",
        "text": "This is a new test note 2",
        "title": "New Test Note 2",
        "usermail" : usermail,
      };

      // Ajouter la nouvelle note à Firebase
      newNoteRef.set(newNote).then((_) {
        print("New note added successfully");
      }).catchError((error) {
        print("Failed to add note: $error");
      });
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
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const Text('Welcome to your Diary'),
            ElevatedButton(
              onPressed: _addTestData,
              child: const Text("Add Test Data"),
            ),
            NotesPage(usermail: usermail)
          ],
        ),
      ),
    );
  }
}
