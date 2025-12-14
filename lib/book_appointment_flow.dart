import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:xstar_app/home_page.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'package:lottie/lottie.dart';

class BookAppointmentFlow extends StatefulWidget {
  const BookAppointmentFlow({super.key});

  @override
  State<BookAppointmentFlow> createState() => _BookAppointmentFlowState();
}

class _BookAppointmentFlowState extends State<BookAppointmentFlow> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  // Step 1 - Procedure Selection
  String? selectedScanType;
  String? selectedProcedureDescription;
  String? selectedCenter;

  // Step 2 - Patient Information
  String fullName = '';
  String mobileNumber = '';
  String emailAddress = '';
  String referringDoctor = '';

  // Step 3 - Date & Time
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();
  String? selectedTime;

  bool _isBooking = false;
  String? paymentMethod;
  bool _showSuccessDialog = false;
  bool _showCheckoutSheet = false;
  String? _bottomSheetPaymentMethod;

  // For expanded sections in checkout
  bool _isBookingSummaryExpanded = false;
  bool _isPriceDetailsExpanded = false;

  final List<String> scanTypes = [
    'Select your Scan...',
    'CT Scan',
    'MRI Scan',
    'X-Ray',
    'Ultrasound',
    'PET Scan',
  ];

  final List<String> procedureDescriptions = [
    'Select your procedure Description...',
    'Abdomen',
    'Brain',
    'Chest',
    'Spine',
    'Full Body',
  ];

  final List<String> centers = [
    'Select your Star Center',
    'STAR Radiology - Noida',
    'STAR Radiology - Delhi',
    'STAR Radiology - Mumbai',
    'STAR Radiology - Bangalore',
  ];

  final List<String> timeSlots = [
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_isBooking) return;

    // Validate current step
    if (_currentStep == 0) {
      if (selectedScanType == null ||
          selectedScanType == 'Select your Scan...') {
        _showError('Please select a scan type');
        return;
      }
      if (selectedProcedureDescription == null ||
          selectedProcedureDescription ==
              'Select your procedure Description...') {
        _showError('Please select a procedure description');
        return;
      }
      if (selectedCenter == null ||
          selectedCenter == 'Select your Star Center') {
        _showError('Please select a center');
        return;
      }
    } else if (_currentStep == 1) {
      if (fullName.isEmpty || mobileNumber.isEmpty) {
        _showError('Please fill all required fields');
        return;
      }
    } else if (_currentStep == 2) {
      if (selectedTime == null) {
        _showError('Please select a time slot');
        return;
      }
      // When on step 3 and clicking Next, show checkout bottom sheet instead
      _showCheckoutBottomSheet();
      return; // Don't increment step
    }

    if (_currentStep < 3) {
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

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
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
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[month - 1];
  }

  List<DateTime> _getDaysInMonth(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);
    final days = <DateTime>[];

    final weekday = firstDay.weekday % 7;
    for (int i = weekday; i > 0; i--) {
      days.add(firstDay.subtract(Duration(days: i)));
    }

    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    return days;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  bool _isPastDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(date.year, date.month, date.day);
    return compareDate.isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ✅ FULL SCREEN BACKGROUND (no SafeArea)
          Positioned.fill(
            child: Image.asset(
              'assets/images/new_bg.png',
              fit: BoxFit.cover,
            ),
          ),

          // ✅ App content inside SafeArea
          SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(),

                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildStep1ProcedureSelection(),
                          _buildStep2PatientInfo(),
                          _buildStep3DateTime(),
                        ],
                      ),
                    ),

                    _buildNavigationButtons(),
                  ],
                ),

                if (_isBooking)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation(Color(0xFF6B5FCF)),
                      ),
                    ),
                  ),

                if (_showSuccessDialog) _buildSuccessDialog(),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Back button and title
          Row(
            children: [
              GestureDetector(
                onTap: _previousPage,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF1F3A5F)),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    size: 15,
                    color: Color(0xFF1F3A5F),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Title
          RichText(
            textAlign: TextAlign.center,
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'Book Your ',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F3A5F),
                  ),
                ),
                TextSpan(
                  text: 'Appointment',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8B7FCF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Progress Indicator
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: SizedBox(
        height: 20,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Background line
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF1F3A5F),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Progress line
            FractionallySizedBox(
              widthFactor: (_currentStep + 1) / 3,
              child: Container(
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCFCFC),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(4, (index) => _buildProgressDot(index)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressDot(int step) {
    final isActive = _currentStep >= step;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF1F3A5F) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? const Color(0xFF1F3A5F) : const Color(0xFFE5E7EB),
          width: 2,
        ),
      ),
    );
  }

  // STEP 1: Procedure Selection (Image 3)
  Widget _buildStep1ProcedureSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20,0,20,20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Procedure Information
          Container(
            margin: EdgeInsets.only(left: 20),
            child: Text(
              'Procedure Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Select Scan Type
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF000000), Color(0xFF000000)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildDropdown(
                value: selectedScanType,
                items: scanTypes,
                hint: 'Select your Scan...',
                onChanged: (value) {
                  setState(() {
                    selectedScanType = value;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Select Procedure Description
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF000000), Color(0xFF000000)],
              ),
            ),
            padding: const EdgeInsets.all(1),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: _buildDropdown(
                value: selectedProcedureDescription,
                items: procedureDescriptions,
                hint: 'Select your procedure Description...',
                onChanged: (value) {
                  setState(() {
                    selectedProcedureDescription = value;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Preparation Note
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: RichText(
              text: const TextSpan(
                children: [
                  TextSpan(
                    text: 'Preparation : ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  TextSpan(
                    text: 'Fasting Not Required',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Select Center
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            child: const Text(
              'Select Center',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
            padding: const EdgeInsets.all(1),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF000000), Color(0xFF000000)],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: _buildDropdown(
                value: selectedCenter,
                items: centers,
                hint: 'Select your Star Center',
                onChanged: (value) {
                  setState(() {
                    selectedCenter = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 2: Patient Information (Image 1)
  Widget _buildStep2PatientInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20,0,20,20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Procedure Information Display
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Procedure Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Procedure : ${selectedScanType ?? 'CT Scan'} - ${selectedProcedureDescription ?? 'Abdomen'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  'Center : ${selectedCenter ?? 'STAR Radiology - Noida'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Patient Information
          Padding(
            padding: const EdgeInsets.fromLTRB(16,0,16,0),
            child: const Text(
              'Patient Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1F2937),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 16),
            child: _buildTextField(
              hint: 'Full Name',
              onChanged: (value) => fullName = value,
            ),
          ),

          const SizedBox(height: 12),

          // Mobile Number with country flag
          Padding(
          padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(
                colors: [Color(0xFF000000), Color(0xFF000000)],
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: const [
                        Text('🇮🇳', style: TextStyle(fontSize: 20)),
                        SizedBox(width: 4),
                        Icon(
                          Icons.keyboard_arrow_down,
                          size: 20,
                          color: Color(0xFF6B7280),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 24, color: Color(0xFFE5E7EB)),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Mobile Number',
                        hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                      onChanged: (value) => mobileNumber = value,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),

          const SizedBox(height: 12),

    Padding(
    padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 16),
         child:  _buildTextField(
            hint: 'Email Address ( Optional )',
            onChanged: (value) => emailAddress = value,
          ),
    ),
          const SizedBox(height: 12),
    Padding(
    padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 16),
    child:_buildTextField(
            hint: 'Reffering Doctor',
            onChanged: (value) => referringDoctor = value,
          ),
    ),
        ],
      ),
    );
  }

  // STEP 3: Date & Time Selection (Image 2)
  Widget _buildStep3DateTime() {
    final months = _getMonthsList();
    final days = _getDaysInMonth(currentMonth);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month Selector
          Container(
            padding: const EdgeInsets.symmetric(vertical: 0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentMonth = DateTime(
                        currentMonth.year,
                        currentMonth.month - 1,
                        1,
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_left,
                    color: Color(0xFF8B7FCF),
                  ),
                ),
                ...List.generate(months.length, (index) {
                  final isCurrent =
                      _getMonthName(currentMonth.month) == months[index];
                  return Expanded(
                    child: Text(
                      months[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCurrent
                            ? const Color(0xFF1F2937)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  );
                }),
                IconButton(
                  onPressed: () {
                    setState(() {
                      currentMonth = DateTime(
                        currentMonth.year,
                        currentMonth.month + 1,
                        1,
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF8B7FCF),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Choose Date
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              currentMonth = DateTime(
                                currentMonth.year,
                                currentMonth.month - 1,
                                1,
                              );
                            });
                          },
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Color(0xFF8B7FCF),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              currentMonth = DateTime(
                                currentMonth.year,
                                currentMonth.month + 1,
                                1,
                              );
                            });
                          },
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF8B7FCF),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Calendar Grid
                _buildCalendarGrid(days),
              ],
            ),
          ),

          // Choose Time
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {},
                          icon: const Icon(
                            Icons.chevron_left,
                            color: Color(0xFF8B7FCF),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {},
                          icon: const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF8B7FCF),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Time Slots Grid (2 columns)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  childAspectRatio: 2.5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: timeSlots
                      .map((time) => _buildTimeSlot(time))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        hint: Text(hint, style: const TextStyle(color: Color(0xFF9CA3AF))),
        items: items.map((String item) {
          return DropdownMenuItem<String>(value: item, child: Text(item));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required Function(String) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF000000), Color(0xFF000000)],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCalendarGrid(List<DateTime> days) {
    return Column(
      children: [
        // Week day headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
              .map(
                (day) => SizedBox(
                  width: 40,
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 12),

        // Calendar dates
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final date = days[index];
            final isSameMonth = date.month == currentMonth.month;
            final isSelected = _isSameDay(date, selectedDate);
            final isPast = _isPastDate(date);

            return GestureDetector(
              onTap: isSameMonth && !isPast
                  ? () {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF8B7FCF)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF8B7FCF)
                        : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Text(
                    date.day.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : isSameMonth
                          ? (isPast
                                ? const Color(0xFFD1D5DB)
                                : const Color(0xFF1F2937))
                          : const Color(0xFFD1D5DB),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF8B7FCF), Color(0xFF6C63FF)],
                )
              : null,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          margin: EdgeInsets.all(isSelected ? 2 : 1),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(23),
            border: isSelected
                ? null
                : Border.all(color: const Color(0xFF003373), width: 1),
          ),
          child: Center(
            child: Text(
              time,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF8B7FCF)
                    : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Container(
            decoration: BoxDecoration(
              gradient: _isBooking
                  ? null // disabled → no gradient
                  : const LinearGradient(
                      colors: [Color(0xFF003373), Color(0xFFCB6CE6)],
                    ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ElevatedButton(
              onPressed: _isBooking ? null : _previousPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                // important
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),

          // Next Button (or Book Now on last step)
          if (_currentStep < 2)
            Container(
              decoration: BoxDecoration(
                gradient: _isBooking
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF003373), Color(0xFFCB6CE6)],
                      ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ElevatedButton(
                onPressed: _isBooking ? null : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  // important
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
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
            )
          else if (_currentStep == 2)
            Container(
              decoration: BoxDecoration(
                gradient: _isBooking
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF003373), Color(0xFFCB6CE6)],
                      ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ElevatedButton(
                onPressed: _isBooking ? null : _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  // important
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            )
          else
            const SizedBox(width: 100),
        ],
      ),
    );
  }

  void _showCheckoutBottomSheet() {
    _bottomSheetPaymentMethod = null;
    _isBookingSummaryExpanded = false;
    _isPriceDetailsExpanded = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Header with drag handle
                  Container(
                    padding: const EdgeInsets.only(top: 12, bottom: 12),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD1D5DB),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),

                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Center(
                          child: Text(
                            'Check Out Summary',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF002c5c),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFF6B7280),
                              size: 24,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Booking Summary
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            // Reduced vertical padding
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF000000),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  // Fixed height header
                                  height: 30,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Booking Summary',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isBookingSummaryExpanded =
                                                !_isBookingSummaryExpanded;
                                          });
                                        },
                                        icon: Icon(
                                          _isBookingSummaryExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: const Color(0xFF6B7280),
                                          size: 24,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 40,
                                          minHeight: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isBookingSummaryExpanded)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 12),
                                      // Appointment Details
                                      _buildDetailRow(
                                        title: 'Appointment Date',
                                        value:
                                            '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                      ),
                                      const SizedBox(height: 6),
                                      _buildDetailRow(
                                        title: 'Appointment Time',
                                        value: selectedTime ?? 'Not selected',
                                      ),
                                      const SizedBox(height: 6),
                                      _buildDetailRow(
                                        title: 'Procedure',
                                        value:
                                            '${selectedScanType ?? 'CT Scan'} - ${selectedProcedureDescription ?? 'Abdomen'}',
                                      ),
                                      const SizedBox(height: 6),
                                      _buildDetailRow(
                                        title: 'Center',
                                        value: selectedCenter ?? 'Not selected',
                                      ),
                                      const SizedBox(height: 6),
                                      _buildDetailRow(
                                        title: 'Patient Name',
                                        value: fullName.isNotEmpty
                                            ? fullName
                                            : 'Not provided',
                                      ),
                                      const SizedBox(height: 6),
                                      _buildDetailRow(
                                        title: 'Mobile Number',
                                        value: mobileNumber.isNotEmpty
                                            ? mobileNumber
                                            : 'Not provided',
                                      ),
                                      const SizedBox(height: 6),
                                      if (emailAddress.isNotEmpty)
                                        _buildDetailRow(
                                          title: 'Email',
                                          value: emailAddress,
                                        ),
                                      if (emailAddress.isNotEmpty)
                                        const SizedBox(height: 6),
                                      if (referringDoctor.isNotEmpty)
                                        _buildDetailRow(
                                          title: 'Referring Doctor',
                                          value: referringDoctor,
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Unlock Coupons
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF000000),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF8B7FCF,
                                    ).withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.local_offer,
                                    color: Color(0xFF8B7FCF),
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Unlock Coupons & Offers',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'View all available coupons',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF000000),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Handle Sample Note
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: const [
                                Icon(
                                  Icons.verified_user,
                                  color: Color(0xFF0EA5E9),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(
                                        'Handle Sample with - ',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF4C4B4B),
                                        ),
                                      ),
                                      Text(
                                        'Family like care',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF000000),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Price Details
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            // Reduced vertical padding
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF000000),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  // Wrap in SizedBox with min height
                                  height: 30, // Fixed height for the header row
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Price Details',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isPriceDetailsExpanded =
                                                !_isPriceDetailsExpanded;
                                          });
                                        },
                                        icon: Icon(
                                          _isPriceDetailsExpanded
                                              ? Icons.keyboard_arrow_up
                                              : Icons.keyboard_arrow_down,
                                          color: const Color(0xFF6B7280),
                                          size: 24, // Adjust icon size
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 40,
                                          minHeight: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isPriceDetailsExpanded)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const SizedBox(height: 12),
                                      // Reduced spacing
                                      _buildPriceDetailRow(
                                        title: 'Procedure Fee',
                                        amount: '₹ 499.00',
                                      ),
                                      const SizedBox(height: 6),
                                      // Reduced spacing
                                      _buildPriceDetailRow(
                                        title: 'Consultation Fee',
                                        amount: '₹ 50.00',
                                      ),
                                      const SizedBox(height: 6),
                                      // Reduced spacing
                                      _buildPriceDetailRow(
                                        title: 'Service Charge',
                                        amount: '₹ 0.00',
                                      ),
                                      const SizedBox(height: 12),
                                      // Reduced spacing
                                      const Divider(),
                                      const SizedBox(height: 6),
                                      // Reduced spacing
                                      _buildPriceDetailRow(
                                        title: 'Total Amount',
                                        amount: '₹ 549.00',
                                        isTotal: true,
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Payment Method
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Payment Method',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF000000),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Payment Options
                          Row(
                            children: [
                              Expanded(
                                child: _buildBottomSheetPaymentOption(
                                  title: 'Pay at Center',
                                  icon: Icons.business,
                                  value: 'Pay at Center',
                                  isSelected:
                                      _bottomSheetPaymentMethod ==
                                      'Pay at Center',
                                  onTap: () {
                                    setState(() {
                                      _bottomSheetPaymentMethod =
                                          'Pay at Center';
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildBottomSheetPaymentOption(
                                  title: 'Pay Now',
                                  icon: Icons.credit_card,
                                  value: 'Pay Now',
                                  isSelected:
                                      _bottomSheetPaymentMethod == 'Pay Now',
                                  onTap: () {
                                    setState(() {
                                      _bottomSheetPaymentMethod = 'Pay Now';
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Pay Now Offer (only shown when Pay Now is selected)
                          if (_bottomSheetPaymentMethod == 'Pay Now')
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.black,
                                  width: 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.verified,
                                    color: Color(0xFF8B7FCF),
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Pay Now',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  Text(
                                    ' and ',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF7A7F87),
                                    ),
                                  ),
                                  Text(
                                    'Get 10% Instant Off.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          const SizedBox(height: 24),

                          // Final Book Now Button
                          // Final Book Now Button
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: SizedBox(
                              width: double.infinity,
                              child: _bottomSheetPaymentMethod == null
                                  ? ElevatedButton(
                                      onPressed: null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                        foregroundColor: Colors.white
                                            .withOpacity(0.7),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        elevation: 0,
                                        minimumSize: const Size(0, 48),
                                      ),
                                      child: const Text(
                                        'BOOK NOW',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    )
                                  : ElevatedButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await _bookAppointment();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        elevation: 0,
                                        shadowColor: Colors.transparent,
                                        minimumSize: const Size(0, 48),
                                      ),
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF003373),
                                              Color(0xFFCB6CE6),
                                            ],
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Container(
                                          constraints: const BoxConstraints(
                                            minHeight: 48,
                                          ),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'BOOK NOW',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
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
  }

  Widget _buildBottomSheetPaymentOption({
    required String title,
    required IconData icon,
    required String value,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [const Color(0xFF003373), const Color(0xFFcb6ce6)]
                : [
                    const Color(0xFF003373).withOpacity(0.7),
                    const Color(0xFFcb6ce6).withOpacity(0.7),
                  ],
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B7FCF).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 60, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceDetailRow({
    required String title,
    required String amount,
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: isTotal ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? const Color(0xFF1F2937) : const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessDialog() {
    // Extract just the center name without "STAR Radiology -" prefix
    String displayCenterName = selectedCenter ?? 'STAR Radiology - Noida';
    if (displayCenterName.contains('STAR Radiology - ')) {
      displayCenterName =
          displayCenterName.replaceAll('STAR Radiology - ', '');
    }

    // Get the scan type without "Select your Scan..."
    String displayScanType = selectedScanType ?? 'CT Scan';
    if (displayScanType == 'Select your Scan...') {
      displayScanType = 'CT Scan';
    }

    return Container(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 38),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Animation using Lottie
              SizedBox(
                width: 120,
                height: 120,
                child: Lottie.asset(
                  'assets/animations/success.json', // Add your Lottie animation file
                  fit: BoxFit.contain,
                  repeat: true,
                  animate: true,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                'Appointment Booked',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 3.5,
                ),
              ),

              const SizedBox(height: 16),

              // Description
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  children: [
                  const TextSpan(
                  text: 'Your Appointment for ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF009f93), // grey color
                  ),
                ),
                    TextSpan(
                      text: displayScanType,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF009f93)
                      ),
                    ),
                    const TextSpan(
                      text: ' at Star Radiology ',
                      style: TextStyle(fontSize: 12,
                          color: Color(0xFF009f93)
                      ),
                    ),
                    TextSpan(
                      text: displayCenterName,
                      style: const TextStyle(
                        fontSize: 12,
                          color: Color(0xFF009f93)
                      ),
                    ),
                    const TextSpan(
                      text: ' is successfully booked.',
                      style: TextStyle(fontSize: 12,
                          color: Color(0xFF009f93)
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Gradient Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF003373),
                      Color(0xFFcb6ce6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showSuccessDialog = false;
                    });
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'BACK TO HOME',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _bookAppointment() async {
    if (fullName.isEmpty ||
        mobileNumber.isEmpty ||
        selectedCenter == null ||
        selectedCenter == 'Select your Star Center' ||
        selectedTime == null ||
        _bottomSheetPaymentMethod == null) {
      _showError('Please fill all required fields');
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final token = await AuthService.getToken();

      if (token == null || token.isEmpty) {
        setState(() {
          _isBooking = false;
        });
        _showLoginPrompt();
        return;
      }

      String formattedTime = selectedTime!;
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

      final appointmentData = {
        'procedure':
            '${selectedScanType ?? 'CT Scan'} - ${selectedProcedureDescription ?? 'Abdomen'}',
        'center': selectedCenter!
            .replaceAll('Select your Star Center', '')
            .trim(),
        'fullName': fullName,
        'mobile': mobileNumber,
        'email': emailAddress.isNotEmpty ? emailAddress : '',
        'doctor': referringDoctor.isNotEmpty ? referringDoctor : '',
        'date': selectedDate.toIso8601String(),
        'time': formattedTime,
        'paymentMethod': _bottomSheetPaymentMethod ?? 'Pay at Center',
      };

      print('📤 Sending appointment data: $appointmentData');

      final response = await ApiService.createAppointment(
        token: token,
        body: appointmentData,
      );

      setState(() {
        _isBooking = false;
      });

      print('📥 API Response: $response');

      if (response['ok'] == true) {
        setState(() {
          _showSuccessDialog = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Appointment Booked Successfully!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      } else {
        _showError(response['error'] ?? 'Booking failed');
      }
    } catch (e) {
      setState(() {
        _isBooking = false;
      });

      print('❌ Booking error: $e');

      String errorMessage = 'Booking failed. Please try again.';
      if (e.toString().contains('paymentMethod')) {
        errorMessage = 'Please select a valid payment method.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Session expired. Please login again.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      }

      _showError(errorMessage);
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
