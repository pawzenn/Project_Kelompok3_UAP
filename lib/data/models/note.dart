class Note {
  final String id;
  final String userId;
  final String title;
  final String? content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isArchived;

  Note({
    required this.id,
    required this.userId,
    required this.title,
    this.content,
    required this.createdAt,
    this.updatedAt,
    this.isArchived = false,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      title: map['title'] as String,
      content: map['content'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
      isArchived: map['is_archived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {'user_id': userId, 'title': title, 'content': content};
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'title': title,
      'content': content,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }
}
