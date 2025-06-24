import 'package:flutter/material.dart';
import 'package:hopeless/screens/educationscreen.dart';
import 'package:hopeless/screens/medicine-screens/medicines_screen.dart';
import 'package:hopeless/screens/profile_screen.dart';
import 'package:hopeless/services/calculate_stats.dart';
import 'package:hopeless/services/fetch_history_service.dart';
import 'package:hopeless/services/list_prescriptions_service_api.dart';
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
void initState() {
  super.initState();
  _loadStats();
}

int _taken = 0;
int _total = 0;

Future<void> _loadStats() async {
  try {
    final prescriptions = await PrescriptionService.fetchPrescriptions();
    final history = await HistoryService.fetchHistory();
    final result = calculateTodayStats(prescriptions: prescriptions, history: history);
    
    setState(() {
      _taken = result['taken']!;
      _total = result['total']!;
    });
  } catch (e) {
    debugPrint('❌ Error loading stats: $e');
  }
}

    List<Widget> get _screens => [
    // ✅ Home screen with dynamic data
    SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeHeader(username: 'سارة'),
          const SizedBox(height: 12),
          StatsCard(taken: _taken, total: _total), // 🔄 Removed const
          const SizedBox(height: 12),
          const DailyMedList(), // this can stay const
        ],
      ),
    ),
     EducationPage(),
    const MedicinesScreen(),
    const ProfileScreen(),
    const ChatScreen(),
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
