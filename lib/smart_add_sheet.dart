import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:day_craft/app_state.dart';
import 'package:day_craft/models.dart';

class SmartAddSheet extends StatefulWidget {
  final DateTime date;
  const SmartAddSheet({super.key, required this.date});

  @override
  State<SmartAddSheet> createState() => _SmartAddSheetState();
}

class _SmartAddSheetState extends State<SmartAddSheet> {
  final TextEditingController _textController = TextEditingController();
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 10, minute: 0);
  String _title = "";

  @override
  Widget build(BuildContext context) {
    final knownTitles = context.read<AppState>().knownTitles;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Přidat rutinu / blok",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),

          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text == '') {
                return const Iterable<String>.empty();
              }
              return knownTitles.where((String option) {
                return option.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                );
              });
            },
            onSelected: (String selection) {
              _title = selection;
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
                  controller.addListener(() {
                    _title = controller.text;
                  });
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      hintText: "Hledat nebo vytvořit...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  );
                },
          ),

          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timeButton(
                "Od",
                startTime,
                (t) => setState(() => startTime = t!),
              ),
              const Icon(Icons.arrow_forward, color: Colors.grey),
              _timeButton("Do", endTime, (t) => setState(() => endTime = t!)),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5E5CE6),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (_title.isEmpty) return;

              context.read<AppState>().addBlock(
                widget.date,
                TimeBlock(
                  id: DateTime.now().toString(),
                  title: _title,
                  start: startTime,
                  end: endTime,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text(
              "Přidat do rozvrhu",
              style: TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _timeButton(
    String label,
    TimeOfDay time,
    Function(TimeOfDay?) onPick,
  ) {
    return InkWell(
      onTap: () async =>
          onPick(await showTimePicker(context: context, initialTime: time)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Text("$label: ", style: const TextStyle(color: Colors.grey)),
            Text(
              time.format(context),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
