import 'package:flutter/material.dart';
import 'self_report_form.dart';
import 'third_party_report_form.dart';

class GBVReportingSelection extends StatelessWidget {
  final VoidCallback? onBack;

  const GBVReportingSelection({super.key, this.onBack});

  static const Color primaryPurple = Color.fromARGB(255, 115, 53, 191);
  static const Color accentPurple = Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildModernHeader(context),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel("Choose Report Type"),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    title: "Report for Myself",
                    subtitle: "Safe and private reporting for you",
                    icon: Icons.person_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SelfReportForm()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildActionCard(
                    title: "Report for Others",
                    subtitle: "Help a friend or family member",
                    icon: Icons.people_rounded,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ThirdPartyReportForm()),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildAwarenessCard(),
                  const SizedBox(height: 28),
                  _buildFriendlySafetyBox(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.black45,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
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
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Report GBV",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "We are here to help you stay safe.",
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

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
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
                  Text(title,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _buildAwarenessCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryPurple.withOpacity(0.08),
            accentPurple.withOpacity(0.04)
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryPurple.withOpacity(0.12)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "You are not alone",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: primaryPurple,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Don't be afraid to speak up. Reporting is the first and most courageous step you can take toward your safety and justice. We are here to support you every step of the way.",
            style: TextStyle(height: 1.5, fontSize: 14),
          ),
          SizedBox(height: 12),
          Text(
            "Once you submit a report, our dedicated responders will review your details securely and reach out to provide the guidance and support you need.",
            style: TextStyle(height: 1.5, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendlySafetyBox() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 70, 16, 137).withOpacity(0.05),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_user_rounded, color: primaryPurple),
          SizedBox(width: 15),
          Expanded(
            child: Text(
              "All reports are secure. Your identity remains private.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}