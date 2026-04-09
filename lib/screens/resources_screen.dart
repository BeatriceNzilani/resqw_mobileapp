import 'package:flutter/material.dart';

class ResourcesScreen extends StatelessWidget {
  // 1. Define the onBack callback
  final VoidCallback? onBack;

  // 2. Add onBack to the constructor
  const ResourcesScreen({super.key, this.onBack});

  final Color primaryPurple = const Color(0xFF9161F2);
  final Color darkPurple = const Color(0xFF5B4BDB);
  final Color tealAccent = const Color(0xFF00796B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // 3. The header now uses the context and local methods
          _buildConsistentHeader(context, "Resources", "Safety Protocol & Help Guide"),
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
                  _buildProtocolCard("Sexual Assault Protocol", [
                    "Do NOT shower, wash, or change clothes (preserves DNA).",
                    "Keep clothes worn in a clean paper bag.",
                    "Go to a hospital within 72 hours for PEP care.",
                    "Ask for a P3 form and medical examination.",
                  ], Icons.warning_rounded),
                  _buildProtocolCard("Physical Violence Steps", [
                    "Move to a safe, public place immediately.",
                    "Take clear photos of all injuries if safe.",
                    "Seek medical attention even for minor injuries.",
                    "Request a P3 form from the police or hospital.",
                  ], Icons.security),
                  _buildProtocolCard("Stalking & Harassment", [
                    "Avoid isolated areas; stay in populated places.",
                    "Save all evidence (screenshots, recordings).",
                    "Inform trusted family or friends of your location.",
                    "Do not engage with the person harassing you.",
                  ], Icons.visibility),
                  _buildProtocolCard("Emergency Contacts (Kenya)", [
                    "Call 1195: Free National GBV Helpline (24/7).",
                    "Call 999 or 112: Police Emergency.",
                    "Visit a GBV Recovery Centre (GBVRC).",
                  ], Icons.phone_in_talk),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsistentHeader(BuildContext context, String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 15, right: 25, bottom: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryPurple, darkPurple]),
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 22),
            onPressed: () {
              // 4. Handle navigation based on whether onBack is provided
              if (onBack != null) {
                onBack!();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.9), fontSize: 16)),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              color: primaryPurple.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Icon(icon, color: primaryPurple, size: 22),
                const SizedBox(width: 10),
                Text(title,
                    style: TextStyle(
                        color: tealAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: steps
                  .map((step) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("• ",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: primaryPurple,
                                    fontSize: 18)),
                            Expanded(
                                child: Text(step,
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.black87,
                                        height: 1.4))),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}