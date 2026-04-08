import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';

class ThirdPartyReportForm extends StatefulWidget {
  const ThirdPartyReportForm({super.key});

  @override
  State<ThirdPartyReportForm> createState() => _ThirdPartyReportFormState();
}

class _ThirdPartyReportFormState extends State<ThirdPartyReportForm> {
  final Color primaryPurple = const Color(0xFF9161F2);
  final Color darkPurple = const Color(0xFF5B4BDB);
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _reporterName = TextEditingController();
  final _reporterContact = TextEditingController();
  final _reporterRelation = TextEditingController();
  final _victimName = TextEditingController();
  final _descController = TextEditingController();

  // State
  String? _selectedAssault;
  String? _selectedVictimRelation;
  bool _alreadyReported = false;
  PlatformFile? _pickedFile;
  bool _isLoading = false;

  @override
  void dispose() {
    for (var c in [_reporterName, _reporterContact, _reporterRelation, _victimName, _descController]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) setState(() => _pickedFile = result.files.first);
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      String? evidenceUrl;
      if (_pickedFile != null) {
        final fileName = '3rd_${DateTime.now().millisecondsSinceEpoch}_${_pickedFile!.name}';
        await Supabase.instance.client.storage.from('evidence').upload(fileName, File(_pickedFile!.path!));
        evidenceUrl = Supabase.instance.client.storage.from('evidence').getPublicUrl(fileName);
      }

      await Supabase.instance.client.from('third_party_reports').insert({
        'reporter_name': _reporterName.text,
        'reporter_contact': _reporterContact.text,
        'reporter_relation': _reporterRelation.text,
        'victim_name': _victimName.text,
        'assault_type': _selectedAssault,
        'victim_relation_to_perpetrator': _selectedVictimRelation,
        'description': _descController.text,
        'already_reported': _alreadyReported,
        'evidence_url': evidenceUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Report Submitted Successfully")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
        child: Column(
          children: [
            _buildConsistentHeader("Reporting for Others"),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildFormCard("Reporter Information (You)", [
                      _buildTextField("Your Full Name", Icons.account_box, _reporterName),
                      _buildTextField("Your Contact Details", Icons.phone, _reporterContact),
                      _buildTextField("Your Relation to Victim", Icons.link, _reporterRelation),
                    ]),


                  
                    _buildFormCard("Victim Information", [
                      _buildTextField("Survivor's Full Name", Icons.person_outline, _victimName),
                      _buildDropdown("Type of Assault", ['Physical Assault', 'Sexual Harassment', 'Psychological or Emotional Abuse',
                        'Stalking', 'Other'], (val) => _selectedAssault = val),
                      _buildDropdown("Relation to Perpetrator", ['Family', 'Partner', 'Ex-Partner', 'Employer', 
                       'Colleague', 'Neighbor', 'Stranger', 'Other'], (val) => _selectedVictimRelation = val),
                    ]),
                    _buildFormCard("Incident Context", [
                      _buildLargeTextField("Describe what happened...", _descController),
                      const SizedBox(height: 15),
                      _buildActionRow(_pickedFile?.name ?? "Add Proof/Evidence", Icons.attachment, onTap: _pickFile),
                    ]),
                    _buildFormCard("Submission", [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Has this been reported before?"),
                        value: _alreadyReported,
                        activeColor: primaryPurple,
                        onChanged: (val) => setState(() => _alreadyReported = val),
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildSubmitButton(),
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

  // --- REUSABLE UI HELPERS ---
  Widget _buildTextField(String label, IconData icon, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        validator: (v) => v!.isEmpty ? "Required" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: primaryPurple, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChange) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChange,
        validator: (v) => v == null ? "Required" : null,
      ),
    );
  }

  Widget _buildLargeTextField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(hintText: hint, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
    );
  }

  Widget _buildActionRow(String label, IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: primaryPurple),
            const SizedBox(width: 15),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
            const Icon(Icons.add_circle_outline, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        onPressed: _submitReport,
        child: const Text("SUBMIT REPORT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildConsistentHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 25, bottom: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryPurple, darkPurple]),
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildFormCard(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 15),
        ...children,
      ]),
    );
  }
}