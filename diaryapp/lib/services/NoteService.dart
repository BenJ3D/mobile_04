import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class NoteService {
  static final NoteService _instance = NoteService._internal();
  factory NoteService() => _instance;

  NoteService._internal();

  final DatabaseReference _database = FirebaseDatabase.instance.ref('notes');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Function? _updateCallback;
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> get notes => _notes;

  void setUpdateCallback(Function callback) {
    _updateCallback = callback;
  }

  Future<void> fetchNotes() async {
    print('et bah alors ????');
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      print('et bah alors ???? V222222222');
      _notes = [];
      if (_updateCallback != null) {
        _updateCallback!();
      }
      return;
    }

    try {
      final notesRef = _database;
      final query = notesRef.orderByChild('usermail').equalTo(user.email);

      final DatabaseEvent event = await query.once();

      if (event.snapshot.exists) {
        Map<dynamic, dynamic> notesMap =
            event.snapshot.value as Map<dynamic, dynamic>;

        _notes = notesMap.entries.map((entry) {
          String key = entry.key as String;
          Map<String, dynamic> value =
              Map<String, dynamic>.from(entry.value as Map);

          return {
            'key': key,
            ...value,
          };
        }).toList();

        _notes.sort((a, b) {
          int dateA = a['date'] as int;
          int dateB = b['date'] as int;
          return dateB.compareTo(dateA);
        });
      } else {
        _notes = [];
      }
    } catch (error) {
      print("Failed to retrieve notes: $error");
      _notes = [];
    }
  }

  Future<void> addNote(String title, String text, String icon) async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      await _database.push().set({
        'date': ServerValue.timestamp,
        'icon': icon,
        'text': text,
        'title': title,
        'usermail': user.email
      });
      await fetchNotes(); // Refresh the notes after adding
      if (_updateCallback != null) {
        _updateCallback!();
      }
    }
  }

  Future<void> deleteNote(String key) async {
    try {
      await _database.child(key).remove();
      notes.removeWhere((note) => note['key'] == key);
      await fetchNotes(); // Refresh the notes after delete
      if (_updateCallback != null) {
        _updateCallback!();
      }
    } catch (error) {
      print("Failed to delete note: $error");
    }
  }
}
