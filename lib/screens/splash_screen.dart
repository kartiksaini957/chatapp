import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/auth_service.dart';
import 'auth/login_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _photoController;
  late AnimationController _textController;
  late AnimationController _shimmerController;

  late Animation<double> _photoScale;
  late Animation<double> _photoOpacity;
  late Animation<double> _glowPulse;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();

    _photoController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _photoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _photoController, curve: Curves.elasticOut));
    _photoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _photoController, curve: const Interval(0.0, 0.5, curve: Curves.easeIn)));

    _textController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
        CurvedAnimation(parent: _textController, curve: Curves.easeOut));

    _shimmerController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _shimmer = Tween<double>(begin: 0.0, end: 1.0).animate(_shimmerController);

    _glowPulse = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOut));

    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _photoController.forward();
    });
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 3200), () async {
      if (!mounted) return;
      final loggedIn = await AuthService.isLoggedIn();
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) =>
              loggedIn ? const HomeScreen() : const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 700),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _photoController.dispose();
    _textController.dispose();
    _shimmerController.dispose();
    super.dispose();
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
            stops: [0.0, 0.4, 0.75, 1.0],
            colors: [
              Color(0xFF1A0505),
              Color(0xFF3D0C0C),
              Color(0xFF6B1A00),
              Color(0xFF1A0505),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative mandala rings - top
            Positioned(
              top: -size.width * 0.3,
              left: -size.width * 0.3,
              child: _buildDecorativeRing(size.width * 0.8, AppTheme.gold.withOpacity(0.06)),
            ),
            Positioned(
              top: -size.width * 0.15,
              right: -size.width * 0.3,
              child: _buildDecorativeRing(size.width * 0.7, AppTheme.saffron.withOpacity(0.05)),
            ),
            // Bottom arcs
            Positioned(
              bottom: -size.width * 0.2,
              left: -size.width * 0.1,
              child: _buildDecorativeRing(size.width * 0.9, AppTheme.gold.withOpacity(0.07)),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  Flexible(flex: 3, child: SizedBox()),

                  // ── GURUJI PHOTO CIRCLE ──
                  AnimatedBuilder(
                    animation: _photoController,
                    builder: (_, child) => Opacity(
                      opacity: _photoOpacity.value,
                      child: Transform.scale(scale: _photoScale.value, child: child),
                    ),
                    child: AnimatedBuilder(
                      animation: _glowPulse,
                      builder: (_, child) => Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.saffron.withOpacity(0.35 * _glowPulse.value),
                              blurRadius: 60,
                              spreadRadius: 10,
                            ),
                            BoxShadow(
                              color: AppTheme.gold.withOpacity(0.2 * _glowPulse.value),
                              blurRadius: 100,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        child: child,
                      ),
                      child: _buildGurujiPhoto(),
                    ),
                  ),

                  Flexible(flex: 2, child: SizedBox()),

                  // ── TEXT SECTION ──
                  AnimatedBuilder(
                    animation: _textController,
                    builder: (_, child) => FadeTransition(
                      opacity: _textFade,
                      child: SlideTransition(position: _textSlide, child: child),
                    ),
                    child: Column(
                      children: [
                        // Decorative line with lotus
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildGoldLine(60),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('🪷', style: TextStyle(fontSize: 18)),
                            ),
                            _buildGoldLine(60),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Radhe Radhe
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppTheme.gold, Color(0xFFFFF0A0), AppTheme.gold],
                          ).createShader(bounds),
                          child: const Text(
                            '🙏 Radhe Radhe 🙏',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Main title
                        const Text(
                          'Shri Hit',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            letterSpacing: 8,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(height: 6),
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [AppTheme.saffron, Color(0xFFFF9D3A), AppTheme.gold],
                          ).createShader(bounds),
                          child: const Text(
                            'Radha Kripa',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Subtitle
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.gold.withOpacity(0.25)),
                            borderRadius: BorderRadius.circular(30),
                            color: AppTheme.gold.withOpacity(0.06),
                          ),
                          child: Text(
                            'Guruji ke pravachan se aapke sawalon ke jawab',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 13,
                              letterSpacing: 0.3,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Flexible(flex: 3, child: SizedBox()),

                  // ── LOADING INDICATOR ──
                  AnimatedBuilder(
                    animation: _textFade,
                    builder: (_, child) => Opacity(opacity: _textFade.value, child: child),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: Column(
                        children: [
                          AnimatedBuilder(
                            animation: _shimmer,
                            builder: (_, __) => _buildShimmerDots(),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading...',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.35),
                              fontSize: 12,
                              letterSpacing: 3,
                            ),
                          ),
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

  Widget _buildGurujiPhoto() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer golden ring
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: SweepGradient(
              colors: [
                AppTheme.gold,
                AppTheme.saffron,
                const Color(0xFFFFF0A0),
                AppTheme.saffron,
                AppTheme.gold,
              ],
            ),
          ),
        ),
        // White gap ring
        Container(
          width: 192,
          height: 192,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF3D0C0C),
          ),
        ),
        // Inner golden ring
        Container(
          width: 184,
          height: 184,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.gold, AppTheme.saffron],
            ),
          ),
        ),
        // Photo area — REPLACE Image.network(...) with actual guruji photo
        // e.g.: Image.asset('assets/images/guruji.jpg', fit: BoxFit.cover)
        ClipOval(
          child: Container(
            width: 176,
            height: 176,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF6B2A00), Color(0xFF3D0C0C)],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // ── GURUJI PHOTO YAHAN DAALO ──
                // Abhi placeholder hai. Replace karo:
                // Image.asset('assets/images/guruji.jpg',
                //   width: 176, height: 176, fit: BoxFit.cover)
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🪷', style: TextStyle(fontSize: 52)),
                    const SizedBox(height: 4),
                    Text(
                      'Guruji',
                      style: TextStyle(
                        color: AppTheme.gold.withOpacity(0.8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      'ki Photo',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Small lotus decorations around circle
        ..._buildOrbitingLotus(),
      ],
    );
  }

  List<Widget> _buildOrbitingLotus() {
    final positions = [
      const Offset(0, -100),   // top
      const Offset(100, 0),    // right
      const Offset(0, 100),    // bottom
      const Offset(-100, 0),   // left
    ];
    return positions.map((pos) => Positioned(
      left: 100 + pos.dx - 10,
      top: 100 + pos.dy - 10,
      child: const Text('✦', style: TextStyle(color: AppTheme.gold, fontSize: 14)),
    )).toList();
  }

  Widget _buildDecorativeRing(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1),
      ),
    );
  }

  Widget _buildGoldLine(double width) {
    return Container(
      width: width,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, AppTheme.gold.withOpacity(0.6), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildShimmerDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final offset = (i * 0.33 + _shimmer.value).clamp(0.0, 1.0);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.gold.withOpacity(0.3 + 0.7 * offset),
          ),
        );
      }),
    );
  }
}
