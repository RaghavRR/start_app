import 'package:flutter/material.dart';
import 'create_account_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  final double _buttonWidth = 280.0;
  final double _buttonHeight = 70.0;
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _dragPosition = 0.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

void _animateToPosition(double target) {
  final maxDrag = _buttonWidth - _buttonHeight;

  _positionAnimation = Tween<double>(
    begin: _dragPosition,
    end: target,
  ).animate(_animationController);

  _animationController
    ..reset()
    ..forward();

  _positionAnimation.addListener(() {
    setState(() => _dragPosition = _positionAnimation.value);
  });
}


  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0.0;
  final double _buttonWidth = 300.0;
  final double _buttonHeight = 65.0;
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _dragPosition = 0.0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animateToPosition(double targetPosition) {
    if (_isAnimating) return;

    _isAnimating = true;
    _positionAnimation = Tween<double>(
      begin: _dragPosition,
      end: targetPosition,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    ));

    _animationController
      ..reset()
      ..forward().then((_) {
        _isAnimating = false;
        if (targetPosition == 0.0) {
          setState(() {
            _dragPosition = 0.0;
          });
        }
      });

    _positionAnimation.addListener(() {
      setState(() {
        _dragPosition = _positionAnimation.value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF234A91), Color(0xFF9370DB)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top texts
              Positioned(
                top: 40,
                left: 0,
                right: 0,
                child: Column(
                  children: const [
                    Text(
                      'Your Health',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      'Just a Tap Away',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        'We bring you cutting-edge technology for faster, clearer, and more reliable reports — all under one roof.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
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
    );
  }

              // Center doctor image
              Positioned(
                top: 160,
                bottom: 150,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Image.asset(
                    'assets/images/doctor.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stack) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(200),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.person, size: 100, color: Colors.white60),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Progress Fill
          ClipRRect(
            borderRadius: BorderRadius.circular(32.5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: _dragPosition + circleSize + 5,
              height: _buttonHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF7A94C0).withOpacity(0.5),
              ),
            ),
          ),

          // Draggable Circle
          AnimatedPositioned(
            duration: const Duration(milliseconds: 50),
            curve: Curves.easeOut,
            left: _dragPosition + 5,
            top: 5,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (_isAnimating) return;

                final newPosition = (_dragPosition + details.primaryDelta!)
                    .clamp(0.0, maxDrag);

              // Bottom swipe button
              Positioned(
                left: 0,
                right: 0,
                bottom: 50,
                child: Center(
                  child: _buildSwipeButton(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildSwipeButton() {
  final maxDrag = _buttonWidth - _buttonHeight;
  final circleSize = _buttonHeight - 8;

  return Container(
    width: _buttonWidth,
    height: _buttonHeight,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF3D5A80), Color(0xFF4A6FA5)],
      ),
      borderRadius: BorderRadius.circular(35),
    ),
    child: Stack(
      children: [
        // Background progress
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: _dragPosition + circleSize,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5E7BB5), Color(0xFF6B8BC5)],
              ),
              borderRadius: BorderRadius.circular(35),
            ),
          ),
        ),

        // Text (fade out)
        Positioned.fill(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: 1 - (_dragPosition / maxDrag * 1.2).clamp(0.0, 1.0),
            child: const Center(
              child: Text(
                "Get Started",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        // Draggable Button
        AnimatedPositioned(
          duration: const Duration(milliseconds: 0),
          left: _dragPosition + 4,
          top: 4,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              final pos = (_dragPosition + details.primaryDelta!)
                  .clamp(0.0, maxDrag);

              setState(() => _dragPosition = pos);

              if (pos >= maxDrag) {
                _completeSwipe();
              }
            },

            onHorizontalDragEnd: (_) {
              if (_dragPosition < maxDrag * 0.8) {
                _animateToPosition(0.0);
              } else {
                _completeSwipe();
              }
            },

            child: Container(
              width: circleSize,
              height: circleSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Colors.white, Colors.white70],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: const Icon(
                Icons.arrow_forward,
                color: Color(0xFF3D5A80),
                size: 28,
              ),
            ),
          ),
        )
      ],
    ),
  );
}


void _completeSwipe() {
  final maxDrag = _buttonWidth - _buttonHeight;

  _animateToPosition(maxDrag);

  Future.delayed(const Duration(milliseconds: 300), () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateAccountPage()),
    ).then((_) {
      _animateToPosition(0.0);
    });
  });
}

}