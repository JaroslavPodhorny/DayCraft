import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:day_craft/app_state.dart';
import 'package:day_craft/smart_add_sheet.dart';
import 'package:day_craft/timeline_screen.dart';
import 'package:day_craft/template_screen.dart';
import 'package:day_craft/settings_screen.dart';
import 'package:day_craft/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('cs', null);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const TimeBlockApp(),
    ),
  );
}

class TimeBlockApp extends StatelessWidget {
  const TimeBlockApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final darkTheme = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color(0xFF050505),
      primaryColor: const Color(0xFF5E5CE6),
      cardColor: const Color(0xFF1C1C1E),
      dividerColor: Colors.white.withOpacity(0.1),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5E5CE6),
        brightness: Brightness.dark,
        background: const Color(0xFF050505),
        onBackground: Colors.white,
        secondary: Colors.grey[400],
      ),
    );

    final lightTheme = ThemeData.light().copyWith(
      scaffoldBackgroundColor: const Color(0xFFF2F2F7),
      primaryColor: const Color(0xFF5E5CE6),
      cardColor: Colors.white,
      dividerColor: Colors.black.withOpacity(0.08),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5E5CE6),
        brightness: Brightness.light,
        background: const Color(0xFFF2F2F7),
        onBackground: Colors.black,
        secondary: Colors.grey[600],
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
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
    const SettingsScreen(),
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
                      _navItem(2, Icons.settings_rounded),
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
                  final selectedDate = context.read<AppState>().selectedDate;
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: const Color(0xFF1C1C1E),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (context) => SmartAddSheet(date: selectedDate),
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
