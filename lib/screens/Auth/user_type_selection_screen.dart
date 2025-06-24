import 'package:flutter/material.dart';
import 'package:hopeless/screens/Auth/PhoneLoginScreen.dart' show PhoneLoginScreen, UserType;

class UserTypeSelectionScreen extends StatefulWidget {
  const UserTypeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<UserTypeSelectionScreen> createState() => _UserTypeSelectionScreenState();
}

class _UserTypeSelectionScreenState extends State<UserTypeSelectionScreen> {
  int? _selectedOption; // 0 for patient, 1 for caregiver

void _navigateToPhoneLogin() {
  if (_selectedOption != null) {
    final userType = _selectedOption == 0 ? UserType.patient : UserType.caregiver;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhoneLoginScreen(userType: userType),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                'مرحباً بك 👋',
                style: theme.titleLarge?.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF112A54),
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 12),
              Text(
                'اختر نوع حسابك للمتابعة',
                style: theme.bodyLarge?.copyWith(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.right,
              ),
              const SizedBox(height: 48),
              
              // Patient Option
              _buildUserTypeCard(
                optionIndex: 0,
                icon: '🧑‍⚕️',
                title: 'للمريض',
                subtitle: 'سجّل كمريض',
                description: 'هذا الحساب يساعدك على تنظيم مواعيد أدويتك ومراقبة التزامك بها بسهولة.',
                isSelected: _selectedOption == 0,
                onTap: () => setState(() => _selectedOption = 0),
              ),
              
              const SizedBox(height: 20),
              
              // Caregiver Option
              _buildUserTypeCard(
                optionIndex: 1,
                icon: '👨‍👩‍👧‍👦',
                title: 'للمرافق',
                subtitle: 'سجّل كمرافق',
                description: 'تابع حالة الأشخاص الأعزّاء عليك وساعدهم في تذكّر مواعيد أدويتهم بكل بساطة.',
                isSelected: _selectedOption == 1,
                onTap: () => setState(() => _selectedOption = 1),
              ),
              
              const Spacer(),
              
              // Continue Button
              ElevatedButton(
                onPressed: _selectedOption != null ? _navigateToPhoneLogin : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF112A54),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  elevation: 0,
                ),
                child: const Text('متابعة'),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserTypeCard({
    required int optionIndex,
    required String icon,
    required String title,
    required String subtitle,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF112A54).withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF112A54) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? const Color(0xFF112A54) : Colors.black87,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? const Color(0xFF112A54) : Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF112A54).withOpacity(0.1) 
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}