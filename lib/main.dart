import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:day_craft/app_state.dart';
import 'package:day_craft/smart_add_sheet.dart';
import 'package:day_craft/timeline_screen.dart';
import 'package:day_craft/template_screen.dart';

void main() async {
  await initializeDateFormatting('cs', null);
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const TimeBlockApp(),
    ),
  );
}

class TimeBlockApp extends StatelessWidget {
  const TimeBlockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: const Color(0xFF5E5CE6),
        cardColor: const Color(0xFF1C1C1E),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const TimelineScreen(),
    const TemplateScreen(),
    const Center(child: Text("Kalendář (Již brzy)")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _screens[_currentIndex],
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Container(
              height: 65,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E).withOpacity(0.95),
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _navItem(0, Icons.dashboard_rounded),
                  _navItem(1, Icons.copy_all_rounded),
                  _navItem(2, Icons.calendar_month_rounded),
                ],
              ),
            ),
          ),
          if (_currentIndex == 0)
            Positioned(
              bottom: 105,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: const Color(0xFF5E5CE6),
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: const Color(0xFF1C1C1E),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => SmartAddSheet(date: DateTime.now()),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5E5CE6) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey,
          size: 26,
        ),
      ),
    );
  }
}
