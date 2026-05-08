import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResponderLoginScreen extends StatefulWidget {
  final Function(String) onViewChange;
  const ResponderLoginScreen({super.key, required this.onViewChange});

  @override
  State<ResponderLoginScreen> createState() => _ResponderLoginScreenState();
}

class _ResponderLoginScreenState extends State<ResponderLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // 1. Attempt the standard Supabase login
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null) {
        // 2. IMPORTANT: Check if the person logging in is actually a responder
        // We don't want victims accessing the dashboard
        final userData = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', response.user!.id)
            .single();

        if (userData['role'] == 'victim') {
          // If they are a victim, kick them out and show an error
          await Supabase.instance.client.auth.signOut();
          throw "Access Denied: This portal is for Responders only. Please use the mobile app.";
        }
        
        // If they are a responder, main.dart will automatically 
        // switch to the Dashboard because of the Auth State Stream.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()), 
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Matches your Dashboard Sidebar
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_rounded, color: Colors.blueAccent, size: 80),
                const SizedBox(height: 20),
                const Text(
                  "ResQW Login",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text(
                  "Official Responder Access",
                  style: TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 40),
                
                _buildField(_emailController, "Official Email", Icons.email_outlined),
                const SizedBox(height: 20),
                
                _buildField(_passwordController, "Password", Icons.lock_outline, isPass: true),
                const SizedBox(height: 30),
                
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.blueAccent)
                    : Column(
                        children: [
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text(
                              "LOGIN TO DASHBOARD",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("New institution?", style: TextStyle(color: Colors.white54)),
                              TextButton(
                                onPressed: () => widget.onViewChange('register'),
                                child: const Text("Register Now", style: TextStyle(color: Colors.blueAccent)),
                              ),
                            ],
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, {bool isPass = false}) {
    return TextFormField(
      controller: ctrl,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.blueAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
      ),
      validator: (val) => val == null || val.isEmpty ? "Field required" : null,
    );
  }
}