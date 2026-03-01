import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:day_craft/app_state.dart';
import 'package:day_craft/timeline_block.dart';
import 'package:day_craft/smart_add_sheet.dart';
import 'package:day_craft/template_screen.dart';
import 'package:day_craft/models.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final selectedDate = appState.selectedDate;
    var blocks = appState.getBlocksForDate(selectedDate);
    const double hourHeight = 80.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 90,
        title: GestureDetector(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: Theme.of(context).primaryColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null && picked != selectedDate) {
              context.read<AppState>().updateSelectedDate(picked);
            }
          },
          child: Row(
            children: [
              Text(
                DateFormat('d').format(selectedDate),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMMM', 'cs').format(selectedDate).toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.secondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        DateFormat('EEEE', 'cs').format(selectedDate),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onBackground,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(12),
              ),
              icon: const Icon(Icons.copy_all_rounded, size: 22),
              tooltip: "Načíst šablonu",
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TemplateScreen()),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(12),
              ),
              icon: const Icon(Icons.save_alt_rounded, size: 22),
              tooltip: "Uložit jako šablonu",
              onPressed: () => _showSaveTemplateDialog(context, selectedDate),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: SizedBox(
          height: 24 * hourHeight,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(24, (index) {
                  return Container(
                    height: hourHeight,
                    decoration: const BoxDecoration(),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Center(
                            child: Text(
                              "$index:00",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Theme.of(context).dividerColor,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              ...blocks.map((block) {
                return DraggableTimelineBlock(
                  key: ValueKey(block.id),
                  block: block,
                  hourHeight: hourHeight,
                  onUpdate: (updatedBlock) {
                    context.read<AppState>().updateBlock(
                      selectedDate,
                      updatedBlock,
                    );
                  },
                  onTap: () =>
                      _showEditBlockSheet(context, selectedDate, block),
                );
              }),
              if (DateUtils.isSameDay(selectedDate, DateTime.now()))
                CurrentTimeIndicator(hourHeight: hourHeight),
            ],
          ),
        ),
      ),
    );
  }

  void _showSaveTemplateDialog(BuildContext context, DateTime date) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Uložit jako šablonu"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(hintText: "Název šablony"),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Zrušit"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  context.read<AppState>().saveDayAsTemplate(
                    date,
                    nameController.text,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Šablona uložena!")),
                  );
                }
              },
              child: const Text("Uložit"),
            ),
          ],
        );
      },
    );
  }

  void _showEditBlockSheet(
    BuildContext context,
    DateTime date,
    TimeBlock block,
  ) {
    final TextEditingController titleController = TextEditingController(
      text: block.title,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                decoration: InputDecoration(
                  hintText: "Název bloku",
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                ),
              ),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _colorOption(context, date, block, Colors.blueAccent),
                  _colorOption(context, date, block, Colors.orangeAccent),
                  _colorOption(context, date, block, Colors.greenAccent),
                  _colorOption(context, date, block, Colors.purpleAccent),
                  _colorOption(context, date, block, Colors.redAccent),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: const Text(
                        "Smazat blok",
                        style: TextStyle(color: Colors.red),
                      ),
                      onPressed: () {
                        context.read<AppState>().removeBlock(date, block.id);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).cardColor,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onBackground,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text("Uložit jako blok"),
                      onPressed: () {
                        _saveBlockAsPreset(context, block);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text("Uložit"),
                      onPressed: () {
                        context.read<AppState>().updateBlock(
                          date,
                          block.copyWith(title: titleController.text),
                        );
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _saveBlockAsPreset(BuildContext context, TimeBlock block) {
    final TextEditingController nameController = TextEditingController(
      text: block.title,
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Uložit jako znovupoužitelný blok"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Název bloku"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Zrušit"),
          ),
          ElevatedButton(
            onPressed: () {
              final duration = Duration(
                minutes:
                    (block.end.hour * 60 + block.end.minute) -
                    (block.start.hour * 60 + block.start.minute),
              );
              context.read<AppState>().addBlockPreset(
                BlockPreset(
                  name: nameController.text,
                  color: block.color,
                  duration: duration,
                ),
              );
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close sheet
            },
            child: const Text("Uložit"),
          ),
        ],
      ),
    );
  }

  Widget _colorOption(
    BuildContext context,
    DateTime date,
    TimeBlock block,
    Color color,
  ) {
    bool isSelected = block.color.value == color.value;
    return GestureDetector(
      onTap: () {
        context.read<AppState>().updateBlock(
          date,
          block.copyWith(color: color),
        );
        Navigator.pop(context);
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: Theme.of(context).colorScheme.onBackground,
                  width: 3,
                )
              : null,
        ),
      ),
    );
  }
}

class CurrentTimeIndicator extends StatefulWidget {
  final double hourHeight;
  const CurrentTimeIndicator({super.key, required this.hourHeight});

  @override
  State<CurrentTimeIndicator> createState() => _CurrentTimeIndicatorState();
}

class _CurrentTimeIndicatorState extends State<CurrentTimeIndicator> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = TimeOfDay.now();
    final top = (now.hour + now.minute / 60.0) * widget.hourHeight;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: Row(
        children: [
          const SizedBox(width: 50),
          const CircleAvatar(radius: 4, backgroundColor: Colors.redAccent),
          Expanded(
            child: Container(
              height: 2,
              color: Colors.redAccent.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
