import 'package:flutter/material.dart';
import 'services/supabase_config.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/gbv_selection_screen.dart'; // Import your other screens
import 'screens/resources_screen.dart';

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
  
  // State trackers for sub-pages
  String _currentProfileView = 'profile'; 
  String _currentHomeView = 'main'; // Tracks if we are on Home, GBV, or Resources

  void _handleProfileViewChange(String newView) {
    setState(() {
      _currentProfileView = newView;
    });
  }

  void _handleHomeViewChange(String newView) {
    setState(() {
      _currentHomeView = newView;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. Logic for the HOME Tab Slot
    Widget homeSlot;
    switch (_currentHomeView) {
      case 'gbv':
        homeSlot = GBVReportingSelection(onBack: () => _handleHomeViewChange('main'));
        break;
      case 'resources':
        homeSlot = ResourcesScreen(onBack: () => _handleHomeViewChange('main'));
        break;
      default:
        homeSlot = HomeScreen(onNavigate: _handleHomeViewChange);
    }

    // 2. Logic for the PROFILE Tab Slot
    Widget profileSlot;
    if (_currentProfileView == 'login') {
      profileSlot = LoginScreen(onViewChange: _handleProfileViewChange);
    } else if (_currentProfileView == 'register') {
      profileSlot = RegisterScreen(onViewChange: _handleProfileViewChange);
    } else {
      profileSlot = ProfileScreen(onViewChange: _handleProfileViewChange);
    }

    final List<Widget> _pages = [
      homeSlot,
      const Center(child: Text("Community Features Coming Soon")),
      profileSlot, 
    ];

    return Scaffold(
      // IndexedStack keeps the state of tabs alive
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // Reset to main screens when tapping the footer icons
            if (index == 0) _currentHomeView = 'main';
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