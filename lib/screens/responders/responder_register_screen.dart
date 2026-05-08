import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ResponderRegisterScreen extends StatefulWidget {
  final Function(String) onViewChange;
  const ResponderRegisterScreen({super.key, required this.onViewChange});

  @override
  State<ResponderRegisterScreen> createState() => _ResponderRegisterScreenState();
}

class _ResponderRegisterScreenState extends State<ResponderRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers - Removed _idController
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _locationNameController = TextEditingController(); 

  String _institutionType = 'police'; 
  bool _isLoading = false;
  final List<String> _types = ['police', 'hospital', 'ngo'];

  // GPS State
  double? _lat;
  double? _lng;

  void _showMapPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text("Click to Pin Station Location", style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.7,
          height: 450,
          child: GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-1.286389, 36.817223), // Centered on Nairobi
              zoom: 13,
            ),
            onTap: (LatLng position) {
              setState(() {
                _lat = position.latitude;
                _lng = position.longitude;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("GPS Location Captured!")),
              );
            },
            markers: _lat != null ? {
              Marker(markerId: const MarkerId('selected'), position: LatLng(_lat!, _lng!))
            } : {},
          ),
        ),
      ),
    );
  }

  Future<void> _registerResponder() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_lat == null || _lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please pin your location on the map first."), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'full_name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': _institutionType,
          // 'official_id' removed from here
          'location_name': _locationNameController.text.trim(),
          'latitude': _lat,
          'longitude': _lng,
        },
      );

      widget.onViewChange('login'); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Success! Awaiting verification."), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isPinned = _lat != null && _lng != null;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white10),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text("Responder Portal", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 30),
                  
                  _buildField(_nameController, "Institution Name (e.g. Kamukunji Police)", Icons.account_balance),
                  const SizedBox(height: 15),
                  
                  _buildTypeSelector(),
                  const SizedBox(height: 20),

                  _buildMapPickerButton(isPinned),
                  const SizedBox(height: 20),

                  // Official ID field has been removed from here
                  
                  _buildField(_locationNameController, "Area Description (e.g. Ring Road)", Icons.location_city),
                  const SizedBox(height: 15),

                  _buildField(_emailController, "Official Email", Icons.email),
                  const SizedBox(height: 15),
                  
                  _buildField(_phoneController, "Station Landline / Phone", Icons.phone),
                  const SizedBox(height: 15),
                  
                  _buildField(_passwordController, "Password", Icons.lock, isPass: true),
                  const SizedBox(height: 30),
                  
                  _isLoading
                      ? const CircularProgressIndicator()
                      : Column(
                          children: [
                            ElevatedButton(
                              onPressed: _registerResponder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getThemeColor(),
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text("REGISTER INSTITUTION", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                            TextButton(
                              onPressed: () => widget.onViewChange('login'),
                              child: const Text("Go to Login", style: TextStyle(color: Colors.white70)),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapPickerButton(bool isPinned) {
    return InkWell(
      onTap: _showMapPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
        decoration: BoxDecoration(
          color: isPinned ? Colors.green.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isPinned ? Colors.greenAccent : Colors.white10),
        ),
        child: Row(
          children: [
            Icon(isPinned ? Icons.check_circle : Icons.add_location_alt, 
                 color: isPinned ? Colors.greenAccent : Colors.blueAccent),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                isPinned ? "GPS Location Pinned" : "Pin Station GPS Location",
                style: TextStyle(color: isPinned ? Colors.greenAccent : Colors.white70, fontWeight: isPinned ? FontWeight.bold : FontWeight.normal),
              ),
            ),
            if (isPinned) const Icon(Icons.edit, color: Colors.white38, size: 16),
          ],
        ),
      ),
    );
  }

  Color _getThemeColor() {
    if (_institutionType == 'police') return Colors.blueAccent;
    if (_institutionType == 'hospital') return Colors.greenAccent;
    return Colors.purpleAccent;
  }

  Widget _buildTypeSelector() {
    return Row(
      children: _types.map((type) {
        bool isSelected = _institutionType == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _institutionType = type),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? _getThemeColor() : Colors.white10,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(type.toUpperCase(), style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      ),
      validator: (val) => (val == null || val.isEmpty) ? "Required" : null,
    );
  }
}