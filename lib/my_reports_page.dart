import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  bool isLoading = true;
  List reports = [];
  int _currentBottomIndex = 3; // Reports tab selected

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  Future<void> fetchReports() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("auth_token");

      if (token == null) {
        print("NO TOKEN FOUND — user not logged in");
        return;
      }

      const String apiUrl = "https://start-app-u8sb.onrender.com/reports";

      final res = await http.get(
        Uri.parse(apiUrl),
        headers: {"Authorization": "Bearer $token"},
      );

      print("📥 STATUS: ${res.statusCode}");
      print("📥 BODY: ${res.body}");

      final data = jsonDecode(res.body);

      setState(() {
        reports = data["reports"] ?? [];
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  String formatDate(String? isoDate) {
    if (isoDate == null) return "";
    final date = DateTime.parse(isoDate);
    return "${date.day}${_getDaySuffix(date.day)} ${_getMonthName(date.month)} ${date.year} ${_formatTime(date)}";
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  String _getMonthName(int month) {
    const months = ['', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6E2F7), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFF003373), Color(0xFFCB6CE6)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds),
                    child: const Text(
                      'My Reports',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                ),
              ),

              // Content
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : reports.isEmpty
                    ? const Center(
                  child: Text(
                    "No reports found.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final r = reports[index];
                    return _buildReportCard(context, r);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildReportCard(BuildContext context, Map report) {
    final caseNumber = report["caseNumber"] ?? "CASE";
    final status = report["status"] ?? "pending";
    final createdDate = formatDate(report["createdAt"]);
    final procedure = report["procedure"] ?? "GENEXPERT ULTRA ( LFT, KFT )....";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
          color: Color(0xFFd9d9d9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with name and 3-dot menu
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Abhinav Kumar | 50 years | Male",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                Icon(
                  Icons.more_vert,
                  color: Colors.grey[600],
                  size: 24,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Lab Number
            Text(
              "Lab Number: $caseNumber",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 4),

            // Date
            Text(
              createdDate,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 4),

            // Procedure
            Text(
              procedure,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),

            // Buttons row
            Row(
              children: [
                // Download Report Button
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      final pdfUrl = report["reportFile"]?["url"];
                      if (pdfUrl != null && pdfUrl.isNotEmpty) {
                        _openPdf(context, pdfUrl);
                      }
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.download,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    label: const Text(
                      "Download Report",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.transparent, // optional
                      foregroundColor: const Color(0xFF7C3AED),
                    ),
                  ),
                ),


                const SizedBox(width: 12),

                // View Details Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReportDetailPage(report: report),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A5C8C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0, // reduced horizontal padding
                        vertical: 10,   // reduced vertical padding
                      ),
                      elevation: 0,
                      minimumSize: const Size(0, 0), // allows button to shrink
                    ),
                    child: const Text(
                      "View Details",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )

              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openPdf(BuildContext context, String pdfUrl) async {
    try {
      final uri = Uri.parse(pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open PDF'),
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
                        Navigator.pushNamed(context, '/appointments');
                        break;
                      case 2:
                        break;
                      case 3:
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

  void _handleNavigation(int index, BuildContext context) {
    switch (index) {
      case 0: // Home
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1: // Appointments
        Navigator.pushReplacementNamed(context, '/appointments');
        break;
      case 2: // Cart
      // Navigator.pushReplacementNamed(context, '/cart');
        break;
      case 3: // My Reports (current page)
      // Do nothing, already on this page
        break;
      case 4: // Profile
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }
}

class ReportDetailPage extends StatelessWidget {
  final Map report;

  const ReportDetailPage({super.key, required this.report});

  String formatDate(String? isoDate) {
    if (isoDate == null) return "";
    final date = DateTime.parse(isoDate);
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final pdfUrl = report["reportFile"]?["url"];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A5C8C),
        title: Text("Report: ${report['caseNumber']}"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildSection("Procedure", report["procedure"]),
            buildSection("Indication", report["indication"]),
            buildSection("Technique", report["technique"]),
            buildSection("Clinical History", report["clinicalHistory"]),
            buildSection("Findings", report["findings"]),
            buildSection("Impression", report["impression"]),
            buildSection("Conclusion", report["conclusion"]),
            buildSection("Notes", report["notes"]),
            buildSection("Created At", formatDate(report["createdAt"])),

            const SizedBox(height: 30),

            if (pdfUrl != null && pdfUrl.isNotEmpty)
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Open PDF Report"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5C8C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      final uri = Uri.parse(pdfUrl);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Could not open PDF'),
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
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildSection(String title, dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A5C8C),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              value.toString(),
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}