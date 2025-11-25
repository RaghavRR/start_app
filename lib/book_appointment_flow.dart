import 'package:flutter/material.dart';

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
  DateTime? selectedDate;
  String? selectedTime;
  String? paymentMethod;

  final List<String> centers = [
    'Select your Star Center',
    'Star Center - Delhi',
    'Star Center - Mumbai',
    'Star Center - Bangalore',
  ];

  final List<String> timeSlots = [
    '02:00 PM',
    '04:00 PM',
    '07:00 PM',
    '08:00 PM',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
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
      // Show payment bottom sheet instead of going to step 3
      _showPaymentBottomSheet();
    }
  }

  void _previousPage() {
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

              // Payment Options
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentOptionBottomSheet(
                      'Pay at Center',
                      Icons.business,
                      'center',
                      setModalState,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildPaymentOptionBottomSheet(
                      'Pay Now',
                      Icons.credit_card,
                      'now',
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
                  onPressed: () {
                    Navigator.pop(context);
                    _bookAppointment();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B5FCF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
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
                        onPressed: _previousPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9B8FCF),
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
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B7FCF),
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
                  onPressed: () {},
                  icon: const Icon(Icons.chevron_left, color: Color(0xFF7B5FCF)),
                ),
                const Text(
                  'SEP',
                  style: TextStyle(fontSize: 18, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(width: 16),
                const Text(
                  'OCT',
                  style: TextStyle(fontSize: 18, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(width: 16),
                const Text(
                  'NOV',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                ),
                const SizedBox(width: 16),
                const Text(
                  'DEC',
                  style: TextStyle(fontSize: 18, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(width: 16),
                const Text(
                  'JAN',
                  style: TextStyle(fontSize: 18, color: Color(0xFF9CA3AF)),
                ),
                IconButton(
                  onPressed: () {},
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
                    const Text(
                      'Choose Date',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF003373),
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.chevron_left, size: 20, color: Color(0xFF7B5FCF)),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right, size: 20, color: Color(0xFF7B5FCF)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Calendar
                _buildCalendar(),
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
                    Row(
                      children: const [
                        Icon(Icons.chevron_left, size: 20, color: Color(0xFF7B5FCF)),
                        SizedBox(width: 8),
                        Icon(Icons.chevron_right, size: 20, color: Color(0xFF7B5FCF)),
                      ],
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

  Widget _buildCalendar() {
    return Column(
      children: [
        // Week days
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map((day) => SizedBox(
            width: 40,
            child: Text(
              day,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ))
              .toList(),
        ),
        const SizedBox(height: 16),
        // Dates
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [27, 28, 29, 30].map((date) => _buildDateCircle(date, false)).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [1, 2, 3, 4, 5, 6, 7].map((date) => _buildDateCircle(date, date == 29)).toList(),
        ),
      ],
    );
  }

  Widget _buildDateCircle(int date, bool isSelected) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF7B5FCF) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? const Color(0xFF7B5FCF) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Center(
        child: Text(
          date.toString(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
      ),
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

  void _bookAppointment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Appointment Booked Successfully!')),
    );
    Navigator.pop(context);
  }
}