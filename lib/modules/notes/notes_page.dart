import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/note.dart';
import 'notes_controller.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotesController());

    return Scaffold(
      appBar: AppBar(title: const Text('Catatan')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.notes.isEmpty) {
          return const Center(child: Text('Belum ada catatan.'));
        }
        return ListView.builder(
          itemCount: controller.notes.length,
          itemBuilder: (context, index) {
            final Note note = controller.notes[index];
            return ListTile(
              title: Text(note.title),
              subtitle: Text(
                note.content ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _showNoteForm(context, controller, note: note),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => controller.deleteNote(note),
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNoteForm(context, controller),
        child: const Icon(Icons.note_add),
      ),
    );
  }

  void _showNoteForm(
    BuildContext context,
    NotesController controller, {
    Note? note,
  }) {
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(note == null ? 'Tambah Catatan' : 'Edit Catatan'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Isi'),
                  maxLines: 4,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                final title = titleController.text.trim();
                final content = contentController.text.trim().isEmpty
                    ? null
                    : contentController.text.trim();
                if (title.isEmpty) return;

                if (note == null) {
                  await controller.addNote(title, content);
                } else {
                  await controller.editNote(note, title, content);
                }

                Get.back();
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }
}
