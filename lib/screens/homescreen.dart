import 'package:flutter/material.dart';
import 'package:hopeless/screens/educationscreen.dart';
import 'package:hopeless/screens/medicine-screens/medicines_screen.dart';
import 'package:hopeless/screens/profile_screen.dart';
import 'package:hopeless/widgets/home_header_bar.dart';
import 'package:hopeless/widgets/medicine-widgets/daily_meds_list.dart';
import 'package:hopeless/widgets/stats_card.dart';
import '../widgets/menu_bar.dart';
import '../chatbot/chat_screen.dart'; // <-- Import your ChatScreen
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // ✅ Each of these must have its own Scaffold
    SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeHeader(
            username: 'سارة',
          ),
          const SizedBox(height: 12),
          const StatsCard(taken: 3, total: 4),
          const SizedBox(height: 12),
           DailyMedList(),
        ],
      ),
    ),
     EducationPage(),
     MedicinesScreen(),
     ProfileScreen(),
     ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Only if _screens[0] doesn’t have a Scaffold, wrap it manually
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(_screens.length, (index) {
          final screen = _screens[index];
          if (index == 0) {
            // Home screen doesn't use its own Scaffold, so we wrap it
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFEAF2FC), Color(0xFFF9FAFB)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(child: screen),
            );
          }
          return screen;
        }),
      ),
      bottomNavigationBar: CustomMenuBar(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
