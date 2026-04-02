import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  final Function(String) onViewChange;

  const ProfileScreen({super.key, required this.onViewChange});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final bool isLoggedIn = user != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(isLoggedIn, user),
            if (isLoggedIn) _buildCaseTrackingSection(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildProfileOption(Icons.notifications_none, "Notifications", "Manage your notifications"),
                  _buildProfileOption(Icons.shield_outlined, "Privacy & Security", "Control your privacy settings"),
                  _buildProfileOption(Icons.help_outline, "Help & Support", "Get help and contact support"),
                  _buildProfileOption(Icons.info_outline, "About", "App version and information"),
                  const SizedBox(height: 20),
                  isLoggedIn 
                    ? _buildLogoutButton()
                    : _buildLoginRedirectButton(),
                  const SizedBox(height: 10),
                  const Text("ResQW v1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const Text("Your Safety, Our Priority", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isLoggedIn, User? user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF9161F2),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white,
            child: Text("U", style: TextStyle(fontSize: 40, color: Color(0xFF9161F2))),
          ),
          const SizedBox(height: 15),
          Text(
            isLoggedIn ? (user?.email?.split('@')[0] ?? "User") : "Guest User",
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            isLoggedIn ? user!.email! : "Log in to track your cases",
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCaseTrackingSection() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        children: [
          Expanded(child: Text("Active Cases: 03", style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text("Completed: 12", style: TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, String sub) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF9161F2)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _buildLoginRedirectButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => onViewChange('login'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9161F2),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: const Text("Login / Register", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () async {
          await Supabase.instance.client.auth.signOut();
          onViewChange('profile'); 
        },
        child: const Text("Log Out", style: TextStyle(color: Colors.red)),
      ),
    );
  }
}