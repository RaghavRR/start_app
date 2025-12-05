import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'landingPage.dart';
import 'create_account_page.dart';
import 'login_page.dart';
import 'my_appointment_page.dart';
import 'profile_page.dart';
import 'home_page.dart';
import 'book_appointment_flow.dart';
import 'dart:math' as math;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if user is already logged in
  final isLoggedIn = await AuthService.isLoggedIn();

  runApp(MyApp(initialRoute: isLoggedIn ? '/home' : '/splash'));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Star Radiology',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: initialRoute,
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/create-account': (context) => const CreateAccountPage(),
        '/appointments': (context) => const MyAppointmentPage(),
        '/profile': (context) => const ProfilePage(),
        '/home': (context) => const HomePage(),
        '/book-appointment': (context) => const BookAppointmentFlow(),
      },
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.625, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Navigate after splash duration
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        // Check if user is logged in to determine where to navigate
        AuthService.isLoggedIn().then((isLoggedIn) {
          Navigator.pushReplacementNamed(
            context,
            isLoggedIn ? '/home' : '/landing',
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final opacity = _controller.value <= 0.5
              ? _fadeInAnimation.value
              : _fadeOutAnimation.value;

          return Opacity(
            opacity: opacity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomPaint(
                        size: const Size(60, 60),
                        painter: StarPainter(
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomPaint(
                        size: const Size(35, 35),
                        painter: StarPainter(
                          color: const Color(0xFFD4AF37),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Star',
                            style: TextStyle(
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD4AF37),
                              height: 1.0,
                            ),
                          ),
                          Text(
                            'Radiology',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              fontStyle: FontStyle.italic,
                              color: const Color(0xFFD4AF37),
                              height: 0.8,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.1),
                                  offset: const Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'A best brand For Tele Radiology',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFE63946),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Star Painter
class StarPainter extends CustomPainter {
  final Color color;

  StarPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;
    const points = 5;

    for (int i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - (math.pi / 2);
      final radius = i.isEven ? outerRadius : innerRadius;
      final x = centerX + radius * math.cos(angle);
      final y = centerY + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}