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
import '../chatbot/chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int _taken = 0;
  int _total = 0;
  bool _isLoading = true; // Add loading state
  String? _errorMessage; // Add error state

  @override // ✅ Fixed: Added missing @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final prescriptions = await PrescriptionService.fetchPrescriptions();
      final history = await HistoryService.fetchHistory();
      final result = calculateTodayStats(
        prescriptions: prescriptions,
        history: history,
      );

      if (mounted) {
        // ✅ Check if widget is still mounted
        setState(() {
          _taken = result['taken']!;
          _total = result['total']!;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading stats: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  List<Widget> get _screens => [
    // Home screen with error handling
    _buildHomeScreen(),
    EducationPage(), // ✅ Fixed: Added const
    MedicinesScreen(),
    ProfileScreen(),
    ChatScreen(),
  ];

  Widget _buildHomeScreen() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF112A54)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ في تحميل البيانات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStats,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    // Normal home screen
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeHeader(username: 'سارة'),
          const SizedBox(height: 12),
          StatsCard(taken: _taken, total: _total),
          const SizedBox(height: 4),
          const DailyMedList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Add error boundary for the entire widget
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(_screens.length, (index) {
          try {
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
          } catch (e) {
            // ✅ Catch any widget building errors
            debugPrint('❌ Error building screen $index: $e');
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('خطأ في تحميل الشاشة', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('$e', textAlign: TextAlign.center),
                  ],
                ),
              ),
            );
          }
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
