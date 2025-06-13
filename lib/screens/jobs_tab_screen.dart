import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/job_model.dart';
import '../../data/user_role.dart';
import '../data/jobs_data.dart';

// Helper widget for styled text fields in the dialog
class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final int maxLines;
  final TextInputType? keyboardType;

  const _StyledTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.maxLines = 1,
    this.keyboardType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodyMedium,
        prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
        filled: true,
        fillColor: isDark ? Colors.white10 : Colors.blue.withOpacity(0.06),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
            onPressed: widget.onBackToHome,
          ),
          title: Text('Jobs', style: Theme.of(context).appBarTheme.titleTextStyle),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 1,
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.filter_list, color: Theme.of(context).iconTheme.color),
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
                    color: Theme.of(context).cardColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Filter Menu...',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
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
                                  backgroundColor: Theme.of(context).cardColor,
                                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                  labelStyle: TextStyle(
                                    color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyMedium?.color,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  side: BorderSide(
                                    color: isSelected ? Theme.of(context).colorScheme.primary : borderColor,
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
                          return Dialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          backgroundColor: Theme.of(context).cardColor,
                          child: SingleChildScrollView(
                          child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                          // Header
                          Container(
                          decoration: BoxDecoration(
                          color: primaryBlue,
                          borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          ),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                          child: Row(
                          children: const [
                          Icon(Icons.work, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                          'Post a Job',
                          style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          ),
                          ),
                          ],
                          ),
                          ),
                          Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                          _StyledTextField(
                          controller: titleController,
                          label: 'Job Title',
                          icon: Icons.title,
                          ),
                          const SizedBox(height: 14),
                          _StyledTextField(
                          controller: companyController,
                          label: 'Company',
                          icon: Icons.business,
                          ),
                          const SizedBox(height: 14),
                          _StyledTextField(
                          controller: locationController,
                          label: 'Location',
                          icon: Icons.location_on,
                          ),
                          const SizedBox(height: 14),
                          _StyledTextField(
                          controller: salaryController,
                          label: 'Salary',
                          icon: Icons.attach_money,
                          keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 14),
                          Container(
                          decoration: BoxDecoration(
                          color: lightGray,
                          borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonFormField<String>(
                          value: type,
                          items: [
                          'Full-Time', 'Remote', 'Hybrid', 'Part-Time', 'Internship'
                          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                          onChanged: (val) => type = val ?? 'Full-Time',
                          decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(12))),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          ),
                          style: const TextStyle(fontSize: 16, color: textDark),
                          ),
                          ),
                          const SizedBox(height: 14),
                          _StyledTextField(
                          controller: descriptionController,
                          label: 'Description',
                          icon: Icons.description,
                          maxLines: 2,
                          ),
                          const SizedBox(height: 14),
                          _StyledTextField(
                          controller: aboutController,
                          label: 'About Company',
                          icon: Icons.info_outline,
                          maxLines: 2,
                          ),
                          const SizedBox(height: 24),
                          Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                          TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).textTheme.bodyMedium?.color,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
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
                          style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          child: const Text('Post'),
                          ),
                          ],
                          ),
                          ],
                          ),
                          ),
                          ],
                          ),
                          ),
                          ),
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
        color: Theme.of(context).cardColor,
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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
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
                      color: Colors.white,
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
                Icon(Icons.location_on, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                const SizedBox(width: 4),
                Text(
                  job.location,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                ),
                const SizedBox(width: 16),
                Icon(Icons.attach_money, size: 16, color: Theme.of(context).textTheme.bodyMedium?.color),
                const SizedBox(width: 4),
                Text(
                  job.salary,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onFullDetailsPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
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
        color: Theme.of(context).cardColor,
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
                  icon: Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.company,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        job.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
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
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job.salary,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
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
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              job.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
            ),
          ),
          // About the job
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About the job',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  job.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Responsibilities',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...job.responsibilities.map((responsibility) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: Theme.of(context).textTheme.bodyMedium),
                        Expanded(
                          child: Text(
                            responsibility,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
                Text(
                  'About the Company',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  job.aboutCompany,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
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
