import 'package:flutter/material.dart';

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  final Color primaryPurple = const Color(0xFF9161F2);
  final Color darkPurple = const Color(0xFF5B4BDB);
  final Color tealAccent = const Color(0xFF00796B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      // We don't need a bottomNavigationBar here because MainNavigation handles it
      body: Column(
        children: [
          // This header matches your HomeScreen perfectly
          _buildGradientHeader(context),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Immediate Action Guide",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Follow these steps to protect yourself and preserve evidence.",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 20),

                  _buildProtocolCard(
                    "Sexual Assault Protocol",
                    [
                      "Do NOT shower, wash, or change clothes (preserves DNA).",
                      "Keep clothes worn in a clean paper bag.",
                      "Go to a hospital within 72 hours for PEP care.",
                      "Ask for a P3 form and medical examination.",
                    ],
                    Icons.warning_rounded,
                  ),

                  _buildProtocolCard(
                    "Physical Violence Steps",
                    [
                      "Move to a safe, public place immediately.",
                      "Take clear photos of all injuries if safe.",
                      "Seek medical attention even for minor injuries.",
                      "Request a P3 form from the police or hospital.",
                    ],
                    Icons.security,
                  ),

                  _buildProtocolCard(
                    "Stalking & Harassment",
                    [
                      "Avoid isolated areas; stay in populated places.",
                      "Save all evidence (screenshots, recordings).",
                      "Inform trusted family or friends of your location.",
                      "Do not engage with the person harassing you.",
                    ],
                    Icons.visibility,
                  ),

                  _buildProtocolCard(
                    "Emergency Contacts (Kenya)",
                    [
                      "Call 1195: Free National GBV Helpline (24/7).",
                      "Call 999 or 112: Police Emergency.",
                      "Visit a GBV Recovery Centre (GBVRC).",
                    ],
                    Icons.phone_in_talk,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 15, right: 25, bottom: 45),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryPurple, darkPurple],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Added a back button so user can return to Home grid
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
            onPressed: () => Navigator.pop(context),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Resources",
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 4),
                Text(
                  "Safety Protocol & Help Guide",
                  style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolCard(String title, List<String> steps, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFFFFD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFB2EBF2).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), 
                topRight: Radius.circular(20)
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: primaryPurple, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(color: tealAccent, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: steps.map((step) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("• ", style: TextStyle(fontWeight: FontWeight.bold, color: primaryPurple, fontSize: 18)),
                    Expanded(
                      child: Text(
                        step,
                        style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}