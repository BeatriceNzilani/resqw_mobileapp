import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  final Function(String) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static const Color primaryPurple = Color.fromARGB(255, 115, 53, 191);
  static const Color accentPurple = Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: Column(
          children: [
            _buildModernHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildActionCard(
                      title: "Emergency Hospitals",
                      subtitle: "Find nearby medical & forensic care",
                      icon: Icons.local_hospital_rounded,
                      onTap: () => print("Hospitals"),
                    ),
                    const SizedBox(height: 15),
                    _buildActionCard(
                      title: "Report Incident",
                      subtitle: "Secure & confidential reporting",
                      icon: Icons.shield_moon_rounded,
                      onTap: () => widget.onNavigate('gbv'),
                    ),
                    const SizedBox(height: 15),
                    _buildActionCard(
                      title: "Police Assistance",
                      subtitle: "Locate nearest safe station",
                      icon: Icons.local_police_rounded,
                      onTap: () => print("Police"),
                    ),
                    const SizedBox(height: 15),
                    _buildActionCard(
                      title: "Knowledge Hub",
                      subtitle: "Safety protocols & legal rights",
                      icon: Icons.menu_book_rounded,
                      onTap: () => widget.onNavigate('resources'),
                    ),
                    const SizedBox(height: 30),
                    _buildSafetyStatusBox(),
                    const SizedBox(height: 150),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Returned to the right (endFloat) and moved down slightly
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 10.0, right: 10.0), 
          child: _buildPulseSOSButton(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [primaryPurple, accentPurple],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 70, 25, 45),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ResQW",
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Your Safety, Our Priority",
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: primaryPurple, size: 30),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyStatusBox() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 70, 16, 137).withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryPurple.withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_rounded, color: primaryPurple, size: 22),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              // Updated to say "danger" instead of emergency
              "In danger? Long press the SOS button for help.",
              style: TextStyle(
                color: Color.fromARGB(221, 0, 0, 0),
                fontSize: 13,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseSOSButton() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double buttonScale = 1.0 + (0.1 * _controller.value);
        double rippleScale = 1.0 + (0.7 * _controller.value);
        double rippleOpacity = (1.0 - _controller.value) * 0.3;

        return GestureDetector(
          onLongPress: () {
            HapticFeedback.vibrate();
            print("SOS ACTIVATED");
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: rippleScale,
                child: Container(
                  width: 95,
                  height: 95,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(rippleOpacity),
                  ),
                ),
              ),
              Transform.scale(
                scale: buttonScale,
                child: Container(
                  height: 85,
                  width: 85,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Danger icon
                      Icon(Icons.report_problem_rounded, color: Colors.white, size: 34),
                      SizedBox(height: 2),
                      Text(
                        "SOS",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}