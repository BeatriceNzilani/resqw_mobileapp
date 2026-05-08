import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  final Function(String) onViewChange;
  const RegisterScreen({super.key, required this.onViewChange});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {
          'full_name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'role': 'victim', // <--- Hardcoded: Everyone here is a victim
        },
      );

      if (response.user != null) {
        // Move to the next mobile screen (usually profile or home)
        widget.onViewChange('profile'); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration Error: $e"), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Container(
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text("Join ResQW", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
                      const SizedBox(height: 10),
                      const Text("Create your emergency profile", style: TextStyle(color: Colors.black54)),
                      const SizedBox(height: 25),
                      _buildField(_nameController, "Full Name", Icons.person_outline),
                      const SizedBox(height: 15),
                      _buildField(_emailController, "Email", Icons.email_outlined),
                      const SizedBox(height: 15),
                      _buildField(_phoneController, "Phone Number", Icons.phone_android_outlined),
                      const SizedBox(height: 15),
                      _buildField(_passwordController, "Password", Icons.lock_outline, isPass: true),
                      const SizedBox(height: 30),
                      _isLoading
                          ? const CircularProgressIndicator(color: Color(0xFF9161F2))
                          : ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF9161F2),
                                minimumSize: const Size(double.infinity, 55),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                              ),
                              child: const Text("CREATE ACCOUNT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => widget.onViewChange('login'),
                        child: RichText(
                          text: const TextSpan(
                            text: "Already have an account? ",
                            style: TextStyle(color: Colors.black54),
                            children: [
                              TextSpan(text: "Login", style: TextStyle(color: Color(0xFF9161F2), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ... _buildHeader and _buildField remain the same as your original code
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF9161F2), Color(0xFF5B4BDB)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      child: const Column(
        children: [
          Text("ResQW", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Safety within reach", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPass,
      validator: (value) => value == null || value.isEmpty ? "Field required" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF9161F2)),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }
}