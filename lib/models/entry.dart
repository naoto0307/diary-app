import 'package:uuid/uuid.dart';

class Entry {
  final String id;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Entry({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Entry.newEntry(String body) {
    final now = DateTime.now();
    return Entry(
      id: const Uuid().v4(),
      body: body,
      createdAt: now,
      updatedAt: now,
    );
  }

  Entry copyWith({String? body, DateTime? updatedAt}) => Entry(
    id: id,
    body: body ?? this.body,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  factory Entry.fromMap(Map<String, Object?> map) => Entry(
    id: map['id'] as String,
    body: map['body'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );

  Map<String, Object?> toMap() => {
    'id': id,
    'body': body,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
