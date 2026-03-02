import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:day_craft/app_state.dart';
import 'package:day_craft/template_screen.dart';

class TimelineAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DateTime selectedDate;
  final void Function(DateTime date) onSaveTemplate;

  const TimelineAppBar({
    super.key,
    required this.selectedDate,
    required this.onSaveTemplate,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
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
                color: Theme.of(context).colorScheme.onSurface,
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
                        color: Theme.of(context).colorScheme.onSurface,
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
            onPressed: () => onSaveTemplate(selectedDate),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(90);
}
