import 'package:flutter/material.dart';
import 'services/supabase_config.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Uses your custom services/supabase_config.dart
  await SupabaseConfig.init();

  runApp(const ResQWApp());
}

class ResQWApp extends StatelessWidget {
  const ResQWApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ResQW',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF9161F2),
        brightness: Brightness.light,
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
  String _currentProfileView = 'profile'; 

  // The missing function your IDE was asking for
  void _handleViewChange(String newView) {
    setState(() {
      _currentProfileView = newView;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget profileSlot;

    // Logic to toggle between Profile, Login, and Register within the same tab
    if (_currentProfileView == 'login') {
      profileSlot = LoginScreen(onViewChange: _handleViewChange);
    } else if (_currentProfileView == 'register') {
      profileSlot = RegisterScreen(onViewChange: _handleViewChange);
    } else {
      profileSlot = ProfileScreen(onViewChange: _handleViewChange);
    }

    final List<Widget> _pages = [
      const HomeScreen(),
      const Center(child: Text("Community Features Coming Soon")),
      profileSlot, 
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // Always reset to main profile view when clicking the profile tab
            if (index == 2) _currentProfileView = 'profile';
          });
        },
        selectedItemColor: const Color(0xFF9161F2),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.group_outlined), label: 'Community'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}