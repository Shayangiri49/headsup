import 'package:flutter/material.dart';

class EditCandidatePopup extends StatefulWidget {
  final Map<String, dynamic> candidate;
  final void Function(Map<String, dynamic> updatedCandidate) onSave;

  const EditCandidatePopup({
    Key? key,
    required this.candidate,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditCandidatePopup> createState() => _EditCandidatePopupState();
}

class _EditCandidatePopupState extends State<EditCandidatePopup> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController roleController;
  late TextEditingController locationController;
  late TextEditingController qualificationController;
  late TextEditingController experienceController;
  late TextEditingController ageController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.candidate['name'] ?? '');
    phoneController = TextEditingController(text: widget.candidate['phone'] ?? '');
    roleController = TextEditingController(text: widget.candidate['role'] ?? '');
    locationController = TextEditingController(text: widget.candidate['location'] ?? '');
    qualificationController = TextEditingController(text: widget.candidate['qualification'] ?? '');
    experienceController = TextEditingController(text: widget.candidate['experience'] ?? '');
    ageController = TextEditingController(text: widget.candidate['age']?.toString() ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    roleController.dispose();
    locationController.dispose();
    qualificationController.dispose();
    experienceController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Candidate',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: qualificationController,
                decoration: const InputDecoration(labelText: 'Qualification'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: experienceController,
                decoration: const InputDecoration(labelText: 'Experience'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      final updatedCandidate = Map<String, dynamic>.from(widget.candidate);
                      updatedCandidate['name'] = nameController.text;
                      updatedCandidate['phone'] = phoneController.text;
                      updatedCandidate['role'] = roleController.text;
                      updatedCandidate['location'] = locationController.text;
                      updatedCandidate['qualification'] = qualificationController.text;
                      updatedCandidate['experience'] = experienceController.text;
                      updatedCandidate['age'] = int.tryParse(ageController.text) ?? widget.candidate['age'];
                      widget.onSave(updatedCandidate);
                      Navigator.pop(context);
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
