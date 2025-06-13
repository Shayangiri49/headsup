import 'package:flutter/material.dart';
import '../services/notification_service.dart' show NotificationItem, NotificationType, NotificationService;
import 'package:fl_chart/fl_chart.dart';
import '../widgets/candidate_popup_form.dart';
import '../../main.dart' show themeModeNotifier;

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _phoneController = TextEditingController();

  // Time period selection
  String selectedPeriod = 'Weekly';

  // Sample data for different periods (same as before)
  Map<String, Map<String, dynamic>> performanceData = {
    'Daily': {
      'joinings': 3,
      'closures': 2,
      'attendance': 1,
      'chartData': [2, 1, 3, 2, 1, 3, 2],
      'labels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      'attendanceData': [8, 7, 8, 6, 8, 0, 0],
    },
    'Weekly': {
      'joinings': 12,
      'closures': 8,
      'attendance': 5,
      'chartData': [8, 12, 15, 10, 18, 12, 20],
      'labels': ['W1', 'W2', 'W3', 'W4', 'W5', 'W6', 'W7'],
      'attendanceData': [5, 4, 5, 3, 5, 4, 5],
    },
    'Monthly': {
      'joinings': 45,
      'closures': 32,
      'attendance': 22,
      'chartData': [35, 42, 38, 45, 52, 48, 55],
      'labels': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'],
      'attendanceData': [22, 20, 23, 18, 24, 21, 25],
    },
  };

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _addCandidate() {
    if (_phoneController.text.isNotEmpty) {
      _showCandidatePopup();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter mobile number or email'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCandidatePopup() {
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
              initialPhone: _phoneController.text,
              onBookInterview: () {
                Navigator.pop(context); // Close popup
                _phoneController.clear(); // Clear input
                _navigateToCandidatesTab();
              },
            ),
          ),
        );
      },
    );
  }

  void _navigateToCandidatesTab() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Interview booked successfully! Check Candidates tab for details.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentData = performanceData[selectedPeriod]!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  Text(
                    'Services',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Row(
                    children: [
                      ValueListenableBuilder<List<NotificationItem>>(
                        valueListenable: _notificationService.notificationsNotifier,
                        builder: (context, notifications, child) {
                          final unreadCount = notifications.where((n) => !n.isRead).length;
                          return Stack(
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.notifications_outlined,
                                  color: Theme.of(context).iconTheme.color,
                                  size: 24,
                                ),
                                onPressed: () => _showNotifications(context),
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    child: Text(
                                      unreadCount.toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.settings_outlined,
                          color: Theme.of(context).iconTheme.color,
                          size: 24,
                        ),
                        onPressed: () => _showSettingsBottomSheet(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Main content area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Add Candidate Section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              hintText: 'Enter mobile number or email',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _addCandidate,
                              style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A90E2),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              ),
                              ),
                              child: const Text(
                                'ADD CANDIDATE',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      context,
                      title: 'Targets For Today',
                      child: Column(
                        children: [
                          _buildTargetItem(context, 'Target Interview Scheduled', '7/10', Colors.green),
                          const SizedBox(height: 12),
                          _buildTargetItem(context, 'In Progress', 'GFE Calling (Telecaller: Abinayhen)', Colors.orange),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      context,
                      title: 'Performance',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildPeriodButton(context, 'Daily')),
                              Expanded(child: _buildPeriodButton(context, 'Weekly')),
                              Expanded(child: _buildPeriodButton(context, 'Monthly')),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildPerformanceMetric(
                            context,
                            '${currentData['joinings']} Joinings',
                            'This ${selectedPeriod.toLowerCase()}',
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 120,
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() < currentData['labels'].length) {
                                          return Text(
                                            currentData['labels'][value.toInt()],
                                            style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: List.generate(
                                      currentData['chartData'].length,
                                      (index) => FlSpot(
                                        index.toDouble(),
                                        currentData['chartData'][index].toDouble(),
                                      ),
                                    ),
                                    isCurved: true,
                                    color: Theme.of(context).colorScheme.primary,
                                    barWidth: 3,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 4,
                                          color: Theme.of(context).colorScheme.primary,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildPerformanceMetric(
                            context,
                            '${currentData['closures']} Closures',
                            '',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      context,
                      title: 'Attendance',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _buildPeriodButton(context, 'Daily', isAttendance: true)),
                              Expanded(child: _buildPeriodButton(context, 'Weekly', isAttendance: true)),
                              Expanded(child: _buildPeriodButton(context, 'Monthly', isAttendance: true)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildPerformanceMetric(
                            context,
                            '${currentData['attendance']} days',
                            'This ${selectedPeriod.toLowerCase()}',
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 120,
                            child: BarChart(
                              BarChartData(
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() < currentData['labels'].length) {
                                          return Text(
                                            currentData['labels'][value.toInt()],
                                            style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(
                                  currentData['attendanceData'].length,
                                  (index) => BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: currentData['attendanceData'][index].toDouble(),
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                        width: 20,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(4),
                                          topRight: Radius.circular(4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildTargetItem(BuildContext context, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(BuildContext context, String period, {bool isAttendance = false}) {
    final isSelected = selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          period,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceMetric(BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
      ],
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return ValueListenableBuilder<List<NotificationItem>>(
              valueListenable: _notificationService.notificationsNotifier,
              builder: (context, notifications, child) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Notifications',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          if (notifications.isNotEmpty)
                            TextButton(
                              onPressed: () {
                                _notificationService.markAllAsRead();
                              },
                              child: const Text('Mark all as read'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: notifications.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.notifications_none,
                                      size: 64,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No notifications yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(context).textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: notifications.length,
                                itemBuilder: (context, index) {
                                  final notification = notifications[index];
                                  return _buildNotificationItem(context, notification);
                                },
                              ),
                      ),
                      if (notifications.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                _notificationService.clearAll();
                              },
                              child: const Text('Clear All Notifications'),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: themeModeNotifier.value == ThemeMode.dark,
                onChanged: (value) {
                  themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                },
                secondary: Icon(
                  themeModeNotifier.value == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              ListTile(
                leading: Icon(Icons.account_circle_outlined, color: Theme.of(context).colorScheme.primary),
                title: Text('Account Settings', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                trailing: Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
                onTap: () {
                  Navigator.pop(context);
                  // Add your account settings navigation here
                },
              ),
              ListTile(
                leading: Icon(Icons.notifications_outlined, color: Theme.of(context).colorScheme.primary),
                title: Text('Notifications', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                trailing: Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
                onTap: () {
                  Navigator.pop(context);
                  // Add your notifications navigation here
                },
              ),
              ListTile(
                leading: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.primary),
                title: Text('Help & Support', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                trailing: Icon(Icons.chevron_right, color: Theme.of(context).iconTheme.color),
                onTap: () {
                  Navigator.pop(context);
                  // Add your help & support navigation here
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Add your logout logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Logout'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Notification item builder
  Widget _buildNotificationItem(BuildContext context, NotificationItem notification) {
    IconData getIcon() {
      switch (notification.type) {
        case NotificationType.interview:
          return Icons.calendar_today;
        case NotificationType.reschedule:
          return Icons.schedule;
        case NotificationType.reached:
          return Icons.check_circle;
        default:
          return Icons.notifications;
      }
    }

    Color getColor() {
      switch (notification.type) {
        case NotificationType.interview:
          return Colors.green;
        case NotificationType.reschedule:
          return Colors.orange;
        case NotificationType.reached:
          return Colors.red;
        default:
          return Theme.of(context).colorScheme.primary;
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: notification.isRead ? 1 : 3,
      color: notification.isRead ? null : Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: getColor().withOpacity(0.1),
          child: Icon(
            getIcon(),
            color: getColor(),
            size: 20,
          ),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(notification.timestamp),
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: notification.isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
        onTap: () {
          if (!notification.isRead) {
            _notificationService.markAsRead(notification.id);
          }
        },
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    }
  }
}
