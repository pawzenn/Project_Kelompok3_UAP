import 'package:get/get.dart';

import '../../data/models/note.dart';
import '../../data/repositories/notes_repository.dart';

class NotesController extends GetxController {
  final NotesRepository _repo = NotesRepository();

  final notes = <Note>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotes();
  }

  Future<void> loadNotes() async {
    try {
      isLoading.value = true;
      final result = await _repo.fetchNotes();
      notes.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addNote(String title, String? content) async {
    await _repo.addNote(title, content);
    await loadNotes();
  }

  Future<void> editNote(Note note, String title, String? content) async {
    final updated = Note(
      id: note.id,
      userId: note.userId,
      title: title,
      content: content,
      createdAt: note.createdAt,
      updatedAt: DateTime.now(),
      isArchived: note.isArchived,
    );
    await _repo.updateNote(updated);
    await loadNotes();
  }

  Future<void> deleteNote(Note note) async {
    await _repo.deleteNote(note.id);
    notes.remove(note);
  }
}
