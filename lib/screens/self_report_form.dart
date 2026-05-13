import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class SelfReportForm extends StatefulWidget {
  const SelfReportForm({super.key});

  @override
  State<SelfReportForm> createState() => _SelfReportFormState();
}

class _SelfReportFormState extends State<SelfReportForm> {
  static const Color primaryPurple = Color.fromARGB(255, 115, 53, 191);
  static const Color accentPurple = Color(0xFF7B1FA2);
  
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController(); // Re-added
  final TextEditingController _descController = TextEditingController();

  // State Variables
  String? _selectedAssault;
  String? _selectedRelation;
  bool _alreadyReported = false;
  List<PlatformFile> _pickedFiles = []; 
  Map<String, Uint8List?> _videoThumbnails = {}; 
  bool _isLoading = false;

  final List<String> _assaultTypes = [
    'Physical Assault', 'Sexual Harassment', 'Psychological Abuse',
    'Stalking', 'Neglect', 'Other'
  ];

  final List<String> _relations = [
    'Family', 'Partner', 'Employer', 'Colleague', 'Stranger', 'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose(); // Dispose age
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true, 
      type: FileType.any
    );
    
    if (result != null) {
      for (var file in result.files) {
        if (['mp4', 'mov', 'avi', 'mkv'].contains(file.extension?.toLowerCase())) {
          final uint8list = await VideoThumbnail.thumbnailData(
            video: file.path!,
            imageFormat: ImageFormat.JPEG,
            maxWidth: 200,
            quality: 25,
          );
          setState(() {
            _videoThumbnails[file.path!] = uint8list;
            _pickedFiles.add(file);
          });
        } else {
          setState(() => _pickedFiles.add(file));
        }
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      final file = _pickedFiles[index];
      _videoThumbnails.remove(file.path);
      _pickedFiles.removeAt(index);
    });
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final uploadTasks = _pickedFiles.map((pickedFile) async {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
        final file = File(pickedFile.path!);
        
        await Supabase.instance.client.storage.from('evidence').upload(fileName, file);
        return Supabase.instance.client.storage.from('evidence').getPublicUrl(fileName);
      }).toList();

      List<String> evidenceUrls = await Future.wait(uploadTasks);

      await Supabase.instance.client.from('self_reports').insert({
        'full_name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'email_address': _emailController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()), // Added to DB insert
        'assault_type': _selectedAssault,
        'relationship': _selectedRelation,
        'description': _descController.text.trim(),
        'already_reported': _alreadyReported,
        'evidence_urls': evidenceUrls,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report filed securely."), backgroundColor: Colors.green),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildModernHeader(context),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel("Contact Information"),
                        const SizedBox(height: 16),
                        _buildCleanField("Full Name", Icons.person_rounded, _nameController),
                        _buildCleanField("Mobile Number", Icons.phone_android_rounded, _phoneController, isNumeric: true),
                        _buildCleanField("Email Address", Icons.email_outlined, _emailController),
                        _buildCleanField("Age", Icons.calendar_today_rounded, _ageController, isNumeric: true), // Age field added here
                        
                        const SizedBox(height: 12),
                        _buildSectionLabel("Incident Information"),
                        const SizedBox(height: 16),
                        _buildDropdownField("Type of Assault", _assaultTypes, _selectedAssault, (val) => setState(() => _selectedAssault = val)),
                        _buildDropdownField("Relationship to Perpetrator", _relations, _selectedRelation, (val) => setState(() => _selectedRelation = val)),
                        
                        const SizedBox(height: 8),
                        _buildLargeInputField("Detailed Description (Optional)", _descController),
                        
                        const SizedBox(height: 20),
                        _buildEvidenceGallery(),
                        
                        const SizedBox(height: 20),
                        _buildSwitchTile(),

                        const SizedBox(height: 32),
                        _isLoading 
                          ? const Center(child: CircularProgressIndicator(color: primaryPurple)) 
                          : _buildSubmitButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 70, 25, 45),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 20),
            const Text("Self Report", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1)),
            const SizedBox(height: 4),
            Text("Provide details securely and privately.", style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 16, letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: primaryPurple.withOpacity(0.7), letterSpacing: 1.2));
  }

  Widget _buildCleanField(String label, IconData icon, TextEditingController controller, {bool isNumeric = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontSize: 15, color: Colors.black),
        validator: (v) => (v == null || v.isEmpty) ? "Field required" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryPurple, size: 22),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          filled: true,
          fillColor: const Color(0xFFF3F4F9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        style: const TextStyle(fontSize: 15, color: Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black87),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          filled: true,
          fillColor: const Color(0xFFF3F4F9),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? "Required" : null,
      ),
    );
  }

  Widget _buildLargeInputField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      validator: (v) => (v == null || v.isEmpty) ? "Description required" : null,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        filled: true,
        fillColor: const Color(0xFFF3F4F9),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildEvidenceGallery() {
    return Column(
      children: [
        if (_pickedFiles.isNotEmpty)
          Container(
            height: 90,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _pickedFiles.length,
              itemBuilder: (context, index) {
                final file = _pickedFiles[index];
                final isImage = ['jpg', 'jpeg', 'png', 'webp'].contains(file.extension?.toLowerCase());

                return Stack(
                  children: [
                    Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 10, top: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryPurple.withOpacity(0.1)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: isImage 
                          ? Image.file(File(file.path!), fit: BoxFit.cover) // Real Image Preview
                          : _videoThumbnails[file.path] != null
                            ? Image.memory(_videoThumbnails[file.path]!, fit: BoxFit.cover) // Video Thumbnail
                            : const Center(child: Icon(Icons.insert_drive_file, color: primaryPurple)),
                      ),
                    ),
                    Positioned(
                      right: 2,
                      top: 0,
                      child: GestureDetector(
                        onTap: () => _removeFile(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        InkWell(
          onTap: _pickFiles,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: primaryPurple.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(15),
              color: primaryPurple.withOpacity(0.02),
            ),
            child: Column(
              children: [
                const Icon(Icons.cloud_upload_outlined, color: primaryPurple, size: 28),
                const SizedBox(height: 8),
                Text(
                  _pickedFiles.isEmpty ? "Add Photos/Videos" : "Add More Files",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: primaryPurple),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFF3F4F9), borderRadius: BorderRadius.circular(15)),
      child: SwitchListTile(
        title: const Text("Already reported to authorities?", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        value: _alreadyReported,
        activeColor: primaryPurple,
        onChanged: (val) => setState(() => _alreadyReported = val),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [primaryPurple, accentPurple]),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: primaryPurple.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: _submitReport,
        child: const Text("SUBMIT SECURELY", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }
}