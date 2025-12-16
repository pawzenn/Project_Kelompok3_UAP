import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note.dart';

class NotesRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Note>> fetchNotes() async {
    final userId = _client.auth.currentUser!.id;
    final List<dynamic> rows = await _client
        .from('notes')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return rows.map((e) => Note.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> addNote(String title, String? content) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('notes').insert({
      'user_id': userId,
      'title': title,
      'content': content,
    });
  }

  Future<void> updateNote(Note note) async {
    await _client.from('notes').update(note.toUpdateMap()).eq('id', note.id);
  }

  Future<void> deleteNote(String id) async {
    await _client.from('notes').delete().eq('id', id);
  }
}
