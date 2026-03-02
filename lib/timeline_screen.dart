import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:day_craft/app_state.dart';
import 'package:day_craft/timeline_block.dart';
import 'package:day_craft/models.dart';
import 'package:day_craft/current_time_indicator.dart';
import 'package:day_craft/edit_block_sheet.dart';
import 'package:day_craft/timeline_app_bar.dart';
import 'package:day_craft/timeline_grid.dart';

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final selectedDate = appState.selectedDate;
    var blocks = appState.getBlocksForDate(selectedDate);
    const double hourHeight = 80.0;

    return Scaffold(
      appBar: TimelineAppBar(
        selectedDate: selectedDate,
        onSaveTemplate: (date) => _showSaveTemplateDialog(context, date),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        child: SizedBox(
          height: 24 * hourHeight,
          child: Stack(
            children: [
              TimelineGrid(hourHeight: hourHeight),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => EditBlockSheet(date: date, block: block),
    );
  }
}
