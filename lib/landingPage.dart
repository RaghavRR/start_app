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
          // Reset completed
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
    final size = MediaQuery.of(context).size;
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
          child: Stack(
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

              // Bottom swipe button
              Positioned(
                left: 0,
                right: 0,
                bottom: 50,
                child: Center(
                  child: _buildSwipeButton(),
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
    final circleSize = _buttonHeight - 8;

    return Container(
      width: _buttonWidth,
      height: _buttonHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3D5A80).withOpacity(0.9),
            const Color(0xFF4A6FA5).withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Animated Text
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: (1.0 - progress * 1.5).clamp(0.0, 1.0),
            child: const Positioned.fill(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 20),
                  child: Text(
                    'Get Started',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Progress background (fills as user drags)
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            width: _dragPosition + circleSize,
            height: _buttonHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF5E7BB5).withOpacity(0.7),
                  const Color(0xFF6B8BC5).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(35),
            ),
          ),

          // Draggable circle
          AnimatedPositioned(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
            left: _dragPosition + 4,
            top: 4,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (_isAnimating) return;

                final newPosition = (_dragPosition + details.primaryDelta!)
                    .clamp(0.0, maxDrag);

                // Use setState only if position actually changed
                if ((newPosition - _dragPosition).abs() > 0.5) {
                  setState(() {
                    _dragPosition = newPosition;
                  });
                }

                // Auto complete if dragged more than 75%
                if (_dragPosition >= maxDrag * 0.75 && !_isAnimating) {
                  _completeSwipe();
                }
              },
              onHorizontalDragEnd: (details) {
                if (_isAnimating) return;

                // Check velocity for quick swipe
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
              child: Material(
                elevation: 4,
                shape: const CircleBorder(),
                child: Container(
                  width: circleSize,
                  height: circleSize,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE8E8F0),
                        Color(0xFFFFFFFF),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: progress * 0.25, // Slight rotation on drag
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Color(0xFF3D5A80),
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

    // Navigate after animation with reset
    Future.delayed(const Duration(milliseconds: 350), () {
      // Reset position before navigation so when user comes back, it's at start
      _animateToPosition(0.0);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CreateAccountPage(),
        ),
      ).then((_) {
        // Also reset when returning from next page
        if (mounted) {
          _animateToPosition(0.0);
        }
      });
    });
  }
}