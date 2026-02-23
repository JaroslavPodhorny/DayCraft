import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:day_craft/app_state.dart';

class TemplateScreen extends StatelessWidget {
  const TemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final templates = context.watch<AppState>().templates;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Šablony"),
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () => _showSaveTemplateDialog(context),
            child: const Text(
              "Uložit dnešek",
              style: TextStyle(color: Color(0xFF5E5CE6)),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: templates.length,
        itemBuilder: (context, i) {
          final template = templates[i];
          return Card(
            color: const Color(0xFF1C1C1E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              title: Text(
                template.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                "${template.blocks.length} blok",
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: const Color(0xFF2C2C2E),
                ),
                icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                onPressed: () {
                  context.read<AppState>().applyTemplate(
                    null, // Let AppState handle the date (defaults to today)
                    template,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Použita šablona ${template.name}")),
                  );
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSaveTemplateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text("Uložit dnešek jako šablonu"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: "Název šablony (např. Pondělí)",
            filled: true,
            fillColor: Colors.black12,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Zrušit"),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().saveCurrentDayAsTemplate(
                DateTime.now(),
                controller.text,
              );
              Navigator.pop(context);
            },
            child: const Text(
              "Uložit",
              style: TextStyle(color: Color(0xFF5E5CE6)),
            ),
          ),
        ],
      ),
    );
  }
}
