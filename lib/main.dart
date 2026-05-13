import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_config.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
// Note: Imports for GBV and Resources are now mainly used inside home_screen.dart

// Responder Imports
import 'screens/responders/responder_dashboard.dart'; 
import 'screens/responders/responder_login_screen.dart';
import 'screens/responders/responder_register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

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
      home: kIsWeb 
          ? const WebAuthGate() 
          : const MainNavigation(),
    );
  }
}

// --- WEB PORTAL GATEKEEPER ---
class WebAuthGate extends StatefulWidget {
  const WebAuthGate({super.key});

  @override
  State<WebAuthGate> createState() => _WebAuthGateState();
}

class _WebAuthGateState extends State<WebAuthGate> {
  String _activeView = 'login'; 

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        if (session != null) {
          return const ResponderDashboard();
        }

        if (_activeView == 'register') {
          return ResponderRegisterScreen(
            onViewChange: (view) => setState(() => _activeView = view),
          );
        } else {
          return ResponderLoginScreen(
            onViewChange: (view) => setState(() => _activeView = view),
          );
        }
      },
    );
  }
}

// --- MOBILE NAVIGATION (Victim App) ---
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  String _currentProfileView = 'profile'; 

  void _handleProfileViewChange(String newView) => setState(() => _currentProfileView = newView);

  @override
  Widget build(BuildContext context) {
    // CORRECTION: homeSlot is now always HomeScreen. 
    // Navigation to 'gbv' or 'resources' happens via Navigator.push inside HomeScreen.
    Widget homeSlot = const HomeScreen();

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
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // Reset profile view when clicking the profile tab
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