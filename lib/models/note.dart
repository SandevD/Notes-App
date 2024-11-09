class Note {
  final int status, id;
  final String title, content, createdAt, updatedAt;

  Note({
    required this.id,
    required this.status,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });
}