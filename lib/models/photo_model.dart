class PhotoModel {
  final String id;
  final String fileName; // Encrypted file name
  final String? label;
  final DateTime createdAt;

  PhotoModel({
    required this.id,
    required this.fileName,
    this.label,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fileName': fileName,
      'label': label,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PhotoModel.fromMap(Map<String, dynamic> map) {
    return PhotoModel(
      id: map['id'],
      fileName: map['fileName'],
      label: map['label'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}
