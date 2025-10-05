import 'package:flutter/material.dart';

class Note {
  final String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  Color? color;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.color,
  });

  Note.create({required this.title, required this.content})
      : id = DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt = DateTime.now(),
        updatedAt = DateTime.now(),
        color = _generatePastelColor();

  static Color _generatePastelColor() {
    final colors = [
      const Color(0xFFFFF0F5), // Lavender blush
      const Color(0xFFF0FFF0), // Honeydew
      const Color(0xFFF0F8FF), // Alice blue
      const Color(0xFFFFFACD), // Lemon chiffon
      const Color(0xFFE6E6FA), // Lavender
      const Color(0xFFF5F5DC), // Beige
    ];
    return colors[DateTime.now().millisecond % colors.length];
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'color': color?.value,
      };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        color: json['color'] != null ? Color(json['color']) : null,
      );
}