import 'package:flutter/material.dart';
import 'create_account_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

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
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF003373),
              Color(0xFFcb6ce6),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Section - Texts
              const SizedBox(height: 50),
              const Text(
                'Your Health',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Just a Tap Away',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 50),
                child: Text(
                  'We bring you cutting-edge technology for faster, clearer, and more reliable reports — all under one roof.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                    fontFamily: 'Canva Sans',
                  ),
                ),
              ),

              // Center Section - Doctor Image (extends to bottom)
              Expanded(
                child: Stack(
                  children: [
                    // Doctor image positioned at bottom with maximum size
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.95, // 95% of screen height - almost full screen
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 1.0, // Full width
                          ),
                          child: Image.asset(
                            'assets/images/doctor.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomCenter,
                            errorBuilder: (context, error, stack) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.person,
                                  size: 120,
                                  color: Colors.white60,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Swipe Button overlaying at bottom
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 40,
                      child: Center(
                        child: _buildSwipeButton(),
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

  Widget _buildSwipeButton() {
    final maxDrag = _buttonWidth - _buttonHeight;
    final progress = (_dragPosition / maxDrag).clamp(0.0, 1.0);
    final circleSize = _buttonHeight - 10;

    return Container(
      width: _buttonWidth,
      height: _buttonHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF3073D3).withOpacity(0.85),
        borderRadius: BorderRadius.circular(32.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Text
          Positioned.fill(
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: (1.0 - progress * 2.0).clamp(0.0, 1.0),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
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

                if ((newPosition - _dragPosition).abs() > 0.5) {
                  setState(() {
                    _dragPosition = newPosition;
                  });
                }

                if (_dragPosition >= maxDrag * 0.75 && !_isAnimating) {
                  _completeSwipe();
                }
              },
              onHorizontalDragEnd: (details) {
                if (_isAnimating) return;

                final velocity = details.primaryVelocity ?? 0;
                if (velocity > 500) {
                  _completeSwipe();
                } else if (_dragPosition < maxDrag * 0.75) {
                  _animateToPosition(0.0);
                }
              },
              onHorizontalDragCancel: () {
                if (_isAnimating) return;
                if (_dragPosition < maxDrag * 0.75) {
                  _animateToPosition(0.0);
                }
              },
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4DEEC),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: progress * 0.2,
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: const Color(0xFF5A7DB0),
                      size: 26,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _completeSwipe() {
    if (_isAnimating) return;

    final maxDrag = _buttonWidth - _buttonHeight;
    _animateToPosition(maxDrag);

    Future.delayed(const Duration(milliseconds: 350), () {
      _animateToPosition(0.0);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateAccountPage(),
        ),
      ).then((_) {
        if (mounted) {
          _animateToPosition(0.0);
        }
      });
    });
  }
}