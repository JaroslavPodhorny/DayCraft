import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'startHour': start.hour,
    'startMinute': start.minute,
    'endHour': end.hour,
    'endMinute': end.minute,
    'color': color.value,
  };

  factory TimeBlock.fromJson(Map<String, dynamic> json) {
    return TimeBlock(
      id: json['id'],
      title: json['title'],
      start: TimeOfDay(hour: json['startHour'], minute: json['startMinute']),
      end: TimeOfDay(hour: json['endHour'], minute: json['endMinute']),
      color: Color(json['color']),
    );
  }
}

class DayTemplate {
  final String id;
  final String name;
  final List<TimeBlock> blocks;

  DayTemplate({String? id, required this.name, required this.blocks})
    : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'blocks': blocks.map((b) => b.toJson()).toList(),
  };

  factory DayTemplate.fromJson(Map<String, dynamic> json) {
    return DayTemplate(
      id: json['id'],
      name: json['name'],
      blocks: (json['blocks'] as List)
          .map((b) => TimeBlock.fromJson(b))
          .toList(),
    );
  }
}

class BlockPreset {
  final String id;
  final String name;
  final Color color;
  final Duration duration;

  BlockPreset({
    String? id,
    required this.name,
    required this.color,
    this.duration = const Duration(minutes: 60),
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'color': color.value,
    'durationMinutes': duration.inMinutes,
  };

  factory BlockPreset.fromJson(Map<String, dynamic> json) {
    return BlockPreset(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
      duration: Duration(minutes: json['durationMinutes'] ?? 60),
    );
  }
}
