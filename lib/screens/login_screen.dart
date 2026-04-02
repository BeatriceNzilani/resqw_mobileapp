import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  final Function(String) onViewChange;
  const LoginScreen({super.key, required this.onViewChange});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      widget.onViewChange('profile'); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( // Fixed: Added Scaffold
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                children: [
                  TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
                  const SizedBox(height: 20),
                  TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
                  const SizedBox(height: 30),
                  _isLoading 
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9161F2), minimumSize: const Size(double.infinity, 50)),
                        child: const Text("LOGIN", style: TextStyle(color: Colors.white)),
                      ),
                  TextButton(onPressed: () => widget.onViewChange('register'), child: const Text("Create Account")),
                ],
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
      padding: const EdgeInsets.symmetric(vertical: 80),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF8E54E9), Color(0xFF4776E6)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35), bottomRight: Radius.circular(35)),
      ),
      child: const Column(
        children: [
          Text("ResQW", style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Welcome Back", style: TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }
}