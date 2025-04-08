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
    image: "assets/on-boarding/onboarding1.png",
    title: "Title 01",
    description: "Discover insights from research papers instantly.",
  ),
  OnBoard(
    image: "assets/on-boarding/onboarding1.png",
    title: "Title 02",
    description: "Stay updated with latest academic trends.",
  ),
  OnBoard(
    image: "assets/on-boarding/onboarding1.png",
    title: "Title 03",
    description: "Visualize, summarize and learn smarter.",
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xfff3f4f6), // light background
              Color(0xffffffff),
            ],
          ),
        ),
        child: Column(
          children: [
            // Carousel
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
            const SizedBox(height: 12),

            // Dots Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                demoData.length,
                    (index) => Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: DotIndicator(isActive: index == _pageIndex),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Get Started Button
            InkWell(
              onTap: () {
                print("Get Started tapped");
              },
              child: Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.black, Color(0xff0c0c0c)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "Get started",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Skip link
            TextButton(
              onPressed: () {
                print("Skipped");
              },
              child: Text(
                "skip",
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Image.asset(image, height: 250),
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
        const Spacer(),
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
