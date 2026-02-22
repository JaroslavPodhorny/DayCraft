import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:day_craft/models.dart';

class AppState extends ChangeNotifier {
  Map<String, List<TimeBlock>> dayBlocks = {};

  final Set<String> _knownTitles = {
    'Oběd',
    'Hluboká práce',
    'Schůzka',
    'Cvičení',
    'E-maily',
  };

  List<TimeBlockTemplate> templates = [
    TimeBlockTemplate(
      name: 'Pracovní den',
      blocks: [
        TimeBlock(
          id: 't1',
          title: 'Ranní porada',
          start: const TimeOfDay(hour: 9, minute: 0),
          end: const TimeOfDay(hour: 9, minute: 30),
          color: Colors.orange,
        ),
        TimeBlock(
          id: 't2',
          title: 'Hluboká práce',
          start: const TimeOfDay(hour: 9, minute: 30),
          end: const TimeOfDay(hour: 12, minute: 0),
          color: Colors.blue,
        ),
      ],
    ),
    TimeBlockTemplate(
      name: 'Víkend',
      blocks: [
        TimeBlock(
          id: 't3',
          title: 'Čtení',
          start: const TimeOfDay(hour: 10, minute: 0),
          end: const TimeOfDay(hour: 11, minute: 30),
          color: Colors.green,
        ),
      ],
    ),
  ];

  List<String> get knownTitles => _knownTitles.toList();

  void addBlock(DateTime date, TimeBlock block) {
    String key = DateFormat('yyyy-MM-dd').format(date);
    dayBlocks.putIfAbsent(key, () => []).add(block);
    _knownTitles.add(block.title);
    notifyListeners();
  }

  void updateBlock(DateTime date, TimeBlock updatedBlock) {
    String key = DateFormat('yyyy-MM-dd').format(date);
    if (dayBlocks.containsKey(key)) {
      final index = dayBlocks[key]!.indexWhere((b) => b.id == updatedBlock.id);
      if (index != -1) {
        dayBlocks[key]![index] = updatedBlock;
        notifyListeners();
      }
    }
  }

  void removeBlock(DateTime date, String blockId) {
    String key = DateFormat('yyyy-MM-dd').format(date);
    if (dayBlocks.containsKey(key)) {
      dayBlocks[key]!.removeWhere((b) => b.id == blockId);
      notifyListeners();
    }
  }

  List<TimeBlock> getBlocksForDate(DateTime date) {
    return dayBlocks[DateFormat('yyyy-MM-dd').format(date)] ?? [];
  }

  void saveCurrentDayAsTemplate(DateTime date, String templateName) {
    final blocks = getBlocksForDate(date);
    if (blocks.isEmpty) return;

    templates.add(
      TimeBlockTemplate(
        name: templateName,
        blocks: blocks.map((b) => b.copyWith(id: '')).toList(),
      ),
    );
    notifyListeners();
  }

  void applyTemplate(DateTime date, TimeBlockTemplate template) {
    String key = DateFormat('yyyy-MM-dd').format(date);
    List<TimeBlock> newBlocks = template.blocks.map((b) {
      return TimeBlock(
        id: DateTime.now().microsecondsSinceEpoch.toString() + b.title,
        title: b.title,
        start: b.start,
        end: b.end,
        color: b.color,
      );
    }).toList();

    if (dayBlocks.containsKey(key)) {
      dayBlocks[key]!.addAll(newBlocks);
    } else {
      dayBlocks[key] = newBlocks;
    }

    _knownTitles.addAll(newBlocks.map((b) => b.title));
    notifyListeners();
  }
}
