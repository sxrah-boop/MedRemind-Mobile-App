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
    // Tab 0: Home
    const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HomeHeader(
            username: 'سارة',
            notificationCount: 4,
          ),
          StatsCard(taken: 3, total: 4),
          DailyMedList(),
        ],
      ),
    ),
    // Tab 1: Education
    const EducationScreen(),
    // Tab 2: Medications
    const MedicinesScreen(),
    // Tab 3: Profile
    const ProfileScreen(),
    // Tab 4: Chatbot
    const ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEAF2FC), Color(0xFFF9FAFB)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: _screens,
          ),
        ),
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
