import 'dart:ui';

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'auth_service.dart';

class MyAppointmentPage extends StatefulWidget {
  const MyAppointmentPage({super.key});

  @override
  State<MyAppointmentPage> createState() => _MyAppointmentPageState();
}

class _MyAppointmentPageState extends State<MyAppointmentPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomIndex = 1; // Appointments tab selected
  List<dynamic> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // Initialize the TabController with 3 tabs
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);

    // Then fetch appointments
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    try {
      final token = await AuthService.getToken();

      if (token == null) return;

      final result = await ApiService.fetchAppointments(token: token);

      if (result['ok'] == true) {
        setState(() {
          appointments = result['appointments'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _cancelAppointment(String id) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      final result = await ApiService.deleteAppointment(token: token, id: id);

      if (result['ok'] == true) {
        setState(() {
          appointments.removeWhere((appt) => appt['_id'] == id);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment cancelled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to cancel appointment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _updateAppointment(String id, DateTime newDate, String newTime) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      // Format time if needed
      String formattedTime = newTime;
      if (newTime.contains('AM') || newTime.contains('PM')) {
        final timeParts = newTime.split(' ');
        final time = timeParts[0];
        final period = timeParts[1];

        if (period == 'PM' && time != '12:00') {
          final hour = int.parse(time.split(':')[0]);
          final minute = time.split(':')[1];
          formattedTime = '${hour + 12}:$minute';
        } else {
          formattedTime = time;
        }
      }

      final body = {
        "date": newDate.toIso8601String(),
        "time": formattedTime,
      };

      final result = await ApiService.updateAppointment(
          token: token,
          id: id,
          body: body
      );

      if (result['ok'] == true) {
        // Update local list
        setState(() {
          final index = appointments.indexWhere((a) => a['_id'] == id);
          if (index != -1) {
            appointments[index]['date'] = newDate.toIso8601String();
            appointments[index]['time'] = formattedTime;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment rescheduled successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Failed to update appointment'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<bool> _showCancelDialog(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Appointment?'),
        content: const Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showRescheduleDialog(BuildContext context, String id, Map<String, dynamic> appt) async {
    DateTime? newDate;
    String? newTime;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Reschedule Appointment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 📅 Select New Date
                  ListTile(
                    leading: const Icon(Icons.calendar_today, color: Color(0xFF7B5FCF)),
                    title: Text(
                        newDate == null
                            ? 'Select New Date'
                            : '${newDate!.day}-${newDate!.month}-${newDate!.year}'
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() {
                          newDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // ⏰ Select New Time
                  ListTile(
                    leading: const Icon(Icons.access_time, color: Color(0xFF7B5FCF)),
                    title: Text(newTime ?? 'Select New Time'),
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          newTime = picked.format(context);
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B5FCF),
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onPressed: () async {
                    if (newDate == null || newTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select both date and time')),
                      );
                      return;
                    }

                    Navigator.pop(context); // Close dialog
                    await _updateAppointment(id, newDate!, newTime!);
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/new_bg.png',
              fit: BoxFit.cover,
            ),
          ),



          // ✅ Actual content in SafeArea
          SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Color(0xFF4A5C8C), Color(0xFF7B5FCF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds),
                    child: const Text(
                      'My Appointment',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Tab Bar
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A5C8C),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SizedBox(
                    height: 44,
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFA78BFA), Color(0xFFC084FC)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white70,
                      labelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelPadding:
                      const EdgeInsets.symmetric(vertical: 8),
                      padding:
                      const EdgeInsets.symmetric(vertical: 2),
                      indicatorPadding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                      dividerColor: Colors.transparent,
                      tabs: const [
                        Tab(text: 'Past'),
                        Tab(text: 'Today'),
                        Tab(text: 'Upcoming'),
                      ],
                    ),
                  ),
                ),

                // Tab Content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPastTab(),
                      _buildTodayTab(),
                      _buildUpcomingTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }


  Widget _buildPastTab() {
    return const Center(
      child: Text(
        'No past appointments',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  Widget _buildTodayTab() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (appointments.isEmpty) {
      return const Center(
        child: Text(
          'No appointments found',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appt = appointments[index];
        return _buildAppointmentCard(
            icon: Icons.medical_services,
            title: appt['procedure'] ?? 'Unknown',
            name: appt['fullName'] ?? '',
            date: appt['date'] != null
                ? appt['date'].toString().substring(0, 10)
                : '',
            time: appt['time'] ?? '',
            status: appt['status'] ?? 'Pending',
            id: appt['_id'],
            appt: appt
        );
      },
    );
  }

  Widget _buildUpcomingTab() {
    return const Center(
      child: Text(
        'No upcoming appointments',
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  Widget _buildAppointmentCard({
    required IconData icon,
    required String title,
    required String name,
    required String date,
    required String time,
    required String status,
    required String id,
    required Map<String, dynamic> appt,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      decoration: BoxDecoration(
        color: const Color(0xffece9e9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ICON BOX
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF4F46E5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF000000),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$date   $time',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF000000),
                  ),
                ),
              ],
            ),
          ),

          // MENU + STATUS
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Glass blurry effect three dots - FIXED VERSION
              PopupMenuButton<String>(
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.05),
                  ),
                  child: const Icon(
                    Icons.more_horiz,
                    size: 20,
                    color: Color(0xFF4A5568),
                  ),
                ),
                offset: const Offset(-20, 40),
                color: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (value) async {
                  switch (value) {
                    case 'cancel':
                      final confirmed = await _showCancelDialog(context);
                      if (confirmed) _cancelAppointment(id);
                      break;
                    case 'reschedule':
                      _showRescheduleDialog(context, id, appt);
                      break;
                    case 'help':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Help option coming soon...')),
                      );
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    // Main container with glass effect
                    PopupMenuItem<String>(
                      value: '',
                      enabled: false,
                      height: 0,
                      padding: EdgeInsets.zero,
                      child: Container(
                        width: 220,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 15.0,
                              sigmaY: 15.0,
                              tileMode: TileMode.clamp,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 25,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Cancel Appointment
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context); // Close menu
                                        _showCancelDialog(context).then((confirmed) {
                                          if (confirmed) _cancelAppointment(id);
                                        });
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: Colors.red.shade600.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.cancel_outlined,
                                                color: Colors.red.shade600,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Cancel Appointment',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.red.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Divider
                                  Container(
                                    height: 0.5,
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    color: Colors.white.withOpacity(0.2),
                                  ),

                                  // Reschedule
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context); // Close menu
                                        _showRescheduleDialog(context, id, appt);
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade600.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.schedule_outlined,
                                                color: Colors.blue.shade600,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Reschedule',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue.shade600,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Divider
                                  Container(
                                    height: 0.5,
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    color: Colors.white.withOpacity(0.2),
                                  ),

                                  // Help
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context); // Close menu
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Help option coming soon...')),
                                        );
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade700.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.help_outline,
                                                color: Colors.grey.shade700,
                                                size: 16,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Help',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ];
                },
              ),

              const SizedBox(height: 12),

              // STATUS PILL
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8FAD9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Helper method to create glass menu item content
  Widget _buildGlassMenuItemContent({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {}, // Empty onTap - handled by PopupMenuItem
        splashColor: Colors.white.withOpacity(0.1),
        highlightColor: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.white.withOpacity(0.1),
                Colors.white.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: color,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildBottomNavigationBar() {
    return ClipRect(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.11,  // Use standard height with padding
            child: Stack(
              children: [
                // Background Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/navbar_bg.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback gradient if image fails to load
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2C4A7C), Color(0xFF1E3A5F)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Semi-transparent overlay for better icon visibility
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.4),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Navigation Bar
                BottomNavigationBar(
                  currentIndex: _currentBottomIndex,
                  onTap: (index) {
                    setState(() {
                      _currentBottomIndex = index;
                    });
                    switch (index) {
                      case 0:
                        Navigator.pushNamed(context, '/home');
                        break;
                      case 1:
                        break;
                      case 2:
                        break;
                      case 3:
                        Navigator.pushReplacementNamed(context, '/myreports');
                        break;
                      case 4:
                        Navigator.pushNamed(context, '/profile');
                        break;
                    }
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.transparent, // Make it transparent
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white.withOpacity(0.7),
                  selectedFontSize: 12,
                  unselectedFontSize: 12,
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  unselectedLabelStyle: const TextStyle(
                    shadows: [
                      Shadow(
                        color: Colors.black,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                  elevation: 0, // Remove default shadow
                  items: [
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _currentBottomIndex == 0
                              ? Colors.white.withOpacity(0.2)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: _currentBottomIndex == 0
                              ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                              : [],
                        ),
                        child: const Icon(Icons.home_outlined, size: 24),
                      ),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _currentBottomIndex == 1
                              ? Colors.white.withOpacity(0.2)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: _currentBottomIndex == 1
                              ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                              : [],
                        ),
                        child: const Icon(Icons.calendar_today_outlined, size: 24),
                      ),
                      label: 'Appointments',
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEC4899).withOpacity(0.6),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shopping_cart_outlined,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _currentBottomIndex == 3
                              ? Colors.white.withOpacity(0.2)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: _currentBottomIndex == 3
                              ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                              : [],
                        ),
                        child: const Icon(Icons.description_outlined, size: 24),
                      ),
                      label: 'My Reports',
                    ),
                    BottomNavigationBarItem(
                      icon: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _currentBottomIndex == 4
                              ? Colors.white.withOpacity(0.2)
                              : Colors.transparent,
                          shape: BoxShape.circle,
                          boxShadow: _currentBottomIndex == 4
                              ? [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.3),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                              : [],
                        ),
                        child: const Icon(Icons.person_outline, size: 24),
                      ),
                      label: 'Profile',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}