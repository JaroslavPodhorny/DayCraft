import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:day_craft/models.dart';

class AppState extends ChangeNotifier {
  Map<String, List<TimeBlock>> dayBlocks = {};
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  final Set<String> _knownTitles = {
    'Oběd',
    'Hluboká práce',
    'Schůzka',
    'Cvičení',
    'E-maily',
  };

  List<DayTemplate> templates = [
    DayTemplate(
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
    DayTemplate(
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

  List<BlockPreset> blockPresets = [
    BlockPreset(
      name: 'Hluboká práce',
      color: Colors.blue,
      duration: const Duration(minutes: 90),
    ),
    BlockPreset(
      name: 'Schůzka',
      color: Colors.orange,
      duration: const Duration(minutes: 30),
    ),
    BlockPreset(
      name: 'Cvičení',
      color: Colors.green,
      duration: const Duration(minutes: 60),
    ),
  ];

  List<String> get knownTitles => _knownTitles.toList();

  AppState() {
    _loadData();
  }

  void updateSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load Blocks
    final String? blocksJson = prefs.getString('dayBlocks');
    if (blocksJson != null) {
      final Map<String, dynamic> decoded = jsonDecode(blocksJson);
      dayBlocks = decoded.map(
        (key, value) => MapEntry(
          key,
          (value as List).map((e) => TimeBlock.fromJson(e)).toList(),
        ),
      );
    }

    // Load Templates
    final String? templatesJson = prefs.getString('templates');
    if (templatesJson != null) {
      final List<dynamic> decoded = jsonDecode(templatesJson);
      templates = decoded.map((e) => DayTemplate.fromJson(e)).toList();
    }

    // Load Presets
    final String? presetsJson = prefs.getString('blockPresets');
    if (presetsJson != null) {
      final List<dynamic> decoded = jsonDecode(presetsJson);
      blockPresets = decoded.map((e) => BlockPreset.fromJson(e)).toList();
    }
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save Blocks
    final blocksJson = jsonEncode(
      dayBlocks.map(
        (key, value) => MapEntry(key, value.map((e) => e.toJson()).toList()),
      ),
    );
    prefs.setString('dayBlocks', blocksJson);

    // Save Templates
    final templatesJson = jsonEncode(templates.map((e) => e.toJson()).toList());
    prefs.setString('templates', templatesJson);

    // Save Presets
    final presetsJson = jsonEncode(
      blockPresets.map((e) => e.toJson()).toList(),
    );
    prefs.setString('blockPresets', presetsJson);
  }

  void addBlock(DateTime date, TimeBlock block) {
    String key = DateFormat('yyyy-MM-dd').format(date);
    dayBlocks.putIfAbsent(key, () => []).add(block);
    _knownTitles.add(block.title);
    _saveData();
    notifyListeners();
  }

  void updateBlock(DateTime date, TimeBlock updatedBlock) {
    String key = DateFormat('yyyy-MM-dd').format(date);
    if (dayBlocks.containsKey(key)) {
      final index = dayBlocks[key]!.indexWhere((b) => b.id == updatedBlock.id);
      if (index != -1) {
        dayBlocks[key]![index] = updatedBlock;
        _saveData();
        notifyListeners();
      }
    }
  }

  void removeBlock(DateTime date, String blockId) {
    String key = DateFormat('yyyy-MM-dd').format(date);
    if (dayBlocks.containsKey(key)) {
      dayBlocks[key]!.removeWhere((b) => b.id == blockId);
      _saveData();
      notifyListeners();
    }
  }

  List<TimeBlock> getBlocksForDate(DateTime date) {
    return dayBlocks[DateFormat('yyyy-MM-dd').format(date)] ?? [];
  }

  void saveDayAsTemplate(DateTime date, String templateName) {
    final blocks = getBlocksForDate(date);
    if (blocks.isEmpty) return;

    templates.add(
      DayTemplate(
        name: templateName,
        blocks: blocks.map((b) => b.copyWith(id: const Uuid().v4())).toList(),
      ),
    );
    _saveData();
    notifyListeners();
  }

  void deleteTemplate(String templateId) {
    templates.removeWhere((t) => t.id == templateId);
    _saveData();
    notifyListeners();
  }

  void applyTemplate(String templateId, DateTime date) {
    final DayTemplate template;
    try {
      template = templates.firstWhere((t) => t.id == templateId);
    } catch (e) {
      return; // Template not found
    }
    String key = DateFormat('yyyy-MM-dd').format(date);
    final int now = DateTime.now().microsecondsSinceEpoch;
    List<TimeBlock> newBlocks = template.blocks.asMap().entries.map((entry) {
      final int index = entry.key;
      final TimeBlock b = entry.value;
      return TimeBlock(
        id: '${now}_${index}_${b.title}',
        title: b.title,
        start: b.start,
        end: b.end,
        color: b.color,
      );
    }).toList();

    dayBlocks[key] = newBlocks;

    _knownTitles.addAll(newBlocks.map((b) => b.title));
    _saveData();
    notifyListeners();
  }

  void addBlockPreset(BlockPreset preset) {
    blockPresets.add(preset);
    _saveData();
    notifyListeners();
  }

  void removeBlockPreset(String id) {
    blockPresets.removeWhere((p) => p.id == id);
    _saveData();
    notifyListeners();
  }

  void addBlockFromPreset(DateTime date, BlockPreset preset) {
    final blocks = getBlocksForDate(date);
    // Sort blocks by start time to find gaps
    blocks.sort((a, b) {
      int aMin = a.start.hour * 60 + a.start.minute;
      int bMin = b.start.hour * 60 + b.start.minute;
      return aMin.compareTo(bMin);
    });

    // Default start: 8:00 AM or Current Time (rounded to next 15 min)
    int startMinutes = 8 * 60;
    if (DateUtils.isSameDay(date, DateTime.now())) {
      final now = TimeOfDay.now();
      int nowMinutes = now.hour * 60 + now.minute;
      startMinutes = ((nowMinutes / 15).ceil() * 15);
    }

    int durationMinutes = preset.duration.inMinutes;

    // Find first gap that fits the duration
    for (var block in blocks) {
      int blockStart = block.start.hour * 60 + block.start.minute;
      int blockEnd = block.end.hour * 60 + block.end.minute;

      if (startMinutes + durationMinutes <= blockStart) {
        // Fits before this block
        break;
      }
      // Try after this block
      if (startMinutes < blockEnd) {
        startMinutes = blockEnd;
      }
    }

    final start = TimeOfDay(
      hour: startMinutes ~/ 60,
      minute: startMinutes % 60,
    );
    final endMinutes = startMinutes + durationMinutes;
    final end = TimeOfDay(hour: endMinutes ~/ 60, minute: endMinutes % 60);

    addBlock(
      date,
      TimeBlock(
        id: const Uuid().v4(),
        title: preset.name,
        start: start,
        end: end,
        color: preset.color,
      ),
    );
  }
}
