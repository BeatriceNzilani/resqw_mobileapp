import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  final Function(String) onViewChange;

  const RegisterScreen({super.key, required this.onViewChange});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
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
        },
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Registration Successful! Check your email.")),
        );
        widget.onViewChange('login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Fixes the "No Material widget found" error
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Transform.translate(
                offset: const Offset(0, -30),
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
                  ),
                  child: Column(
                    children: [
                      _buildField(_nameController, "Full Name", Icons.person_outline),
                      const SizedBox(height: 15),
                      _buildField(_emailController, "Email", Icons.email_outlined),
                      const SizedBox(height: 15),
                      _buildField(_phoneController, "Phone Number", Icons.phone_android_outlined),
                      const SizedBox(height: 15),
                      _buildField(_passwordController, "Password", Icons.lock_outline, isPass: true),
                      const SizedBox(height: 15),
                      _buildField(_confirmPasswordController, "Confirm Password", Icons.lock_reset, isPass: true),
                      const SizedBox(height: 25),
                      _isLoading 
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF9161F2),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text("REGISTER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                      TextButton(
                        onPressed: () => widget.onViewChange('login'),
                        child: const Text("Already have an account? Login"),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 60),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF8E54E9), Color(0xFF4776E6)]),
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
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF9161F2)),
        filled: true,
        fillColor: const Color(0xFFF5F7FA),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}