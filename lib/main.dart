import 'package:flutter/material.dart';
import 'services/supabase_config.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  void _handleViewChange(String newView) {
    setState(() {
      _currentProfileView = newView;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget profileSlot;

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
      // The IndexedStack ensures the footer stays at the bottom
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
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