import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:xstar_app/my_appointment_page.dart';
import 'api_service.dart';
import 'auth_service.dart';

class BookAppointmentFlow extends StatefulWidget {
  const BookAppointmentFlow({super.key});

  @override
  State<BookAppointmentFlow> createState() => _BookAppointmentFlowState();
}

class _BookAppointmentFlowState extends State<BookAppointmentFlow> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  String? selectedCenter;
  String fullName = '';
  String mobileNumber = '';
  String emailAddress = '';
  String referringDoctor = '';
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();
  String? selectedTime;
  String? paymentMethod;

  // Add loading state
  bool _isBooking = false;
  bool _showSuccessDialog = false;

  final List<String> centers = [
    'Select your Star Center',
    'Star Center - Delhi',
    'Star Center - Mumbai',
    'Star Center - Bangalore',
    'Star Center - Hyderabad',
    'Star Center - Chennai',
    'Star Center - Kolkata',
  ];

  final List<String> timeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with today's date
    selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_isBooking) return;

    if (_currentStep < 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 1) {
      // Validate step 2 before showing payment
      if (selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a time slot'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      _showPaymentBottomSheet();
    }
  }

  void _previousPage() {
    if (_isBooking) return;

    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  List<String> _getMonthsList() {
    final List<String> months = [];
    final DateTime now = DateTime.now();

    for (int i = -2; i <= 2; i++) {
      final monthDate = DateTime(now.year, now.month + i, 1);
      months.add(_getMonthName(monthDate.month));
    }

    return months;
  }

  String _getMonthName(int month) {
    final months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[month - 1];
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];

    // Add days from previous month to fill the first week
    final weekday = firstDay.weekday;
    for (int i = weekday - 1; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }

    // Add days of current month
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    return days;
  }

  List<List<DateTime>> _getWeeksInMonth(DateTime month) {
    final days = _getDaysInMonth(month);
    final weeks = <List<DateTime>>[];
    List<DateTime> week = [];

    for (final day in days) {
      week.add(day);
      if (day.weekday == DateTime.sunday || day == days.last) {
        weeks.add(List.from(week));
        week.clear();
      }
    }

    return weeks;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isPastDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);
    return compareDate.isBefore(today);
  }

  // In your _BookAppointmentFlowState class, update the payment method section:

  void _showPaymentBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                'Payment Method',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 24),

              // Payment Options - UPDATED VALUES
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentOptionBottomSheet(
                      'Pay at Center',
                      Icons.business,
                      'Pay at Center', // EXACTLY as API expects
                      setModalState,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPaymentOptionBottomSheet(
                      'Pay Now',
                      Icons.credit_card,
                      'Pay Now', // EXACTLY as API expects
                      setModalState,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Offer Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.verified, color: Color(0xFF7B5FCF), size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Pay Now and Get 10% Instant Off.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Book Now Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isBooking
                      ? null
                      : () async {
                    Navigator.pop(context);
                    await _bookAppointment();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isBooking
                        ? Colors.grey
                        : const Color(0xFF7B5FCF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: _isBooking
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                      : const Text(
                    'BOOK NOW',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOptionBottomSheet(
      String title,
      IconData icon,
      String value,
      StateSetter setModalState,
      ) {
    final isSelected = paymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          paymentMethod = value;
        });
        setModalState(() {
          paymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [const Color(0xFF7B5FCF), const Color(0xFF9B8FCF)]
                : [const Color(0xFF5A4A8F), const Color(0xFF7B5FCF)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7B5FCF).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.asset(
                'assets/images/home_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFFF8FAFF),
                  );
                },
              ),
            ),

            // Content
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _previousPage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF003B85)),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 18,
                            color: Color(0xFF003B85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title and Progress
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Book Your ',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                                letterSpacing: 2,
                              ),
                            ),
                            TextSpan(
                              text: 'Appointment',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF7B5FCF),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: _buildProgressIndicator(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Pages
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                    ],
                  ),
                ),

                // Navigation Buttons
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      ElevatedButton(
                        onPressed: _isBooking ? null : _previousPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isBooking
                              ? Colors.grey
                              : const Color(0xFF9B8FCF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.arrow_back_ios, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Back',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Next Button
                      ElevatedButton(
                        onPressed: _isBooking ? null : _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isBooking
                              ? Colors.grey
                              : const Color(0xFF8B7FCF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Next',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_ios, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Loading Overlay
            if (_isBooking)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                ),
              ),

            // Success Dialog
            if (_showSuccessDialog)
              _buildSuccessDialog(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return SizedBox(
      height: 18,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Progress bar background
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Progress bar fill
          FractionallySizedBox(
            widthFactor: (_currentStep + 1) / 2,
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1F3A5F), Color(0xFF7B5FCF)],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          // Dots positioned at 0% and 100%
          Positioned(
            left: 0,
            child: _buildProgressDot(0),
          ),
          Positioned(
            right: 0,
            child: _buildProgressDot(1),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDot(int step) {
    final isActive = _currentStep >= step;
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1F3A5F) : const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  // STEP 1: Procedure and Patient Information
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Procedure Information',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Procedure : CT Scan - Abdomen',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Select Center
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Center',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedCenter,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    hint: const Text(
                      'Select your Star Center',
                      style: TextStyle(color: Color(0xFF111112)),
                    ),
                    items: centers.map((String center) {
                      return DropdownMenuItem<String>(
                        value: center,
                        child: Text(center),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedCenter = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Patient Information
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Patient Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),

                _buildTextField('Full Name', (value) => fullName = value),
                const SizedBox(height: 12),

                // Mobile Number with country code
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: const [
                            Text('🇮🇳', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down, size: 20, color: Color(0xFF6B7280)),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 24, color: const Color(0xFFE5E7EB)),
                      Expanded(
                        child: TextField(
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            hintText: 'Mobile Number',
                            hintStyle: TextStyle(color: Color(0xFF111112)),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          onChanged: (value) => mobileNumber = value,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                _buildTextField('Email Address ( Optional )', (value) => emailAddress = value),
                const SizedBox(height: 12),

                _buildTextField('Reffering Doctor', (value) => referringDoctor = value),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // STEP 2: Date and Time Selection
  Widget _buildStep2() {
    final months = _getMonthsList();
    final currentMonthIndex = months.indexOf(_getMonthName(DateTime.now().month));
    final weeks = _getWeeksInMonth(currentMonth);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Selector
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
                    });
                  },
                  icon: const Icon(Icons.chevron_left, color: Color(0xFF7B5FCF)),
                ),
                const SizedBox(width: 8),
                ...List.generate(months.length, (index) {
                  final isCurrent = _getMonthName(currentMonth.month) == months[index];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          final now = DateTime.now();
                          final monthDiff = index - currentMonthIndex;
                          currentMonth = DateTime(now.year, now.month + monthDiff, 1);
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isCurrent ? const Color(0xFF7B5FCF).withOpacity(0.1) : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          months[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            color: isCurrent ? const Color(0xFF1F2937) : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
                    });
                  },
                  icon: const Icon(Icons.chevron_right, color: Color(0xFF7B5FCF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Calendar Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Choose Date Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_getMonthName(currentMonth.month)} ${currentMonth.year}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003373),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              currentMonth = DateTime(currentMonth.year, currentMonth.month - 1, 1);
                            });
                          },
                          icon: const Icon(Icons.chevron_left, size: 20, color: Color(0xFF7B5FCF)),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
                            });
                          },
                          icon: const Icon(Icons.chevron_right, size: 20, color: Color(0xFF7B5FCF)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Calendar
                _buildCalendar(weeks),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Time Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Choose Time Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Choose Time',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003373),
                      ),
                    ),
                    Text(
                      selectedDate.day == DateTime.now().day ?
                      'Today' :
                      '${selectedDate.day} ${_getMonthName(selectedDate.month)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7B5FCF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Time Slots
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: timeSlots.map((time) => _buildTimeSlot(time)).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, Function(String) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF111112)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildCalendar(List<List<DateTime>> weeks) {
    return Column(
      children: [
        // Week days
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
              .map((day) => SizedBox(
            width: 40,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ))
              .toList(),
        ),
        const SizedBox(height: 16),
        // Dates
        ...weeks.map((week) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: week.map((date) {
              final isSameMonth = date.month == currentMonth.month;
              final isSelected = _isSameDay(date, selectedDate);
              final isToday = _isToday(date);
              final isPast = _isPastDate(date);

              return GestureDetector(
                onTap: isSameMonth && !isPast ? () {
                  setState(() {
                    selectedDate = date;
                  });
                } : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF7B5FCF) :
                    isToday ? const Color(0xFF7B5FCF).withOpacity(0.1) :
                    Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isToday && !isSelected ? const Color(0xFF7B5FCF) : Colors.transparent,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white :
                        isSameMonth ?
                        (isPast ? const Color(0xFFD1D5DB) : const Color(0xFF1F2937)) :
                        const Color(0xFFD1D5DB),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildTimeSlot(String time) {
    final isSelected = selectedTime == time;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTime = time;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF7B5FCF) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          time,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? const Color(0xFF7B5FCF) : const Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessDialog() {
    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 50,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              const Text(
                'Appointment Confirmed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 16),

              // Message
              const Text(
                'Your appointment has been successfully booked.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 8),

              const Text(
                'You will receive a confirmation SMS shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _showSuccessDialog = false;
                        });
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFF7B5FCF)),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Color(0xFF7B5FCF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showSuccessDialog = false;
                        });
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyAppointmentPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B5FCF),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        'View Appointments',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _bookAppointment() async {
    // Validate all required fields
    if (fullName.isEmpty ||
        mobileNumber.isEmpty ||
        selectedCenter == null ||
        selectedCenter == 'Select your Star Center' ||
        selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      // Get user token
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        setState(() {
          _isBooking = false;
        });
        _showLoginPrompt();
        return;
      }

      // Format time from "09:00 AM" to "09:00" (24-hour format if needed)
      String formattedTime = selectedTime!;

      // Convert "09:00 AM" to "09:00" and "02:00 PM" to "14:00"
      if (selectedTime!.contains('AM') || selectedTime!.contains('PM')) {
        final timeParts = selectedTime!.split(' ');
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

      // Prepare appointment data EXACTLY as API expects
      final appointmentData = {
        'procedure': 'CT Scan - Abdomen', // Fixed as per UI
        'center': selectedCenter!.replaceAll('Select your Star Center', '').trim(),
        'fullName': fullName,
        'mobile': mobileNumber,
        'email': emailAddress.isNotEmpty ? emailAddress : '',
        'doctor': referringDoctor.isNotEmpty ? referringDoctor : '',
        'date': selectedDate.toIso8601String(),
        'time': formattedTime,
        'paymentMethod': paymentMethod ?? 'Pay at Center', // Default if not selected
      };

      print('📤 Sending appointment data to API:');
      print('📤 Token: ${token.substring(0, 20)}...');
      print('📤 Data: $appointmentData');

      // Call API to create appointment
      final response = await ApiService.createAppointment(
        token: token,
        body: appointmentData,
      );

      setState(() {
        _isBooking = false;
      });

      print('📥 API Response: $response');

      if (response['ok'] == true) {
        // Show success
        setState(() {
          _showSuccessDialog = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Appointment Booked Successfully!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['error'] ?? 'Booking failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isBooking = false;
      });

      print('❌ Booking error details:');
      print('❌ Error: $e');

      // Provide user-friendly error message
      String errorMessage = 'Booking failed. Please try again.';

      if (e.toString().contains('paymentMethod')) {
        errorMessage = 'Please select a valid payment method.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Session expired. Please login again.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Login Required'),
        content: const Text('You need to login to book an appointment.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }
}