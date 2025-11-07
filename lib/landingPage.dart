import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0B3B8C), Color(0xFF7B3CE6)],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Top texts
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Your Health\nJust a Tap Away',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          height: 1.05,
                          shadows: [Shadow(blurRadius: 6, color: Colors.black26, offset: Offset(0, 2))],
                        ),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'We bring you cutting-edge technology for faster, clearer, and more reliable reports — all under one roof.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),

              // Center doctor image
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: SizedBox(
                    height: size.height * 0.52,
                    child: Image.asset(
                      'assets/images/doctor.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) {
                        // If the asset is not present, show a simple placeholder
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.person, size: 96, color: Colors.white70),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Bottom left pill button
              Positioned(
                left: 20,
                bottom: 30,
                child: GestureDetector(
                  onTap: () {
                    // Placeholder action: replace with navigation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Get Started tapped')),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E5778),
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0,4))],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Get Started',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_forward, color: Colors.white),
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
    );
  }
}
