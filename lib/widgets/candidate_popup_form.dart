import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/database_service.dart';
import '../models/company_model.dart';

class CandidatePopupForm extends StatefulWidget {
  final String initialPhone;
  final String? initialName;
  final String? initialRole;
  final String? initialLocation;
  final String? initialQualification;
  final String? initialExperience;
  final String? initialInterviewTime;
  final bool onlyEditTime;
  final void Function(Map<String, dynamic> candidateData) onBookInterview;

  const CandidatePopupForm({
    super.key,
    required this.initialPhone,
    this.initialName,
    this.initialRole,
    this.initialLocation,
    this.initialQualification,
    this.initialExperience,
    this.initialInterviewTime,
    this.onlyEditTime = false,
    required this.onBookInterview,
  });

  @override
  State<CandidatePopupForm> createState() => _CandidatePopupFormState();
}

class _CandidatePopupFormState extends State<CandidatePopupForm> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _mobileController = TextEditingController();
  final _experienceController = TextEditingController();
  
  // Selection states
  String? selectedLocality;
  String? selectedJobCategory;
  List<String> selectedQualifications = [];
  String? selectedCompanyId;
  String? selectedTimeSlot;
  bool isResumeUploaded = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  
  // Data from database
  List<String> localities = [];
  List<Company> companies = [];
  Company? selectedCompany;
  
  // Static options (these could also come from database)
  final List<String> jobCategories = [
    'Inside Sales', 'Developer', 'UI/UX Designer', 'Marketing', 'HR Executive'
  ];
  
  final List<String> qualifications = [
    '10th', '12th', 'Graduate', 'Post Graduate', 'Diploma'
  ];

  @override
  void initState() {
    super.initState();
    _mobileController.text = widget.initialPhone;
    // Use initial values if provided, otherwise leave empty
    if (widget.initialName != null && widget.initialName!.isNotEmpty) {
      final nameParts = widget.initialName!.split(' ');
      _firstNameController.text = nameParts.first;
      if (nameParts.length > 1) {
        _lastNameController.text = nameParts.sublist(1).join(' ');
      }
    }
    if (widget.initialExperience != null) {
      _experienceController.text = widget.initialExperience!;
    }
    // Age is not passed, so leave as is unless you add initialAge
    // Set other fields if initial values are provided
    if (widget.initialLocation != null) {
      selectedLocality = widget.initialLocation;
    }
    if (widget.initialRole != null) {
      selectedJobCategory = widget.initialRole;
    }
    if (widget.initialQualification != null && widget.initialQualification!.isNotEmpty) {
      selectedQualifications = widget.initialQualification!.split(',').map((q) => q.trim()).toList();
    }
    // Interview time is handled in the date/time picker logic
    _loadDataFromDatabase();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _ageController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _loadDataFromDatabase() async {
    try {
      final databaseService = DatabaseService();
      final loadedLocalities = await databaseService.getLocalities();
      final loadedCompanies = await databaseService.getCompanies();
      setState(() {
        localities = loadedLocalities;
        companies = loadedCompanies;
      });
    } catch (e) {
      setState(() {
        localities = [
          'Marathahalli', 'MG Layout', 'Whitefield', 'Koramangala', 'Bellandur'
        ];
        companies = [
          Company(id: '1', name: 'Client 1', address: 'The Skyline • Seoul Plaza Rd'),
          Company(id: '2', name: 'Client 2', address: 'Tech Park • Whitefield'),
          Company(id: '3', name: 'Client 3', address: 'Business Hub • Koramangala'),
        ];
      });
    }
  }

  void _simulateFileUpload() {
    setState(() {
      isResumeUploaded = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resume uploaded successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        selectedTimeSlot = null;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: primaryBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        final timeString = '${picked.format(context)} - ${picked.replacing(hour: picked.hour + 1).format(context)}';
        selectedTimeSlot = timeString;
      });
    }
  }

  void _onCompanySelected(String companyId) {
    setState(() {
      selectedCompanyId = companyId;
      selectedCompany = companies.firstWhere((company) => company.id == companyId);
    });
  }

  bool _showSelectionErrors = false;

  void _bookInterview() {
    setState(() {
      _showSelectionErrors = true;
    });
    if (_formKey.currentState!.validate()) {
      if (selectedLocality == null || 
          selectedJobCategory == null || 
          selectedQualifications.isEmpty ||
          selectedCompanyId == null ||
          selectedDate == null ||
          selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      widget.onBookInterview({
        'name': _firstNameController.text + (" ${_lastNameController.text}").trim(),
        'experience': _experienceController.text,
        'role': selectedJobCategory ?? '',
        'age': int.tryParse(_ageController.text) ?? 0,
        'location': selectedLocality ?? '',
        'qualification': selectedQualifications.isNotEmpty ? selectedQualifications.join(', ') : '',
        'addedDate': DateTime.now().toString().split(' ')[0],
        'status': 'active',
        'rating': 0.0,
        'notes': '',
        'phone': _mobileController.text,
      });
    }
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
      ),
    );
  }

  Widget _buildDateTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Slots',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                    color: selectedDate != null ? Colors.green.withOpacity(0.1) : Colors.white,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: selectedDate != null ? Colors.green : Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      if (selectedDate != null) ...[
                        Text(
                          _getWeekdayName(selectedDate!.weekday),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          '${selectedDate!.day}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          _getMonthName(selectedDate!.month),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.green,
                          ),
                        ),
                      ] else ...[
                        const Text(
                          'Select Date',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: selectedDate != null ? _selectTime : null,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: selectedDate != null 
                          ? Colors.grey.withOpacity(0.3) 
                          : Colors.grey.withOpacity(0.1),
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: selectedTime != null ? Colors.green.withOpacity(0.1) : Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: selectedTime != null ? Colors.green : 
                               selectedDate != null ? Colors.grey : Colors.grey.withOpacity(0.5),
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        selectedTime != null 
                            ? selectedTime!.format(context)
                            : selectedDate != null 
                                ? 'Select Time'
                                : 'Select Date First',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: selectedTime != null ? Colors.green : 
                                 selectedDate != null ? Colors.grey : Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Add Candidate Pop-up',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.code,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Form content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Info Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // First Name
                          TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: UnderlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Last Name
                          TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: UnderlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Age
                          TextFormField(
                            controller: _ageController,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              border: UnderlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final age = int.tryParse(value);
                              if (age == null) {
                                return 'Enter a valid number';
                              }
                              if (age < 18 || age > 65) {
                                return 'Enter age between 18 and 65';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Experience
                          TextFormField(
                            controller: _experienceController,
                            decoration: const InputDecoration(
                              labelText: 'Experience',
                              hintText: 'e.g. 2 years, 6 months',
                              border: UnderlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Mobile Number
                          TextFormField(
                            controller: _mobileController,
                            decoration: const InputDecoration(
                              labelText: 'Mobile Number',
                              border: UnderlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(vertical: 8),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              final phoneRegExp = RegExp(r'^\d{10} ?$');
                              if (!phoneRegExp.hasMatch(value)) {
                                return 'Enter a valid 10-digit number';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Locality Section
                    _buildSectionTitle('Locality'),
                    const SizedBox(height: 8),
                    localities.isEmpty 
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: localities.map((locality) {
                                  final isSelected = selectedLocality == locality;
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedLocality = locality;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected ? primaryBlue : Colors.blue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: isSelected ? primaryBlue : Colors.blue.withOpacity(0.3),
                                        ),
                                      ),
                                      child: Text(
                                        locality,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : primaryBlue,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (_showSelectionErrors && selectedLocality == null)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4, left: 4),
                                  child: Text(
                                    'Please select a locality',
                                    style: TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                    const SizedBox(height: 24),
                    // Job Category Section
                    _buildSectionTitle('Job Category'),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: jobCategories.map((category) {
                            final isSelected = selectedJobCategory == category;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedJobCategory = category;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.green : Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected ? Colors.green : Colors.green.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.green,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_showSelectionErrors && selectedJobCategory == null)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              'Please select a job category',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Qualification Section
                    _buildSectionTitle('Qualification'),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: qualifications.map((qualification) {
                            final isSelected = selectedQualifications.contains(qualification);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedQualifications.remove(qualification);
                                  } else {
                                    selectedQualifications.add(qualification);
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.orange : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.orange,
                                  ),
                                ),
                                child: Text(
                                  qualification,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_showSelectionErrors && selectedQualifications.isEmpty)
                          const Padding(
                            padding: EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              'Please select at least one qualification',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Upload Resume Section
                    _buildSectionTitle('Upload Resume'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _simulateFileUpload,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isResumeUploaded ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isResumeUploaded ? Colors.green : Colors.grey.withOpacity(0.3),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              isResumeUploaded ? Icons.check_circle : Icons.cloud_upload_outlined,
                              size: 40,
                              color: isResumeUploaded ? Colors.green : primaryBlue,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isResumeUploaded ? 'Resume_Sumona.pdf' : 'Upload Resume',
                              style: TextStyle(
                                fontSize: 14,
                                color: isResumeUploaded ? Colors.green : textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (!isResumeUploaded)
                              const Text(
                                'Tap to select resume file',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Company Selection
                    _buildSectionTitle('Select Company'),
                    const SizedBox(height: 8),
                    companies.isEmpty 
                        ? const Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: companies.map((company) {
                                  final isSelected = selectedCompanyId == company.id;
                                  return GestureDetector(
                                    onTap: () => _onCompanySelected(company.id),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          Radio<String>(
                                            value: company.id,
                                            groupValue: selectedCompanyId,
                                            onChanged: (value) => _onCompanySelected(value!),
                                            activeColor: primaryBlue,
                                          ),
                                          Expanded(
                                            child: Text(
                                              company.name,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: textDark,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              if (_showSelectionErrors && selectedCompanyId == null)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4, left: 4),
                                  child: Text(
                                    'Please select a company',
                                    style: TextStyle(color: Colors.red, fontSize: 12),
                                  ),
                                ),
                            ],
                          ),
                    const SizedBox(height: 24),
                    // Interview Schedule Section
                    _buildSectionTitle('Interview Schedule'),
                    const SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateTimeSelector(),
                        if (_showSelectionErrors && (selectedDate == null || selectedTime == null))
                          const Padding(
                            padding: EdgeInsets.only(top: 4, left: 4),
                            child: Text(
                              'Please select date and time',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (selectedCompany != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.business,
                              color: Colors.green,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    selectedCompany!.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    selectedCompany!.address,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
          // Book Interview Button
          Container(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _bookInterview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'BOOK INTERVIEW',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
