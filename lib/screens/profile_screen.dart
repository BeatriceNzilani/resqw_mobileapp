import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final Function(String) onViewChange;
  const ProfileScreen({super.key, required this.onViewChange});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUploading = false;
  final _supabase = Supabase.instance.client;
  final Color primaryPurple = const Color(0xFF9161F2); // The signature purple

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  // --- SECURE STORAGE LOGIC ---

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image == null) return;
    setState(() => _isUploading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final file = File(image.path);
      final fileExt = image.path.split('.').last;
      final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await _supabase.storage.from('avatars').upload(
            fileName,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final imageUrl = _supabase.storage.from('avatars').getPublicUrl(fileName);

      await _supabase.auth.updateUser(
        UserAttributes(data: {'avatar_url': imageUrl}),
      );

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile picture updated!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Upload Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteImage() async {
    final user = _supabase.auth.currentUser;
    final String? avatarUrl = user?.userMetadata?['avatar_url'];

    if (avatarUrl == null) return;
    setState(() => _isUploading = true);

    try {
      final fileName = avatarUrl.split('/').last;
      await _supabase.storage.from('avatars').remove([fileName]);

      await _supabase.auth.updateUser(
        UserAttributes(data: {'avatar_url': null}),
      );

      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile photo deleted for security.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Delete Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // Menu triggered only by the Camera Icon
  void _showImageOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        final hasImage = _supabase.auth.currentUser?.userMetadata?['avatar_url'] != null;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              ListTile(
                leading: Icon(Icons.photo_camera, color: primaryPurple),
                title: const Text('Upload New Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _uploadImage();
                },
              ),
              if (hasImage)
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.red),
                  title: const Text('Delete Current Photo', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteImage();
                  },
                ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _supabase.auth.currentUser;
    final bool isLoggedIn = user != null;
    final String fullName = user?.userMetadata?['full_name'] ?? "User";
    final String? avatarUrl = user?.userMetadata?['avatar_url'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(isLoggedIn, fullName, avatarUrl),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildOption(Icons.notifications_none, "Notifications", "Manage your alerts"),
                  _buildOption(Icons.shield_outlined, "Privacy", "Security settings"),
                  _buildOption(Icons.help_outline, "Support", "Get help"),
                  const SizedBox(height: 40),
                  isLoggedIn ? _buildLogoutButton() : _buildLoginRedirectButton(),
                  const SizedBox(height: 20),
                  const Text("ResQW v1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(bool isLoggedIn, String name, String? avatarUrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 70, bottom: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryPurple, const Color(0xFF5B4BDB)]),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white,
                backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
                child: avatarUrl == null
                    ? Icon(Icons.person, size: 60, color: primaryPurple)
                    : null,
              ),
              if (isLoggedIn)
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: GestureDetector(
                    onTap: _showImageOptions, // The camera icon is the only trigger
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black26)],
                      ),
                      child: _isUploading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: primaryPurple),
                            )
                          : Icon(Icons.camera_alt, size: 18, color: primaryPurple),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            isLoggedIn ? "${_getGreeting()}, $name" : "Guest User",
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(IconData icon, String title, String sub) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, color: primaryPurple),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(sub, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: () async {
          await _supabase.auth.signOut();
          widget.onViewChange('login');
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: primaryPurple, width: 2), // Purple Outline
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text("Log Out", style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLoginRedirectButton() {
    return ElevatedButton(
      onPressed: () => widget.onViewChange('login'),
      style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
      child: const Text("Login / Register", style: TextStyle(color: Colors.white)),
    );
  }
}