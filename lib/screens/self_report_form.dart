import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

// --- MAP PICKER WIDGET ---
class MapPicker extends StatefulWidget {
  const MapPicker({super.key});

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  LatLng _pickedLocation = const LatLng(-1.286389, 36.817223);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pin Location"),
        backgroundColor: const Color.fromARGB(255, 115, 53, 191),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _pickedLocation),
            child: const Text("CONFIRM", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(target: _pickedLocation, zoom: 15),
        onTap: (LatLng position) {
          setState(() {
            _pickedLocation = position;
          });
        },
        markers: {
          Marker(
            markerId: const MarkerId("selected_point"),
            position: _pickedLocation,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          ),
        },
      ),
    );
  }
}

// --- MAIN REPORT FORM ---
class SelfReportForm extends StatefulWidget {
  const SelfReportForm({super.key});

  @override
  State<SelfReportForm> createState() => _SelfReportFormState();
}

class _SelfReportFormState extends State<SelfReportForm> {
  static const Color primaryPurple = Color.fromARGB(255, 115, 53, 191);
  static const Color accentPurple = Color(0xFF7B1FA2);
  
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String? _selectedAssault;
  String? _selectedRelation;
  String? _locationCoords; 
  bool _alreadyReported = false;
  List<PlatformFile> _pickedFiles = []; 
  Map<String, Uint8List?> _videoThumbnails = {}; 
  bool _isLoading = false;

  final List<String> _assaultTypes = ['Physical Assault', 'Sexual Harassment', 'Psychological Abuse', 'Stalking', 'Neglect', 'Other'];
  final List<String> _relations = ['Family', 'Partner', 'Employer', 'Colleague', 'Stranger', 'Other'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _descController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // File Picking Logic
  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.any);
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

  // Remove File Helper
  void _removeFile(int index) {
    setState(() {
      final file = _pickedFiles[index];
      _videoThumbnails.remove(file.path);
      _pickedFiles.removeAt(index);
    });
  }

  Future<void> _handleMapPinning() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MapPicker()),
    );
    if (result != null) {
      setState(() {
        _locationCoords = "${result.latitude}, ${result.longitude}";
      });
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      List<String> evidenceUrls = [];
      for (var pickedFile in _pickedFiles) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}';
        final file = File(pickedFile.path!);
        await Supabase.instance.client.storage.from('evidence').upload(fileName, file);
        final url = Supabase.instance.client.storage.from('evidence').getPublicUrl(fileName);
        evidenceUrls.add(url);
      }

      await Supabase.instance.client.from('self_reports').insert({
        'full_name': _nameController.text.trim(),
        'phone_number': _phoneController.text.trim(),
        'email_address': _emailController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()),
        'assault_type': _selectedAssault,
        'relationship': _selectedRelation,
        'description': _descController.text.trim(),
        'address': _addressController.text.trim(),
        'gps_location': _locationCoords,
        'already_reported': _alreadyReported,
        'evidence_urls': evidenceUrls,
        'created_at': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Report submitted successfully"), backgroundColor: Colors.green),
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
      backgroundColor: const Color(0xFFF8F9FE),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionLabel("Contact Information"),
                      const SizedBox(height: 16),
                      _buildCleanField("Full Name", Icons.person, _nameController),
                      _buildCleanField("Phone", Icons.phone, _phoneController, isNumeric: true),
                      _buildCleanField("Email (Optional)", Icons.email, _emailController, isRequired: false),
                      
                      const SizedBox(height: 12),
                      _buildSectionLabel("Incident Location"),
                      const SizedBox(height: 16),
                      _buildCleanField("Address / Area Name", Icons.location_city, _addressController),
                      _buildMapTriggerButton(),

                      const SizedBox(height: 12),
                      _buildSectionLabel("Report Details"),
                      const SizedBox(height: 16),
                      _buildDropdownField("Type of Assault", _assaultTypes, _selectedAssault, (val) => setState(() => _selectedAssault = val)),
                      _buildDropdownField("Relation to Person", _relations, _selectedRelation, (val) => setState(() => _selectedRelation = val)),
                      _buildLargeInputField("Description", _descController),
                      
                      const SizedBox(height: 20),
                      _buildEvidenceGallery(),
                      
                      const SizedBox(height: 32),
                      _isLoading 
                        ? const Center(child: CircularProgressIndicator(color: primaryPurple)) 
                        : _buildSubmitButton(),
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
      padding: const EdgeInsets.fromLTRB(25, 70, 25, 45),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [primaryPurple, accentPurple]),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Self Report", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          Text("Provide incident details securely", style: TextStyle(color: Colors.white70, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildEvidenceGallery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel("Evidence"),
        const SizedBox(height: 12),
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
                          ? Image.file(File(file.path!), fit: BoxFit.cover) 
                          : _videoThumbnails[file.path] != null
                            ? Image.memory(_videoThumbnails[file.path]!, fit: BoxFit.cover) 
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
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: primaryPurple.withOpacity(0.3), style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(15),
              color: primaryPurple.withOpacity(0.05),
            ),
            child: Column(
              children: [
                const Icon(Icons.upload_file, color: primaryPurple),
                const SizedBox(height: 8),
                Text(
                  _pickedFiles.isEmpty ? "Attach Photos/Videos" : "Add More Evidence", 
                  style: const TextStyle(color: primaryPurple, fontWeight: FontWeight.bold)
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapTriggerButton() {
    bool isPinned = _locationCoords != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: _handleMapPinning,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPinned ? Colors.green.withOpacity(0.1) : primaryPurple.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isPinned ? Colors.green : primaryPurple.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Icon(isPinned ? Icons.check_circle : Icons.map_outlined, color: isPinned ? Colors.green : primaryPurple),
              const SizedBox(width: 12),
              Text(
                isPinned ? "Location Pinned" : "Pin Exact Location on Map",
                style: TextStyle(fontWeight: FontWeight.bold, color: isPinned ? Colors.green : primaryPurple),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) => Text(text.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.1));

  Widget _buildCleanField(String label, IconData icon, TextEditingController controller, {bool isNumeric = false, bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        validator: (v) => isRequired && (v == null || v.isEmpty) ? "Required" : null,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: primaryPurple),
          labelText: label,
          filled: true,
          fillColor: const Color(0xFFF3F4F9),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? value, ValueChanged<String?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label, filled: true, fillColor: const Color(0xFFF3F4F9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? "Required" : null,
      ),
    );
  }

  Widget _buildLargeInputField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(labelText: label, filled: true, fillColor: const Color(0xFFF3F4F9), border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _submitReport,
        style: ElevatedButton.styleFrom(backgroundColor: primaryPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        child: const Text("SUBMIT REPORT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
