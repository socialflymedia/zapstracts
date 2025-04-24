// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../../core/constants/colors/colors.dart';
// import '../../../../utils/components/primaryButton.dart';
//
// class GetStarted extends StatefulWidget {
//   const GetStarted({super.key});
//
//   @override
//   State<GetStarted> createState() => _GetStartedState();
// }
//
// class _GetStartedState extends State<GetStarted>
//     with TickerProviderStateMixin {
//   late final AnimationController _logoController;
//   late final Animation<double> _logoAnimation;
//
//   late final AnimationController _textController;
//   late final Animation<double> _textOpacity;
//
//   int _gradientIndex = 0;
//   final List<List<Color>> _gradientColors = [
//     [Color(0xFFE5D6FF), Color(0xFFD0CFFF), Colors.white],
//     [Color(0xFFF3E8FF), Color(0xFFE0D9FF), Colors.white],
//     [Color(0xFFEADFFF), Color(0xFFEEF0FF), Colors.white],
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//
//     _logoController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );
//     _logoAnimation = CurvedAnimation(
//       parent: _logoController,
//       curve: Curves.easeOutBack,
//     );
//
//     _textController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );
//     _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _textController, curve: Curves.easeIn),
//     );
//
//     _logoController.forward().whenComplete(() => _textController.forward());
//
//     // Start gradient cycling
//     Future.delayed(Duration.zero, _cycleGradient);
//   }
//
//   void _cycleGradient() {
//     Future.delayed(const Duration(seconds: 4), () {
//       setState(() {
//         _gradientIndex = (_gradientIndex + 1) % _gradientColors.length;
//       });
//       _cycleGradient(); // Loop
//     });
//   }
//
//   @override
//   void dispose() {
//     _logoController.dispose();
//     _textController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Animated Gradient Background
//           AnimatedContainer(
//             duration: const Duration(seconds: 3),
//             curve: Curves.easeInOut,
//             decoration: BoxDecoration(
//               gradient: RadialGradient(
//                 center: const Alignment(0, -0.3),
//                 radius: 1.2,
//                 colors: _gradientColors[_gradientIndex],
//                 stops: const [0.3, 0.7, 1.0],
//               ),
//             ),
//           ),
//
//           // Dreamy Blur
//           BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
//             child: Container(
//               color: Colors.white.withOpacity(0.05),
//             ),
//           ),
//
//           // Main Content
//           Center(
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 20.w),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   // Animated Logo
//                   ScaleTransition(
//                     scale: _logoAnimation,
//                     child: Image.asset(
//                       'assets/logo/logo1.png',
//                       height: 240.h,
//                       fit: BoxFit.contain,
//                     ),
//                   ),
//                   SizedBox(height: 24.h),
//
//                   // Animated App Name
//                   FadeTransition(
//                     opacity: _textOpacity,
//                     child: Padding(
//                       padding: EdgeInsets.only(top: 8.h),
//                       child: Text(
//                         'Zapstracts',
//                         style: TextStyle(
//                           fontSize: 28.sp,
//                           fontWeight: FontWeight.bold,
//                           color: AppColors.primary,
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 60.h),
//
//                   // Get Started Button
//                   CustomGradientButton(
//                     text: "Get Started",
//                     onPressed: () {
//                       // Navigate
//                     },
//                   ),
//                   SizedBox(height: 16.h),
//
//                   // Skip
//                   GestureDetector(
//                     onTap: () {
//                       // Skip logic
//                     },
//                     child: Text(
//                       'skip',
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         color: AppColors.primary,
//                         fontWeight: FontWeight.bold,
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapstract/features/onBoarding/presentation/screens/onboarding.dart';
import '../../../../core/constants/colors/colors.dart';
import '../../../../utils/components/primaryButton.dart';

class GetStarted extends StatefulWidget {
  const GetStarted({super.key});

  @override
  State<GetStarted> createState() => _GetStartedState();
}

class _GetStartedState extends State<GetStarted> with TickerProviderStateMixin {
  late final AnimationController _animationController;

  late final AnimationController _logoController;
  late final Animation<double> _logoAnimation;
  late final AnimationController _textController;
  late final Animation<double> _textOpacity;

  @override

  void initState() {
    super.initState();

    // Animated background: sync movement, stop after 2.5s
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // full cycle
    );

    _animationController.forward();

    Future.delayed(const Duration(milliseconds: 3000), () {
      _animationController.animateTo(
        _animationController.value,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutCirc,
      );
    });


    // Logo and text animations
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeIn),
    );

    _logoController.forward().whenComplete(() => _textController.forward());
  }


  @override
  void dispose() {
    _animationController.dispose();
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Spherical Blob Background
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              return CustomPaint(
                size: Size.infinite,
                painter: BlobbyBackgroundPainter(_animationController.value),
              );
            },
          ),

          // Dreamy blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              color: Colors.transparent,
            ),
          ),

          // Main Content
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _logoAnimation,
                    child: Image.asset(
                      'assets/logo/logo2.png',
                      height: 240.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  FadeTransition(
                    opacity: _textOpacity,
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        'Zapstracts',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 60.h),

                  CustomGradientButton(
                    text: "Get Started",
                    onPressed: () {
                      // navigate
                      print("here");
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>OnBoardingScreen()));
                    },
                  ),
                  SizedBox(height: 16.h),

                  GestureDetector(
                    onTap: () {
                      print("skip");
                    },
                    child: Text(
                      'skip',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BlobbyBackgroundPainter extends CustomPainter {
  final double progress;
  BlobbyBackgroundPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final double radius = 320;

    final double spinRadius = 60; // small tight orbit to simulate fast spin
    final double spinSpeed = 6; // how fast each blob spins

    final List<Offset> baseCenters = [
      Offset(size.width * 0.25, size.height * 0.25),
      Offset(size.width * 0.75, size.height * 0.25),
      Offset(size.width * 0.25, size.height * 0.88),
      Offset(size.width * 0.75, size.height * 0.75),
    ];

    final List<double> phaseOffsets = [0, pi / 2, pi, 3 * pi / 2];

    // final List<Offset> centers = List.generate(4, (i) {
    //   final angle = progress * 2 * pi * spinSpeed + phaseOffsets[i];
    //   return Offset(
    //     baseCenters[i].dx + spinRadius * cos(angle),
    //     baseCenters[i].dy + spinRadius * sin(angle),
    //   );
    // });
    //
    final Offset centerTarget = Offset(size.width / 2, size.height * 0.52);

// Interpolation strength: only affects last ~0.25 of the animation
    double settleProgress = (progress - 0.5) * 2;
    settleProgress = settleProgress.clamp(0.0, 1.0);
    settleProgress = Curves.easeOut.transform(settleProgress);

    final List<Offset> centers = List.generate(4, (i) {
      final angle = progress * 2 * pi * spinSpeed + phaseOffsets[i];
      final spinOffset = Offset(
        baseCenters[i].dx + spinRadius * cos(angle),
        baseCenters[i].dy + spinRadius * sin(angle),
      );
      return Offset.lerp(spinOffset, centerTarget, settleProgress)!;
    });

    final List<Color> colors = [
      const Color(0xFFB89EFF).withOpacity(0.5),
      const Color(0xFF8F80FF).withOpacity(0.4),
      const Color(0xFFD3C0FF).withOpacity(0.9),
      const Color(0xFFC1A9FF).withOpacity(0.8),
    ];

    for (int i = 0; i < centers.length; i++) {
      paint.shader = RadialGradient(
        center: Alignment.center,
        radius: 0.3,
        colors: [colors[i], Colors.transparent],
      ).createShader(
        Rect.fromCircle(center: centers[i], radius: radius),
      );

      canvas.drawCircle(centers[i], radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant BlobbyBackgroundPainter oldDelegate) =>
      oldDelegate.progress != progress;
}


