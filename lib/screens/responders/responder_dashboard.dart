import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui'; 

class ResponderDashboard extends StatefulWidget {
  const ResponderDashboard({super.key});

  @override
  State<ResponderDashboard> createState() => _ResponderDashboardState();
}

class _ResponderDashboardState extends State<ResponderDashboard> {
  final _supabase = Supabase.instance.client;

  // Function to format the location text if it exists
  String _formatLocation(dynamic location) {
    if (location == null) return "Location: Pending...";
    // Supabase returns geography as a GeoJSON-like string or object
    return "GPS Coordinates Active";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          // 1. NAVIGATION SIDEBAR
          _buildSidebar(),

          // 2. LIVE ALERTS PANEL
          Expanded(
            flex: 3,
            child: _buildAlertsPanel(),
          ),

          // 3. MAP VIEW PANEL
          Expanded(
            flex: 5,
            child: _buildMapPlaceholder(),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(right: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 50),
          const Text("ResQW", 
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const Text("COMMAND CENTER", 
            style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 50),
          _sidebarItem(Icons.grid_view_rounded, "Dashboard", true),
          _sidebarItem(Icons.notifications_active_outlined, "Active Alerts", false),
          _sidebarItem(Icons.history_rounded, "Incident Reports", false),
          _sidebarItem(Icons.settings_outlined, "Settings", false),
          const Spacer(),
          _sidebarItem(Icons.logout_rounded, "Logout", false, isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label, bool isActive, {bool isLogout = false}) {
    return ListTile(
      leading: Icon(icon, color: isLogout ? Colors.redAccent : (isActive ? Colors.blueAccent : Colors.white60)),
      title: Text(label, 
        style: TextStyle(
          color: isLogout ? Colors.redAccent : (isActive ? Colors.white : Colors.white60), 
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal
        )),
      onTap: () {
        if (isLogout) _supabase.auth.signOut();
      },
    );
  }

  Widget _buildAlertsPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Live Emergency Feed", 
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("Real-time updates from Nairobi Region", 
            style: TextStyle(color: Colors.white.withOpacity(0.5))),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              // Listens to the 'profiles' table for NGO/Responder locations 
              // or 'alerts' table for victim emergencies. 
              // Assuming we are watching 'alerts' for this view.
              stream: _supabase.from('alerts').stream(primaryKey: ['id']).order('created_at'),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
                
                final alerts = snapshot.data!;
                if (alerts.isEmpty) return const Center(child: Text("No active alerts", style: TextStyle(color: Colors.white24)));

                return ListView.builder(
                  itemCount: alerts.length,
                  itemBuilder: (context, index) => _buildAlertCard(alerts[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Map<String, dynamic> alert) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.redAccent, 
              child: Icon(Icons.warning_amber_rounded, color: Colors.white)
            ),
            title: Text(alert['victim_name'] ?? "Anonymous", 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert['emergency_type'] ?? "General Alert", 
                  style: TextStyle(color: Colors.redAccent.withOpacity(0.8), fontSize: 12)),
                const SizedBox(height: 4),
                Text(_formatLocation(alert['location']), 
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11)),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.blueAccent, size: 18),
              onPressed: () {
                // Future: Zoom map to this alert's location
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        image: const DecorationImage(
          image: NetworkImage("https://images.unsplash.com/photo-1526778548025-fa2f459cd5c1?q=80&w=2000"), // Placeholder map texture
          fit: BoxFit.cover,
          opacity: 0.1,
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_rounded, size: 80, color: Colors.white10),
            SizedBox(height: 16),
            Text("INTERACTIVE MAP ENGINE", 
              style: TextStyle(color: Colors.white24, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            Text("Ready for coordinates...", style: TextStyle(color: Colors.white10, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}