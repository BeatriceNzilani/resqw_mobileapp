import 'package:flutter/material.dart';
import 'self_report_form.dart';
import 'third_party_report_form.dart';

class GBVReportingSelection extends StatelessWidget {
  const GBVReportingSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          _buildHeader("Report Incident", "Choose how you want to report"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _selectionCard(
                    context,
                    "Report for Self",
                    "I am the victim and need assistance",
                    Icons.person,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SelfReportForm())),
                  ),
                  const SizedBox(height: 20),
                  _selectionCard(
                    context,
                    "Report for Others",
                    "Reporting on behalf of someone else",
                    Icons.people_alt_outlined,
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ThirdPartyReportForm())),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String title, String sub) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 35),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9161F2), Color(0xFF5B4BDB)],
        ),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => print("Back"),
          ),
          Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(sub, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _selectionCard(BuildContext context, String title, String sub, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF9161F2), size: 35),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  Text(sub, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}