import 'package:flutter/material.dart';
import 'dart:ui';
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF050505),
        primaryColor: const Color(0xFF5E5CE6),
        cardColor: const Color(0xFF1C1C1E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5E5CE6),
          brightness: Brightness.dark,
        ),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(35),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 70,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2E).withOpacity(0.8),
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
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
            ),
          ),
          if (_currentIndex == 0)
            Positioned(
              bottom: 105,
              right: 20,
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColor,
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
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
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
