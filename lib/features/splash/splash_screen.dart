import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/storage/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<Offset> _slideAnimation;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: .88, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, .18), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    _timer = Timer(const Duration(milliseconds: 2100), () {
      if (!mounted) return;

      Get.offAllNamed(StorageService.canEnterApp ? Routes.home : Routes.auth);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101014) : Colors.white,
      body: Stack(
        children: [
          const Positioned.fill(child: _SplashBackground()),

          const Positioned(
            top: -80,
            right: -80,
            child: _SoftCircle(size: 230, opacity: .08),
          ),

          const Positioned(
            bottom: -90,
            left: -70,
            child: _SoftCircle(size: 260, opacity: .07),
          ),

          const Positioned(
            top: 0,
            right: 0,
            child: _CornerPattern(alignment: Alignment.topRight),
          ),

          const Positioned(
            bottom: 0,
            left: 0,
            child: _CornerPattern(alignment: Alignment.bottomLeft),
          ),

          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        ScaleTransition(
                          scale: _scaleAnimation,
                          child: const _LogoSection(),
                        ),

                        const SizedBox(height: 34),

                        const Text(
                          'مدرج',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.black,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            letterSpacing: -.5,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'مجتمع المشجعين العرب',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: .2,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Container(
                          height: 3,
                          width: 54,
                          decoration: BoxDecoration(
                            color: AppColors.red,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),

                        const Spacer(flex: 2),

                        const _LoadingSection(),

                        const SizedBox(height: 26),
                      ],
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
}

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 236,
      height: 236,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.94),
        borderRadius: BorderRadius.circular(54),
        border: Border.all(color: Colors.black.withOpacity(.045), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.08),
            blurRadius: 36,
            offset: const Offset(0, 22),
          ),
          BoxShadow(
            color: AppColors.red.withOpacity(.08),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(54),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1,
                    colors: [Colors.white, const Color(0xFFF4F4F4)],
                  ),
                ),
              ),
            ),

            // هنا كبرنا اللوقو قليلًا حتى يظهر الجسم أوضح
            Transform.scale(
              scale: 1.0,
              child: Image.asset(
                'assets/app_icon.png',
                width: 210,
                height: 210,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.sports_soccer_rounded,
                    color: AppColors.red,
                    size: 82,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingSection extends StatelessWidget {
  const _LoadingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: AppColors.red,
            backgroundColor: Color(0xFFEAEAEA),
          ),
        ),

        const SizedBox(height: 14),

        Container(
          width: 160,
          height: 5,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(99),
          ),
          clipBehavior: Clip.antiAlias,
          child: Align(
            alignment: Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: .58,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.redGradient,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'جاري تجهيز المدرج...',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _SplashBackground extends StatelessWidget {
  const _SplashBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SplashBackgroundPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _SplashBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final softPaint = Paint()
      ..color = const Color(0xFFF4F4F4)
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = AppColors.black.withOpacity(.045)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;

    final redPaint = Paint()
      ..color = AppColors.red.withOpacity(.12)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      Offset(size.width * .5, size.height * .48),
      size.width * .72,
      softPaint,
    );

    final stadiumPath1 = Path()
      ..moveTo(-40, size.height * .66)
      ..quadraticBezierTo(
        size.width * .5,
        size.height * .52,
        size.width + 40,
        size.height * .66,
      );

    final stadiumPath2 = Path()
      ..moveTo(-40, size.height * .70)
      ..quadraticBezierTo(
        size.width * .5,
        size.height * .57,
        size.width + 40,
        size.height * .70,
      );

    final stadiumPath3 = Path()
      ..moveTo(-40, size.height * .74)
      ..quadraticBezierTo(
        size.width * .5,
        size.height * .62,
        size.width + 40,
        size.height * .74,
      );

    canvas.drawPath(stadiumPath1, linePaint);
    canvas.drawPath(stadiumPath2, linePaint);
    canvas.drawPath(stadiumPath3, redPaint);

    final diagonalPaint = Paint()
      ..color = AppColors.red.withOpacity(.12)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * .08, size.height * .94),
      Offset(size.width * .34, size.height * .72),
      diagonalPaint,
    );

    final blackDiagonalPaint = Paint()
      ..color = AppColors.black.withOpacity(.08)
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * .02, size.height * .97),
      Offset(size.width * .32, size.height * .69),
      blackDiagonalPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerPattern extends StatelessWidget {
  const _CornerPattern({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: .055,
      child: SizedBox(
        width: 190,
        height: 190,
        child: Image.asset(
          'assets/sadu_pattern.jpeg',
          fit: BoxFit.cover,
          alignment: alignment,
        ),
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.red.withOpacity(opacity),
      ),
    );
  }
}
