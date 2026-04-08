import 'package:flutter/material.dart';
import 'gbv_selection_screen.dart';
import 'resources_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildGradientHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                children: [
                  _buildActionCard(
                    title: "Hospitals",
                    subtitle: "Find nearby medical assistance",
                    icon: Icons.local_hospital,
                    color: Colors.green,
                    onTap: () => print("Navigate to Hospitals"),
                  ),
                  const SizedBox(height: 15),
                  
                  _buildActionCard(
                    title: "Report GBV",
                    subtitle: "File a report for yourself or others",
                    icon: Icons.description,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GBVReportingSelection()),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  
                  _buildActionCard(
                    title: "Police Stations",
                    subtitle: "Locate help on the map",
                    icon: Icons.local_police,
                    color: Colors.blue,
                    onTap: () => print("Navigate to Police"),
                  ),
                  const SizedBox(height: 15),
                  
                  _buildActionCard(
                    title: "Resources",
                    subtitle: "Immediate safety protocols",
                    icon: Icons.menu_book,
                    color: Colors.blueGrey,
                    onTap: () {
                      // Keeps the footer visible by pushing onto the current navigator stack
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ResourcesScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  
                  _buildInfoBox(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildSOSButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildGradientHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 70, left: 25, right: 25, bottom: 45),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9161F2), Color(0xFF5B4BDB)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "ResQW",
            style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            "Your Safety, Our Priority",
            style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 45,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
            ),
            const SizedBox(width: 15),
            Icon(icon, color: color, size: 30),
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
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF5B4BDB).withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF5B4BDB).withOpacity(0.1)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: Color(0xFF5B4BDB), size: 22),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "In immediate danger? Long-press the SOS button to alert emergency contacts.",
              style: TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSOSButton() {
    return GestureDetector(
      onLongPress: () => print("EMERGENCY TRIGGERED"),
      child: Container(
        height: 75,
        width: 75,
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 30),
            Text("SOS", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}