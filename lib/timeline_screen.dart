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
    DateTime today = DateTime.now();
    var blocks = context.watch<AppState>().getBlocksForDate(today);
    const double hourHeight = 80.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 90,
        title: Row(
          children: [
            Text(
              DateFormat('d').format(today),
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM', 'cs').format(today).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  DateFormat('EEEE', 'cs').format(today),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF1C1C1E),
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
                children: List.generate(24, (index) {
                  return Container(
                    height: hourHeight,
                    decoration: const BoxDecoration(
                      // Removed bottom border for cleaner look, using Divider below
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Center(
                            child: Text(
                              "$index:00",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.white.withOpacity(0.08),
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
                    context.read<AppState>().updateBlock(today, updatedBlock);
                  },
                  onTap: () => _showEditBlockSheet(context, today, block),
                );
              }).toList(),
            ],
          ),
        ),
      ),
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
      backgroundColor: const Color(0xFF1C1C1E),
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                decoration: const InputDecoration(
                  hintText: "Název bloku",
                  hintStyle: TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white10,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: InputBorder.none,
                ),
              ),
              const Divider(color: Colors.white24),
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
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      child: const Text(
                        "Uložit",
                        style: TextStyle(color: Colors.white),
                      ),
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
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
      ),
    );
  }
}
