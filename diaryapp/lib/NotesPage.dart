import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class NotesPage extends StatefulWidget {
  final String usermail;

  NotesPage({required this.usermail});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref('notes');
  List<Map<String, dynamic>> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotes();
  }
 Future<void> _fetchNotes() async {
    _database.orderByChild('usermail').equalTo(widget.usermail).once().then((DatabaseEvent event) {
      if (event.snapshot.exists()) {
        Map<dynamic, dynamic> notesMap = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _notes = notesMap.entries.map((e) => {
            'key': e.key,
            ...e.value as Map<String, dynamic>
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _notes = [];
          _isLoading = false;
        });
      }
    }).catchError((error) {
      print("Failed to retrieve notes: $error");
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Notes'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _notes.isEmpty
          ? Center(child: Text('No notes found'))
          : ListView.builder(
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            child: ListTile(
              title: Text(note['title']),
              subtitle: Text(note['text']),
              trailing: Text(note['icon']),
              onTap: () {
                // Action on tap, e.g., navigate to detail or edit page
              },
            ),
          );
        },
      ),
    );
  }
}