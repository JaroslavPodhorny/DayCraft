import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:day_craft/app_state.dart';
import 'package:day_craft/models.dart';

class EditBlockSheet extends StatefulWidget {
  final DateTime date;
  final TimeBlock block;

  const EditBlockSheet({super.key, required this.date, required this.block});

  @override
  State<EditBlockSheet> createState() => _EditBlockSheetState();
}

class _EditBlockSheetState extends State<EditBlockSheet> {
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.block.title);
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            controller: _titleController,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
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
              _colorOption(
                context,
                widget.date,
                widget.block,
                Colors.blueAccent,
              ),
              _colorOption(
                context,
                widget.date,
                widget.block,
                Colors.orangeAccent,
              ),
              _colorOption(
                context,
                widget.date,
                widget.block,
                Colors.greenAccent,
              ),
              _colorOption(
                context,
                widget.date,
                widget.block,
                Colors.purpleAccent,
              ),
              _colorOption(
                context,
                widget.date,
                widget.block,
                Colors.redAccent,
              ),
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
                    context.read<AppState>().removeBlock(
                      widget.date,
                      widget.block.id,
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    shape: const StadiumBorder(),
                  ),
                  child: const Text("Uložit jako blok"),
                  onPressed: () {
                    _saveBlockAsPreset(context, widget.block);
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
                      widget.date,
                      widget.block.copyWith(title: _titleController.text),
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
                  color: Theme.of(context).colorScheme.onSurface,
                  width: 3,
                )
              : null,
        ),
      ),
    );
  }
}
