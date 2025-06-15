import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/notification_service.dart';
import '../../data/candidates_data.dart' as candidates_data;
import '../widgets/candidate_popup_form.dart';
import '../widgets/edit_candidate_popup.dart';
import '../../data/user_role.dart';

class CandidatesTabScreen extends StatefulWidget {
  final VoidCallback onBackToHome;
  const CandidatesTabScreen({super.key, required this.onBackToHome});

  @override
  State<CandidatesTabScreen> createState() => _CandidatesTabScreenState();
}

class _CandidatesTabScreenState extends State<CandidatesTabScreen> {
  final NotificationService _notificationService = NotificationService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  // Search variables
  String _searchQuery = '';
  bool _isSearching = false;
  List<Map<String, dynamic>> filteredCandidates = [];

  // Light button colors
  static const Color lightGreen = Color(0xFFD1EFEA); // Interview
  static const Color lightOrange = Color(0xFFFBE9B7); // Reschedule
  static const Color lightRed = Color(0xFFFFE8E8); // Reached

  // Button text colors
  static const Color interviewTextColor = Color(0xFF319582);
  static const Color rescheduleTextColor = Color(0xFF726E02);
  static const Color reachedTextColor = Color(0xFFFF3535);

  // All candidates data with additional fields for popup
  // Use the global candidates list
  List<Map<String, dynamic>> get allCandidates => candidates_data.globalCandidates;

  @override
  void initState() {
    super.initState();
    filteredCandidates = allCandidates;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterCandidates(_searchQuery);
    });
  }

  void _filterCandidates(String query) {
    if (query.isEmpty) {
      filteredCandidates = allCandidates;
      _isSearching = false;
    } else {
      _isSearching = true;
      filteredCandidates = allCandidates.where((candidate) {
        return candidate['name'].toLowerCase().contains(query.toLowerCase()) ||
               candidate['role'].toLowerCase().contains(query.toLowerCase()) ||
               candidate['location'].toLowerCase().contains(query.toLowerCase()) ||
               candidate['qualification'].toLowerCase().contains(query.toLowerCase()) ||
               candidate['experience'].toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
      filteredCandidates = allCandidates;
    });
  }

  // Show candidate details popup
  void _showCandidateDetails(Map<String, dynamic> candidate, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Theme.of(context).cardColor,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).cardColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with name and 3-dot menu
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            candidate['name'],
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            candidate['role'],
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: textSecondary),
                      onSelected: (String value) {
                        if (value == 'remove') {
                          final allIndex = allCandidates.indexOf(candidate);
                          _removeCandidate(allIndex);
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        if (currentUserRole == 'admin')
                          const PopupMenuItem<String>(
                            value: 'remove',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                SizedBox(width: 8),
                                Text('Remove Candidate'),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // Rating and View Resume
                Row(
                  children: [
                    // Rating stars (interactive)
                    Row(
                      children: [
                        Text(
                          candidate['rating'].toString(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          children: List.generate(5, (starIndex) {
                            if (currentUserRole == 'admin') {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop();
                                  setState(() {
                                    allCandidates[index]['rating'] = starIndex + 1.0;
                                    _filterCandidates(_searchQuery);
                                  });
                                  // Reopen the dialog to reflect the new rating
                                  Future.delayed(const Duration(milliseconds: 200), () {
                                    _showCandidateDetails(allCandidates[index], index);
                                  });
                                },
                                child: Icon(
                                  starIndex < candidate['rating'].floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 24,
                                ),
                              );
                            } else {
                              return Icon(
                                starIndex < candidate['rating'].floor()
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 24,
                              );
                            }
                          }),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // View Resume button
                    ElevatedButton(
                      onPressed: () {
                        print('View Resume for ${candidate['name']}');
                        // TODO: Implement view resume functionality
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE3F2FD),
                        foregroundColor: primaryBlue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'View Resume',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Details grid
                Row(
                  children: [
                    Expanded(
                      child: _buildPopupDetailItem('Job Title', candidate['role']),
                    ),
                    Expanded(
                      child: _buildPopupDetailItem('Experience', candidate['experience']),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildPopupDetailItem('Name', candidate['name']),
                    ),
                    Expanded(
                      child: _buildPopupDetailItem('Age', '${candidate['age']}'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildPopupDetailItem('Location', candidate['location']),
                    ),
                    Expanded(
                      child: _buildPopupDetailItem('Qualification', candidate['qualification']),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Notes section (editable)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                StatefulBuilder(
                  builder: (context, setStateDialog) {
                    final TextEditingController notesController = TextEditingController(text: candidate['notes'] ?? '');
                    return Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          ),
                          child: TextField(
                            controller: notesController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Write notes here...',
                            ),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, height: 1.4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              // Save notes
                              setState(() {
                                allCandidates[index]['notes'] = notesController.text;
                                _filterCandidates(_searchQuery);
                              });
                              // Reopen the dialog to reflect the new notes
                              Future.delayed(const Duration(milliseconds: 200), () {
                                _showCandidateDetails(allCandidates[index], index);
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text('Save Notes', style: Theme.of(context).textTheme.bodyLarge),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Action buttons: Only Reschedule for user
                if (currentUserRole != 'admin')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  insetPadding: const EdgeInsets.all(16),
                                  child: Container(
                                    width: double.infinity,
                                    constraints: BoxConstraints(
                                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                                    ),
                                    child: CandidatePopupForm(
                                      initialPhone: candidate['phone'] ?? '',
                                      initialName: candidate['name'],
                                      initialRole: candidate['role'],
                                      initialLocation: candidate['location'],
                                      initialQualification: candidate['qualification'],
                                      initialExperience: candidate['experience'],
                                      initialInterviewTime: candidate['interviewTime'],
                                      onlyEditTime: true,
                                      onBookInterview: (candidateData) {
                                        Navigator.pop(context);
                                        setState(() {
                                          allCandidates[index]['interviewTime'] = candidateData['interviewTime'];
                                        });
                                        _notificationService.addNotification(
                                          title: 'Interview Rescheduled',
                                          message: 'Interview rescheduled with ${candidate['name']}',
                                          type: NotificationType.reschedule,
                                          candidateName: candidate['name'],
                                        );
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Interview rescheduled with ${candidate['name']}'),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: lightOrange,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Reschedule',
                            style: TextStyle(
                              color: Color(0xFF726E02),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Close',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPopupDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // Remove candidate function
  void _removeCandidate(int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Remove Candidate'),
          content: Text('Are you sure you want to remove ${allCandidates[index]['name']} from the candidates list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  final removedCandidate = allCandidates[index];
                  allCandidates.removeAt(index);
                  _filterCandidates(_searchQuery);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${removedCandidate['name']} has been removed'),
                      backgroundColor: Colors.red,
                      action: SnackBarAction(
                        label: 'Undo',
                        textColor: Colors.white,
                        onPressed: () {
                          setState(() {
                            allCandidates.insert(index, removedCandidate);
                            _filterCandidates(_searchQuery);
                          });
                        },
                      ),
                    ),
                  );
                });
                Navigator.of(dialogContext).pop(); // Close confirmation dialog
                Navigator.of(dialogContext).pop(); // Close candidate details dialog
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Refresh candidates
  Future<void> _refreshCandidates() async {
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() {
      filteredCandidates = allCandidates;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Candidates list refreshed'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Show filter dialog
  void _showFilterDialog(BuildContext context) {
  // Filter controllers
  TextEditingController ageController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  showDialog(
  context: context,
  builder: (BuildContext context) {
  return AlertDialog(
  title: const Text('Filter Candidates'),
  content: Column(
  mainAxisSize: MainAxisSize.min,
  children: [
  TextField(
  controller: ageController,
  keyboardType: TextInputType.number,
  decoration: const InputDecoration(
  labelText: 'Age',
  hintText: 'Enter age',
  ),
  ),
  const SizedBox(height: 12),
  TextField(
  controller: roleController,
  decoration: const InputDecoration(
  labelText: 'Role',
  hintText: 'Enter role',
  ),
  ),
  const SizedBox(height: 12),
  TextField(
  controller: locationController,
  decoration: const InputDecoration(
  labelText: 'Location',
  hintText: 'Enter location',
  ),
  ),
  ],
  ),
  actions: [
  TextButton(
  onPressed: () => Navigator.pop(context),
  child: const Text('Cancel'),
  ),
  ElevatedButton(
  onPressed: () {
  // Apply filters
  String age = ageController.text.trim();
  String role = roleController.text.trim().toLowerCase();
  String location = locationController.text.trim().toLowerCase();
  setState(() {
  filteredCandidates = allCandidates.where((candidate) {
  bool matches = true;
  if (age.isNotEmpty) {
  matches = matches && candidate['age'].toString() == age;
  }
  if (role.isNotEmpty) {
  matches = matches && candidate['role'].toLowerCase().contains(role);
  }
  if (location.isNotEmpty) {
  matches = matches && candidate['location'].toLowerCase().contains(location);
  }
  return matches;
  }).toList();
  _isSearching = true;
  _searchQuery = '';
  });
  Navigator.pop(context);
  },
  child: const Text('Apply Filters'),
  ),
  ],
  );
  },
  );
  }

  // Add new candidate
  void _addNewCandidate() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: CandidatePopupForm(
              initialPhone: '',
              initialName: '',
              initialRole: '',
              initialLocation: '',
              initialQualification: '',
              initialExperience: '',
              initialInterviewTime: '',
              onlyEditTime: false,
              onBookInterview: (candidateData) {
                Navigator.pop(context);
                setState(() {
                  candidates_data.globalCandidates.insert(0, candidateData);
                  filteredCandidates = List.from(candidates_data.globalCandidates);
                  if (_searchQuery.isNotEmpty) {
                    _filterCandidates(_searchQuery);
                  }
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Candidate added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Edit candidate
  void _editCandidate(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditCandidatePopup(
          candidate: allCandidates[index],
          onSave: (updatedCandidate) {
            setState(() {
              allCandidates[index] = updatedCandidate;
              _filterCandidates(_searchQuery);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Candidate details updated'),
                backgroundColor: Colors.green,
              ),
            );
          },
        );
      },
    );
  }

  // QuickActionsHeaderDelegate class for the persistent header (removed duplicate definition from inside CandidatesTabScreen)

  // Go for interview
  void _goForInterview(int index) {
    _notificationService.addNotification(
      title: 'Interview Scheduled',
      message: 'Interview scheduled with ${allCandidates[index]['name']}',
      type: NotificationType.interview,
      candidateName: allCandidates[index]['name'],
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Interview scheduled with ${allCandidates[index]['name']}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Reschedule interview
  void _reschedule(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reschedule Interview'),
          content: Text('Reschedule interview with ${allCandidates[index]['name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _notificationService.addNotification(
                title: 'Interview Rescheduled',
                message: 'Interview rescheduled with ${allCandidates[index]['name']}',
                type: NotificationType.reschedule,
                candidateName: allCandidates[index]['name'],
                );
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Interview rescheduled with ${allCandidates[index]['name']}'),
                    backgroundColor: Colors.orange,
                  ),
                );
              },
              child: const Text('Reschedule'),
            ),
          ],
        );
      },
    );
  }

  // Mark as reached
  void _markReached(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Mark as Reached'),
          content: Text('Mark ${allCandidates[index]['name']} as reached?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  allCandidates[index]['status'] = 'reached';
                });
                _notificationService.addNotification(
                  title: 'Candidate Reached',
                  message: '${allCandidates[index]['name']} marked as reached',
                  type: NotificationType.reached,
                  candidateName: allCandidates[index]['name'],
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${allCandidates[index]['name']} marked as reached'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark Reached'),
            ),
          ],
        );
      },
    );
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
        title: _isSearching
          ? null
          : Row(
            children: [
            Text('Candidates List', style: Theme.of(context).appBarTheme.titleTextStyle),
            SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
              '${filteredCandidates.length}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
              ),
            ),
            ],
          ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 1,
        actions: [
        if (!_isSearching) ...[
          IconButton(
          icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            setState(() {
            _isSearching = true;
            });
          },
          ),
          IconButton(
          icon: Icon(Icons.filter_list, color: Theme.of(context).iconTheme.color),
          onPressed: () => _showFilterDialog(context),
          ),
        ] else ...[
          IconButton(
          icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
          onPressed: _clearSearch,
          ),
        ],
        ],
        bottom: _isSearching
          ? PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
              hintText: 'Search by name, role, location, qualification...',
              prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
              suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                  icon: Icon(Icons.clear, color: Theme.of(context).iconTheme.color),
                  onPressed: _clearSearch,
                  )
                : null,
              filled: true,
              fillColor: Theme.of(context).cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            ),
          )
          : null,
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCandidates,
        child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Search results header
          if (_isSearching) ...[
          SliverToBoxAdapter(
            child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
              Icon(
                filteredCandidates.isEmpty ? Icons.search_off : Icons.search,
                color: textSecondary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                filteredCandidates.isEmpty
                  ? 'No candidates found for "$_searchQuery"'
                  : '${filteredCandidates.length} candidate${filteredCandidates.length == 1 ? '' : 's'} found for "$_searchQuery"',
                style: const TextStyle(
                  color: textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                ),
              ),
              ],
            ),
            ),
          ),
          ],

          // Quick actions header removed

          // Candidates list
          if (filteredCandidates.isEmpty && _isSearching) ...[
          SliverFillRemaining(
            child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Icon(
                Icons.person_search,
                size: 80,
                color: textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'No candidates found',
                style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try searching with different keywords',
                style: TextStyle(
                fontSize: 14,
                color: textSecondary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear Search'),
                style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                ),
              ),
              ],
            ),
            ),
          ),
          ] else ...[
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
              final reversedList = filteredCandidates.reversed.toList();
              final candidateIndex = allCandidates.indexOf(reversedList[index]);
              return _buildCandidateCard(reversedList[index], candidateIndex);
              },
              childCount: filteredCandidates.length,
            ),
            ),
          ),

          // End of list indicator
          if (!_isSearching)
            SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
              child: Text(
                'End of candidates list',
                style: TextStyle(
                color: textSecondary,
                fontSize: 14,
                ),
              ),
              ),
            ),
            ),
          ],
        ],
        ),
      ),

      // Floating Action Button removed as per requirements
      floatingActionButton: null,
      ),
    );
  }

  Widget _buildCandidateCard(Map<String, dynamic> candidate, int index) {
    // Highlight search terms in candidate name
    Widget buildHighlightedText(String text, String query) {
      if (query.isEmpty) {
        return GestureDetector(
          onTap: () => _showCandidateDetails(candidate, index),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      }
      final lowerText = text.toLowerCase();
      final lowerQuery = query.toLowerCase();
      if (!lowerText.contains(lowerQuery)) {
        return GestureDetector(
          onTap: () => _showCandidateDetails(candidate, index),
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      }
      final startIndex = lowerText.indexOf(lowerQuery);
      final endIndex = startIndex + query.length;
      return GestureDetector(
        onTap: () => _showCandidateDetails(candidate, index),
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
              decoration: TextDecoration.underline,
            ),
            children: [
              TextSpan(text: text.substring(0, startIndex)),
              TextSpan(
                text: text.substring(startIndex, endIndex),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  backgroundColor: Colors.yellow,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              TextSpan(text: text.substring(endIndex)),
            ],
          ),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 20.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header with name and edit button
            Row(
              children: [
                // Candidate Info (expanded to take more space)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildHighlightedText(candidate['name'], _searchQuery),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green, width: 1),
                            ),
                            child: Text(
                              candidate['experience'],
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 1),
                              ),
                              child: Text(
                                candidate['role'],
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Edit button (always visible)
                IconButton(
                  onPressed: () => _editCandidate(index),
                  icon: Icon(Icons.edit_outlined, color: Theme.of(context).iconTheme.color),
                  tooltip: 'Edit Candidate',
                ),
                // Delete button (admin only)
                if (currentUserRole == 'admin')
                  IconButton(
                    onPressed: () => _removeCandidate(index),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    tooltip: 'Delete Candidate',
                  ),
              ],
            ),
            SizedBox(height: 16),
            // Candidate details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(Icons.location_on_outlined, candidate['location']),
                      SizedBox(height: 8),
                      _buildDetailRow(Icons.school_outlined, candidate['qualification']),
                      SizedBox(height: 8),
                      _buildDetailRow(Icons.calendar_today_outlined, 'Added: ${candidate['addedDate']}'),
                    ],
                  ),
                ),
                // Rating display (always show)
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 4),
                        Text(
                          candidate['rating'].toString(),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Rating',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            // Action buttons
            Row(
              children: [
                if (currentUserRole == 'admin') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _goForInterview(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGreen,
                        foregroundColor: interviewTextColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Interview'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                                ),
                                child: CandidatePopupForm(
                                  initialPhone: candidate['phone'] ?? '',
                                  initialName: candidate['name'],
                                  initialRole: candidate['role'],
                                  initialLocation: candidate['location'],
                                  initialQualification: candidate['qualification'],
                                  initialExperience: candidate['experience'],
                                  initialInterviewTime: candidate['interviewTime'],
                                  onlyEditTime: true,
                                  onBookInterview: (candidateData) {
                                    Navigator.pop(dialogContext);
                                    setState(() {
                                      allCandidates[index]['interviewTime'] = candidateData['interviewTime'];
                                    });
                                    _notificationService.addNotification(
                                      title: 'Interview Rescheduled',
                                      message: 'Interview rescheduled with ${candidate['name']}',
                                      type: NotificationType.reschedule,
                                      candidateName: candidate['name'],
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Interview rescheduled with ${candidate['name']}'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightOrange,
                        foregroundColor: rescheduleTextColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Reschedule'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _markReached(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightRed,
                        foregroundColor: reachedTextColor,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Reached'),
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _goForInterview(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightGreen,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Interview',
                        style: TextStyle(
                          color: Color(0xFF319582),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (dialogContext) {
                            return Dialog(
                              insetPadding: const EdgeInsets.all(16),
                              child: Container(
                                width: double.infinity,
                                constraints: BoxConstraints(
                                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                                ),
                                child: CandidatePopupForm(
                                  initialPhone: candidate['phone'] ?? '',
                                  initialName: candidate['name'],
                                  initialRole: candidate['role'],
                                  initialLocation: candidate['location'],
                                  initialQualification: candidate['qualification'],
                                  initialExperience: candidate['experience'],
                                  initialInterviewTime: candidate['interviewTime'],
                                  onlyEditTime: true,
                                  onBookInterview: (candidateData) {
                                    Navigator.pop(dialogContext);
                                    setState(() {
                                      allCandidates[index]['interviewTime'] = candidateData['interviewTime'];
                                    });
                                    _notificationService.addNotification(
                                      title: 'Interview Rescheduled',
                                      message: 'Interview rescheduled with ${candidate['name']}',
                                      type: NotificationType.reschedule,
                                      candidateName: candidate['name'],
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Interview rescheduled with ${candidate['name']}'),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightOrange,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reschedule',
                        style: TextStyle(
                          color: Color(0xFF726E02),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _markReached(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: lightRed,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Reached',
                        style: TextStyle(
                          color: Color(0xFFFF3535),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: textSecondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// QuickActionsHeaderDelegate removed
