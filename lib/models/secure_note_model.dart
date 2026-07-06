class SecureNoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final int? colorValue; // Store color as an integer ARGB value

  SecureNoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.colorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'colorValue': colorValue,
    };
  }

  factory SecureNoteModel.fromMap(Map<String, dynamic> map) {
    return SecureNoteModel(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      createdAt: DateTime.parse(map['createdAt']),
      colorValue: map['colorValue'],
    );
  }
}
