import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class SelfReportForm extends StatefulWidget {
  const SelfReportForm({super.key});

  @override
  State<SelfReportForm> createState() => _SelfReportFormState();
}

class _SelfReportFormState extends State<SelfReportForm> {
  final Color primaryPurple = const Color(0xFF9161F2);
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  // State Variables
  String? _selectedAssault;
  String? _selectedRelation;
  bool _alreadyReported = false;
  PlatformFile? _pickedFile; // To store the selected file
  bool _isLoading = false;   // To show a spinner during upload

  final List<String> _assaultTypes = [
    'Physical Assault', 'Sexual Harassment', 'Psychological or Emotional Abuse',
    'Stalking', 'Neglect', 'Other'
  ];

  final List<String> _relations = [
    'Family', 'Partner', 'Ex-Partner', 'Employer', 
    'Colleague', 'Neighbor', 'Stranger', 'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // --- LOGIC: PICK FILE ---
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result != null) {
      setState(() => _pickedFile = result.files.first);
    }
  }

  // --- LOGIC: SUBMIT TO SUPABASE ---
  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? evidenceUrl;

      // 1. Upload file if one was picked
      if (_pickedFile != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${_pickedFile!.name}';
        final file = File(_pickedFile!.path!);

        // Upload to the "evidence" bucket you just created
        await Supabase.instance.client.storage
            .from('evidence')
            .upload(fileName, file);

        // Get the public URL for the database record
        evidenceUrl = Supabase.instance.client.storage
            .from('evidence')
            .getPublicUrl(fileName);
      }

      // 2. Save form data to the "self_reports" table
      await Supabase.instance.client.from('self_reports').insert({
        'full_name': _nameController.text,
        'age': int.parse(_ageController.text),
        'assault_type': _selectedAssault,
        'relationship': _selectedRelation,
        'description': _descController.text,
        'already_reported': _alreadyReported,
        'evidence_url': evidenceUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report submitted successfully!")),
        );
        Navigator.pop(context); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Submission failed: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildConsistentHeader("Self Report"),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildFormCard("Victim Information", [
                      _buildTextField("Full Name", Icons.person_outline, _nameController, isRequired: true),
                      _buildTextField("Age", Icons.cake_outlined, _ageController, 
                          keyboardType: TextInputType.number, isRequired: true),
                    ]),

                    _buildFormCard("Incident Classification", [
                      _buildDropdown("Type of Assault", _assaultTypes, _selectedAssault, 
                          (val) => setState(() => _selectedAssault = val)),
                      _buildDropdown("Relation to Perpetrator", _relations, _selectedRelation, 
                          (val) => setState(() => _selectedRelation = val)),
                    ]),

                    _buildFormCard("Incident Details", [
                      _buildLargeTextField("Describe the incident in detail...", _descController),
                      const SizedBox(height: 20),
                      _buildFileUploadSection(), // Updated to use _pickFile
                      const Divider(height: 30),
                      _buildActionRow("Pin Incident Location", Icons.location_on_outlined),
                    ]),

                    _buildFormCard("Legal Status", [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Already Reported to Authorities?"),
                        subtitle: Text(_alreadyReported ? "Yes" : "No"),
                        value: _alreadyReported,
                        activeColor: primaryPurple,
                        onChanged: (val) => setState(() => _alreadyReported = val),
                      ),
                    ]),

                    const SizedBox(height: 20),
                    _isLoading 
                      ? const CircularProgressIndicator() 
                      : _buildSubmitButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildTextField(String label, IconData icon, TextEditingController controller, {TextInputType? keyboardType, bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: isRequired ? (value) => (value == null || value.isEmpty) ? "Required" : null : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryPurple, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? currentValue, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: label, 
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? "Please select" : null,
      ),
    );
  }

  Widget _buildLargeTextField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return InkWell(
      onTap: _pickFile,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: primaryPurple.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primaryPurple.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_upload_outlined, color: primaryPurple),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                _pickedFile?.name ?? "Tap to upload files", 
                style: const TextStyle(fontSize: 14)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConsistentHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 25, bottom: 40),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF9161F2), Color(0xFF5B4BDB)]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackButton(color: Colors.white),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Your Safety, Our Priority", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildFormCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildActionRow(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: primaryPurple),
          const SizedBox(width: 15),
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const Spacer(),
          const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: _submitReport,
        child: const Text("SUBMIT REPORT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}