import 'package:flutter/material.dart';
import 'auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentBottomIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  Map<String, dynamic>? _currentUser;
  bool _isLoading = true;

  // Mock data - Replace with API calls
  final List<Map<String, dynamic>> banners = [
    {
      'image': 'https://via.placeholder.com/400x200/4A90E2/FFFFFF?text=Star+Radiology',
      'title': 'Star Radiology',
      'subtitle': 'Our Trusted Partner of Choice',
    },
    {
      'image': 'https://via.placeholder.com/400x200/7B68EE/FFFFFF?text=Health+Care',
      'title': 'Premium Health Care',
      'subtitle': 'Book Your Tests Today',
    },
  ];

  final List<Map<String, dynamic>> testCategories = [
    {
      'name': 'CT Scans',
      'image': 'https://via.placeholder.com/150/4A90E2/FFFFFF?text=CT',
    },
    {
      'name': 'Ultrasound',
      'image': 'https://via.placeholder.com/150/7B68EE/FFFFFF?text=Ultrasound',
    },
    {
      'name': 'MRI',
      'image': 'https://via.placeholder.com/150/EC4899/FFFFFF?text=MRI',
    },
    {
      'name': 'Pathology',
      'image': 'https://via.placeholder.com/150/10B981/FFFFFF?text=Pathology',
    },
  ];

  final Map<String, dynamic> promoOffer = {
    'title': 'Book your Test Now!',
    'discount': 'Get 20% Off',
    'code': 'STAR20',
    'description': 'Use Coupon Code',
    'image': 'https://via.placeholder.com/200x150/F3F4F6/6B7280?text=Promo',
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getUser();
      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getUserInitials(String fullName) {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else if (names.isNotEmpty) {
      return names[0][0].toUpperCase();
    }
    return 'U';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFE8E8F5), Color(0xFFF0E8F5)],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message and notification
                  Row(
                    children: [
                      // Avatar with user initials
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF6366F1),
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _isLoading
                              ? Container(
                            color: const Color(0xFF6366F1).withOpacity(0.2),
                            child: const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                              ),
                            ),
                          )
                              : _currentUser != null
                              ? Container(
                            color: const Color(0xFF6366F1),
                            child: Center(
                              child: Text(
                                _getUserInitials(_currentUser!['fullName'] ?? 'User'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                              : Container(
                            color: const Color(0xFF6366F1).withOpacity(0.2),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF6366F1),
                              size: 30,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Welcome text with user data
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _isLoading ? 'Loading...' : 'Welcome Back! ',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                                if (!_isLoading)
                                  const Text(
                                    '👋',
                                    style: TextStyle(fontSize: 15),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isLoading
                                  ? 'Loading...'
                                  : _currentUser?['fullName'] ?? 'User',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                            if (_currentUser != null && _currentUser!['mobile'] != null)
                              const SizedBox(height: 2),
                            if (_currentUser != null && _currentUser!['mobile'] != null)
                              Text(
                                _currentUser!['mobile'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Notification bell
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: Color(0xFF6366F1),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Find your Labs, Tests...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF6B7280),
                        ),
                        suffixIcon: Container(
                          margin: const EdgeInsets.all(8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5FCF)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // Banner Carousel
                    SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: banners.length,
                        itemBuilder: (context, index) {
                          final banner = banners[index];
                          return Container(
                            width: MediaQuery.of(context).size.width - 40,
                            margin: EdgeInsets.only(
                              right: index < banners.length - 1 ? 16 : 0,
                            ),
                            child: _buildBannerCard(
                              banner['image'],
                              banner['title'],
                              banner['subtitle'],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Test Categories Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: testCategories.length,
                        itemBuilder: (context, index) {
                          final category = testCategories[index];
                          return _buildTestCategoryCard(
                            category['name'],
                            category['image'],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Book a Test and Find Center Buttons
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              'Book A Test',
                              Icons.event_available,
                              const Color(0xFF4A5C8C),
                                  () {
                                // Navigate to book test
                                Navigator.pushNamed(context, '/book-appointment');
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildActionButton(
                              'Find your\nNearest center',
                              Icons.location_on_outlined,
                              const Color(0xFF4A5C8C),
                                  () {
                                // Navigate to find center
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Promo Banner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildPromoBanner(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBannerCard(String imageUrl, String title, String subtitle) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4A90E2), Color(0xFF7B68EE)],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_hospital, size: 50, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
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

  Widget _buildTestCategoryCard(String name, String imageUrl) {
    return GestureDetector(
      onTap: () {
        // Navigate to category tests
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6366F1).withOpacity(0.1),
                            const Color(0xFF8B5FCF).withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.medical_services,
                        color: Color(0xFF6366F1),
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String text,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  promoOffer['title'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  promoOffer['discount'],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6366F1),
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                    children: [
                      TextSpan(text: promoOffer['description']),
                      const TextSpan(text: ': '),
                      TextSpan(
                        text: promoOffer['code'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              promoOffer['image'],
              width: 100,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 100,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.discount,
                    color: Color(0xFF6366F1),
                    size: 40,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C4A7C),
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
        child: BottomNavigationBar(
          currentIndex: _currentBottomIndex,
          onTap: (index) {
            setState(() {
              _currentBottomIndex = index;
            });
            switch (index) {
              case 0:
              // Already on Home
                break;
              case 1:
                Navigator.pushNamed(context, '/appointments'); // CHANGED
                break;
              case 2:
              // Navigate to Cart
                break;
              case 3:
              // Navigate to Reports
                break;
              case 4:
                Navigator.pushNamed(context, '/profile'); // CHANGED
                break;
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF2C4A7C),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white60,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
   items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentBottomIndex == 0
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.home_outlined, size: 26),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentBottomIndex == 1
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_today_outlined, size: 24),
              ),
              label: 'Appointments',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC4899), Color(0xFFF472B6)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFEC4899).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.shopping_cart_outlined, size: 24, color: Colors.white),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentBottomIndex == 3
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.description_outlined, size: 24),
              ),
              label: 'My Reports',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _currentBottomIndex == 4
                      ? Colors.white.withOpacity(0.2)
                      : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, size: 26),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}