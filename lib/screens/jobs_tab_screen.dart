import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../models/job_model.dart';

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

  // Sample job data
  final List<Job> jobs = [
    Job(
      id: '1',
      title: 'Senior Product Designer',
      company: 'Tech Innovators Inc.',
      location: 'San Francisco, CA',
      salary: '\$80k - \$100k',
      type: 'Remote',
      description: 'We are seeking a dynamic Human Resource Recruiter to join our team. The successful candidate will be responsible for attracting, screening, and recruiting various positions within the company. This role requires excellent communication and interpersonal skills, as well as a strong understanding of recruitment processes.',
      responsibilities: [
        'Manage the full recruitment cycle',
        'Develop and implement recruitment strategies',
        'Conduct interviews and assess candidates\' qualifications'
      ],
      aboutCompany: 'Tech Innovators Inc. is a leading technology company focused on creating innovative solutions for the future. We are committed to fostering a collaborative environment where our employees can thrive and grow. Our mission is to empower individuals and businesses through cutting-edge technology.',
    ),
    Job(
      id: '2',
      title: 'Senior Product Designer',
      company: 'Design Studio Co.',
      location: 'New York, NY',
      salary: '\$70k - \$90k',
      type: 'Full-Time',
      description: 'Join our creative team as a Senior Product Designer. You will be responsible for creating user-centered designs and innovative solutions.',
      responsibilities: [
        'Create wireframes and prototypes',
        'Collaborate with development team',
        'Conduct user research and testing'
      ],
      aboutCompany: 'Design Studio Co. is a creative agency specializing in digital experiences and brand identity.',
    ),
    Job(
      id: '3',
      title: 'Senior Product Designer',
      company: 'Innovation Labs',
      location: 'Austin, TX',
      salary: '\$75k - \$95k',
      type: 'Hybrid',
      description: 'We are looking for a passionate Senior Product Designer to help shape the future of our products.',
      responsibilities: [
        'Design user interfaces',
        'Create design systems',
        'Mentor junior designers'
      ],
      aboutCompany: 'Innovation Labs focuses on breakthrough technologies and user experience design.',
    ),
  ];

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

class JobDetailsPanel extends StatefulWidget {
  final Job job;
  final VoidCallback onClose;

  const JobDetailsPanel({
    super.key,
    required this.job,
    required this.onClose,
  });

  @override
  State<JobDetailsPanel> createState() => _JobDetailsPanelState();
}

class _JobDetailsPanelState extends State<JobDetailsPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, (1 - _slideAnimation.value) * 50),
          child: Opacity(
            opacity: _slideAnimation.value,
            child: Container(
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
                          onPressed: widget.onClose,
                          icon: const Icon(Icons.arrow_back, color: textDark),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.job.company,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                              Text(
                                widget.job.title,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                        onPressed: () async {
                        final shareText =
                        '${widget.job.title} at ${widget.job.company}\nLocation: ${widget.job.location}\nSalary: ${widget.job.salary}\nType: ${widget.job.type}\n\n${widget.job.description}';
                        // ignore: use_build_context_synchronously
                        await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                        title: const Text('Share'),
                        content: Text('Sharing...'),
                        ),
                        );
                        // You should use Share.share(shareText) from share_plus package in real app
                        },
                        icon: const Icon(Icons.share, color: textDark),
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
                            widget.job.salary,
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
                            widget.job.type,
                            style: const TextStyle(
                              color: greenAccent,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () {
                            // Handle save
                            print('Save pressed');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: buttonTextWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Save'),
                        ),
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
                          widget.job.description,
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
                        ...widget.job.responsibilities.map((responsibility) {
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
                          widget.job.aboutCompany,
                          style: const TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Similar Jobs',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3, // Sample similar jobs
                            itemBuilder: (context, index) {
                              return Container(
                                width: 200,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: lightGray,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(Icons.work, size: 40, color: textSecondary),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            index == 0 ? 'Talent Acquisition Specialist' : 
                                            index == 1 ? 'HR Generalist' : 'Recruiter',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: textDark,
                                            ),
                                          ),
                                          Text(
                                            'San Francisco, CA',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
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
  }
}
