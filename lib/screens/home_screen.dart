import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // GRADIENT HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF8E54E9), Color(0xFF4776E6)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("ResQW", 
                  style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                Text("Your Safety, Our Priority", 
                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
              ],
            ),
          ),

          // STATIC ACTION CARDS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                _buildActionCard("Hospitals", "Find nearby hospitals", const Color(0xFF00A676), Icons.medical_services),
                const SizedBox(height: 12),
                _buildActionCard("Report GBV", "File a report anonymously", const Color(0xFFE53935), Icons.description),
                const SizedBox(height: 12),
                _buildActionCard("Police Stations", "Locate help on the map", const Color(0xFF1E88E5), Icons.shield),
                const SizedBox(height: 12),
                _buildActionCard("Resources", "Educational materials", const Color(0xFFFB8C00), Icons.school),
                
                const SizedBox(height: 20),
                
                // EMERGENCY INFO BOX
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFF1E88E5), size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Immediate danger? Long-press the SOS button below.", 
                          style: TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          // Trigger Emergency Logic here
        },
        backgroundColor: Colors.red.shade700,
        elevation: 8,
        shape: const CircleBorder(),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
            Text("SOS", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      // bottomNavigationBar has been removed to avoid duplication with main.dart
    );
  }

  Widget _buildActionCard(String title, String sub, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
        ],
      ),
    );
  }
}