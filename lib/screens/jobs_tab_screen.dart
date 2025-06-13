import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/job_model.dart';
import '../../data/user_role.dart';
import '../data/jobs_data.dart';

class JobsTabScreen extends StatefulWidget {
  final VoidCallback onBackToHome;
  const JobsTabScreen({super.key, required this.onBackToHome});

  @override
  State<JobsTabScreen> createState() => _JobsTabScreenState();
}

class _JobsTabScreenState extends State<JobsTabScreen> {
  String selectedFilter = 'All';
  String? expandedJobId;
  bool showFilterMenu = false;

  final List<String> filterOptions = [
    'All',
    'Full-Time',
    'Remote',
    'Hybrid',
    'Part-Time',
    'Internship'
  ];

  List<Job> get jobs => globalJobs;

  List<Job> get filteredJobs {
    if (selectedFilter == 'All') return jobs;
    return jobs.where((job) => job.type == selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        return false;
      },
      child: Scaffold(
        backgroundColor: lightGray,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBackToHome,
          ),
          title: const Text('Jobs'),
          backgroundColor: backgroundWhite,
          elevation: 1,
          titleTextStyle: const TextStyle(
            color: textDark,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list, color: textDark),
                  onPressed: () {
                    setState(() {
                      showFilterMenu = !showFilterMenu;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Filter Menu
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: showFilterMenu ? 120 : 0,
                  child: Container(
                    color: backgroundWhite,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Filter Menu...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textSecondary,
                            ),
                          ),
                        ),
                        Container(
                          height: 60,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: filterOptions.length,
                            itemBuilder: (context, index) {
                              final option = filterOptions[index];
                              final isSelected = selectedFilter == option;
                              return Container(
                                margin: const EdgeInsets.only(right: 12),
                                child: FilterChip(
                                  label: Text(option),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      selectedFilter = option;
                                      showFilterMenu = false;
                                    });
                                  },
                                  backgroundColor: backgroundWhite,
                                  selectedColor: primaryBlue.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: isSelected ? primaryBlue : textSecondary,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  side: BorderSide(
                                    color: isSelected ? primaryBlue : borderColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Post Job (admin only)
                if (currentUserRole == 'admin')
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Post Job'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () async {
                          final titleController = TextEditingController();
                          final companyController = TextEditingController();
                          final locationController = TextEditingController();
                          final salaryController = TextEditingController();
                          String type = 'Full-Time';
                          final descriptionController = TextEditingController();
                          final aboutController = TextEditingController();
                          final result = await showDialog<Map<String, String>>(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Post Job'),
                                content: SingleChildScrollView(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                        controller: titleController,
                                        decoration: const InputDecoration(labelText: 'Job Title'),
                                      ),
                                      TextField(
                                        controller: companyController,
                                        decoration: const InputDecoration(labelText: 'Company'),
                                      ),
                                      TextField(
                                        controller: locationController,
                                        decoration: const InputDecoration(labelText: 'Location'),
                                      ),
                                      TextField(
                                        controller: salaryController,
                                        decoration: const InputDecoration(labelText: 'Salary'),
                                      ),
                                      DropdownButtonFormField<String>(
                                        value: type,
                                        items: [
                                          'Full-Time', 'Remote', 'Hybrid', 'Part-Time', 'Internship'
                                        ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                                        onChanged: (val) => type = val ?? 'Full-Time',
                                        decoration: const InputDecoration(labelText: 'Type'),
                                      ),
                                      TextField(
                                        controller: descriptionController,
                                        decoration: const InputDecoration(labelText: 'Description'),
                                      ),
                                      TextField(
                                        controller: aboutController,
                                        decoration: const InputDecoration(labelText: 'About Company'),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      if (titleController.text.trim().isNotEmpty && companyController.text.trim().isNotEmpty) {
                                        Navigator.pop(context, {
                                          'title': titleController.text.trim(),
                                          'company': companyController.text.trim(),
                                          'location': locationController.text.trim(),
                                          'salary': salaryController.text.trim(),
                                          'type': type,
                                          'description': descriptionController.text.trim(),
                                          'about': aboutController.text.trim(),
                                        });
                                      }
                                    },
                                    child: const Text('Post'),
                                  ),
                                ],
                              );
                            },
                          );
                          if (result != null && result['title'] != null && result['company'] != null) {
                            setState(() {
                              globalJobs.insert(0, Job(
                                id: DateTime.now().millisecondsSinceEpoch.toString(),
                                title: result['title']!,
                                company: result['company']!,
                                location: result['location'] ?? '',
                                salary: result['salary'] ?? '',
                                type: result['type'] ?? 'Full-Time',
                                description: result['description'] ?? '',
                                responsibilities: [],
                                aboutCompany: result['about'] ?? '',
                              ));
                            });
                          }
                        },
                      ),
                    ),
                  ),
                // Job List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      final isExpanded = expandedJobId == job.id;

                      return Column(
                        children: [
                          JobCard(
                            job: job,
                            isExpanded: isExpanded,
                            onFullDetailsPressed: () {
                              setState(() {
                                expandedJobId = isExpanded ? null : job.id;
                              });
                            },
                          ),
                          if (isExpanded)
                            JobDetailsPanel(
                              job: job,
                              onClose: () {
                                setState(() {
                                  expandedJobId = null;
                                });
                              },
                            ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final Job job;
  final bool isExpanded;
  final VoidCallback onFullDetailsPressed;

  const JobCard({
    super.key,
    required this.job,
    required this.isExpanded,
    required this.onFullDetailsPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: const TextStyle(
                          fontSize: 14,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: greenAccent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job.type,
                    style: const TextStyle(
                      color: backgroundWhite,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: textSecondary),
                const SizedBox(width: 4),
                Text(
                  job.location,
                  style: const TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.attach_money, size: 16, color: textSecondary),
                const SizedBox(width: 4),
                Text(
                  job.salary,
                  style: const TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onFullDetailsPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  foregroundColor: buttonTextWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  isExpanded ? 'Hide Details' : 'Full Details',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JobDetailsPanel extends StatelessWidget {
  final Job job;
  final VoidCallback onClose;

  const JobDetailsPanel({
    super.key,
    required this.job,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: backgroundWhite,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.arrow_back, color: textDark),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.company,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Job Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job.salary,
                    style: const TextStyle(
                      color: primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: greenAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job.type,
                    style: const TextStyle(
                      color: greenAccent,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              job.description,
              style: const TextStyle(
                fontSize: 14,
                color: textSecondary,
                height: 1.5,
              ),
            ),
          ),
          // About the job
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'About the job',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  job.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Responsibilities',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                ...job.responsibilities.map((responsibility) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: textSecondary)),
                        Expanded(
                          child: Text(
                            responsibility,
                            style: const TextStyle(
                              fontSize: 14,
                              color: textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                const Text(
                  'About the Company',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  job.aboutCompany,
                  style: const TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
