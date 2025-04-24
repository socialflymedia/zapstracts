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
//     // Play animations in sequence
//     _logoController.forward().whenComplete(() => _textController.forward());
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
//           // Background gradient + blur
//           Container(
//             width: double.infinity,
//             height: double.infinity,
//             decoration: const BoxDecoration(
//               gradient: RadialGradient(
//                 center: Alignment(0, -0.3),
//                 radius: 1.0,
//                 colors: [
//                   Color(0xFFE5D6FF),
//                   Color(0xFFEEF0FF),
//                   Colors.white,
//                 ],
//                 stops: [0.3, 0.7, 1.0],
//               ),
//             ),
//           ),
//           BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
//             child: Container(
//               color: Colors.white.withOpacity(0.05),
//             ),
//           ),
//
//           // Main content
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
//                   // Animated App Title
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
//                       // Handle Get Started
//                     },
//                   ),
//                   SizedBox(height: 16.h),
//
//                   // Skip Text
//                   GestureDetector(
//                     onTap: () {
//                       // Handle Skip
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
//                   )
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
