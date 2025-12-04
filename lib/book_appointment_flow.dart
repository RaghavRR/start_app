import 'package:flutter/material.dart';
import './api_service.dart';
import 'auth_service.dart';

class BookAppointmentFlow extends StatefulWidget {
  const BookAppointmentFlow({super.key});

  @override
  State<BookAppointmentFlow> createState() => _BookAppointmentFlowState();
}

class _BookAppointmentFlowState extends State<BookAppointmentFlow> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Form data
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
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _previousPage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: Color(0xFF6B7280),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Book Your ',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        TextSpan(
                          text: 'Appointment',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7B5FCF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildProgressIndicator(),
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
                  _buildStep3(),
                ],
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _previousPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B8FCF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.arrow_back, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Back',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _currentStep == 2 ? _bookAppointment : _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B5FCF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == 2 ? 'Book Now' : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Stack(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFE5E7EB),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        FractionallySizedBox(
          widthFactor: (_currentStep + 1) / 3,
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
        Positioned(
          left: 0,
          top: -3,
          child: _buildProgressDot(0),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: -3,
          child: Center(child: _buildProgressDot(1)),
        ),
        Positioned(
          right: 0,
          top: -3,
          child: _buildProgressDot(2),
        ),
      ],
    );
  }

  Widget _buildProgressDot(int step) {
    final isActive = _currentStep >= step;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1F3A5F) : const Color(0xFFE5E7EB),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
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
          const Text(
            'Procedure Information',
            style: TextStyle(
              fontSize: 18,
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
          const SizedBox(height: 24),

          // Select Center
          const Text(
            'Select Center',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
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
              initialValue: selectedCenter,
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
          const SizedBox(height: 24),

          // Patient Information
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_left, color: Color(0xFF7B5FCF)),
              ),
              const Text(
                'SEP',
                style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(width: 16),
              const Text(
                'OCT',
                style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(width: 16),
              const Text(
                'NOV',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
              ),
              const SizedBox(width: 16),
              const Text(
                'DEC',
                style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(width: 16),
              const Text(
                'JAN',
                style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right, color: Color(0xFF7B5FCF)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Choose Date Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose Date',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
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
          const SizedBox(height: 24),

          // Choose Time Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose Time',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // STEP 3: Payment Method
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Selector (same as step 2)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_left, color: Color(0xFF7B5FCF)),
              ),
              const Text('SEP', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
              const SizedBox(width: 16),
              const Text('OCT', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
              const SizedBox(width: 16),
              const Text('NOV', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              const SizedBox(width: 16),
              const Text('DEC', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
              const SizedBox(width: 16),
              const Text('JAN', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.chevron_right, color: Color(0xFF7B5FCF)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Choose Date Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Choose Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
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

          // Mini Calendar
          _buildMiniCalendar(),
          const SizedBox(height: 24),

          // Bottom Sheet - Payment Method
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Payment Options
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildPaymentOption(
                          'Pay at Center',
                          Icons.business,
                          'center',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildPaymentOption(
                          'Pay Now',
                          Icons.credit_card,
                          'now',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Offer Banner
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF7B5FCF)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.verified, color: Color(0xFF7B5FCF), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Pay Now and Get 10% Instant Off.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
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

DateTime _focusedDate = DateTime.now();
DateTime? _selectedDate;

Widget _buildCalendar() {

  // Get first day and number of days in current month
  final firstDayOfMonth = DateTime(_focusedDate.year, _focusedDate.month, 1);
  final daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
  final startWeekday = firstDayOfMonth.weekday; // 1 = Mon ... 7 = Sun

  List<Widget> dayWidgets = [];

  // Add blanks for offset days before month starts
  for (int i = 1; i < startWeekday; i++) {
    dayWidgets.add(const SizedBox(width: 42, height: 42));
  }

  // Add actual dates
  for (int day = 1; day <= daysInMonth; day++) {
    final currentDate = DateTime(_focusedDate.year, _focusedDate.month, day);
    final isSelected = _selectedDate != null &&
        _selectedDate!.year == currentDate.year &&
        _selectedDate!.month == currentDate.month &&
        _selectedDate!.day == currentDate.day;

    dayWidgets.add(
      GestureDetector(
        onTap: () {
          setState(() {
            _selectedDate = currentDate;
          });
        },
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF7B5FCF), Color(0xFF9B8FCF)],
                  )
                : null,
            border: Border.all(
              color: isSelected ? const Color(0xFF7B5FCF) : const Color(0xFFE5E7EB),
            ),
            color: isSelected ? null : Colors.white,
          ),
          child: Text(
            '$day',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
        ),
      ),
    );
  }

  return Column(
    children: [
      // 🔹 Month-Year header with navigation
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: Color(0xFF7B5FCF)),
              onPressed: () {
                setState(() {
                  _focusedDate = DateTime(_focusedDate.year, _focusedDate.month - 1);
                });
              },
            ),
            GestureDetector(
              onTap: _showMonthYearPicker, // 👇 Step 2 handles this
              child: Text(
                '${_monthName(_focusedDate.month)} ${_focusedDate.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: Color(0xFF7B5FCF)),
              onPressed: () {
                setState(() {
                  _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + 1);
                });
              },
            ),
          ],
        ),
      ),

      // 🔹 Weekday labels
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
            .map(
              (d) => SizedBox(
                width: 40,
                child: Text(
                  d,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
            .toList(),
      ),
      const SizedBox(height: 8),

      // 🔹 Dates grid
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: dayWidgets,
        ),
      ),
    ],
  );
}

  
  void _showMonthYearPicker() async {
  final picked = await showDatePicker(
    context: context,
    initialDate: _focusedDate,
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
    helpText: "Select Month and Year",
    initialDatePickerMode: DatePickerMode.year,
  );
  if (picked != null) {
    setState(() {
      _focusedDate = DateTime(picked.year, picked.month);
    });
  }
}



  Widget _buildMiniCalendar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
          .asMap()
          .entries
          .map((entry) {
        final dates = [27, 28, 29, 30, 1, 2, 3];
        return _buildDateCircle(dates[entry.key], dates[entry.key] == 29);
      })
          .toList(),
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
          borderRadius: BorderRadius.circular(10),
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

  Widget _buildPaymentOption(String title, IconData icon, String value) {
    final isSelected = paymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          paymentMethod = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [const Color(0xFF7B5FCF), const Color(0xFF9B8FCF)]
                : [const Color(0xFFE8E8F5), const Color(0xFFF0E8F5)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF7B5FCF) : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.white : const Color(0xFF7B5FCF),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Future<void> _bookAppointment() async {
    try {
      // Retrieve token (assuming you saved it after login)
      final token = await AuthService.getToken();


      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        return;
      }

      final body = {
        "procedure": "CT Scan - Abdomen",
        "center": selectedCenter ?? "Star Center - Delhi",
        "fullName": fullName,
        "mobile": mobileNumber,
        "email": emailAddress,
        "doctor": referringDoctor,
        "date": _selectedDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
        "time": selectedTime ?? "05:00 PM",
        "paymentMethod": paymentMethod == 'now' ? "Pay Now" : "Pay at Center",
      };

      final result = await ApiService.createAppointment(token: token, body: body);

      if (result['ok'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment booked successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${result['error'] ?? 'Unknown error'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _monthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June",
      "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }

}