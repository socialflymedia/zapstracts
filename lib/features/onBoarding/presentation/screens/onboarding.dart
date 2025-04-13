import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapstract/core/constants/colors/colors.dart';

// OnBoarding content Model
class OnBoard {
  final String image, title, description;

  OnBoard({
    required this.image,
    required this.title,
    required this.description,
  });
}

// OnBoarding content list
final List<OnBoard> demoData = [
  OnBoard(
    image: "assets/on-boarding/onBoardingImage1.png",
    title: "Keep up with the latest science updates",
    description: "Our intelligent search connects you with the most "
        "relevant research papers, journals, and articles across a wide range of subjects. "
        "Say goodbye to endless scrolling and hello to smart discovery.",
  ),
  OnBoard(
    image: "assets/on-boarding/onBoardingImage2.png",
    title: "Never miss out on important updates.",
    description: "Our intelligent search connects you with the most relevant research papers,"
        " journals, and articles across a wide range of subjects. Say goodbye to endless "
        "scrolling and hello to smart discovery.",
  ),
  OnBoard(
    image: "assets/on-boarding/onBoardingImage3.png",
    title: "Keep up with the latest science updates",
    description: "Our intelligent search connects you with the most "
        "relevant research papers, journals, and articles across a wide range of subjects. "
        "Say goodbye to endless scrolling and hello to smart discovery.",
  ),
];

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  late PageController _pageController;
  int _pageIndex = 0;


  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    // _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
    //   if (_pageIndex < demoData.length - 1) {
    //     _pageIndex++;
    //   } else {
    //     _pageIndex = 0;
    //   }
    //
    //   _pageController.animateToPage(
    //     _pageIndex,
    //     duration: const Duration(milliseconds: 350),
    //     curve: Curves.easeIn,
    //   );
    // });
  }

  @override
  void dispose() {
    _pageController.dispose();
    // _timer?.cancel();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _pageIndex = index);
              },
              itemCount: demoData.length,
              itemBuilder: (context, index) => OnBoardContent(
                title: demoData[index].title,
                description: demoData[index].description,
                image: demoData[index].image,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(
                    demoData.length,
                        (index) => Padding(
                      padding: EdgeInsets.only(right: 6.w),
                      child: DotIndicator(isActive: index == _pageIndex),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => print("Skip"),
                  child: Text(
                    "Skip",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              ],
            ),
          ),
          // SizedBox(height: 12.h),
        ],
      ),
    );
  }

}

// OnBoarding content widget
class OnBoardContent extends StatelessWidget {
  final String image;
  final String title;
  final String description;

  const OnBoardContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });

  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 420.h,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(image, fit: BoxFit.cover),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.white.withOpacity(0.95)],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black54,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

}

// Dot Indicator widget
class DotIndicator extends StatelessWidget {
  final bool isActive;

  const DotIndicator({super.key, this.isActive = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
