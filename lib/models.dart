import 'package:flutter/material.dart';

class TimeBlock {
  final String id;
  final String title;
  final TimeOfDay start;
  final TimeOfDay end;
  final Color color;

  TimeBlock({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    this.color = Colors.blueAccent,
  });

  TimeBlock copyWith({
    String? id,
    String? title,
    TimeOfDay? start,
    TimeOfDay? end,
    Color? color,
  }) {
    return TimeBlock(
      id: id ?? this.id,
      title: title ?? this.title,
      start: start ?? this.start,
      end: end ?? this.end,
      color: color ?? this.color,
    );
  }
}

class TimeBlockTemplate {
  final String name;
  final List<TimeBlock> blocks;

  TimeBlockTemplate({required this.name, required this.blocks});
}
