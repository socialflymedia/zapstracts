import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../features/personalization/models/topic.dart';

class TopicCard extends StatelessWidget {
  final Topic topic;
  final bool isSelected;
  final VoidCallback onTap;

  const TopicCard({
    super.key,
    required this.topic,
    required this.isSelected,
    required this.onTap,
  });

  double _calculateOptimalFontSize(String text, double maxWidth, double maxHeight) {
    // Start with a base font size
    double fontSize = 16.0;
    const double minFontSize = 10.0;
    const double maxFontSize = 18.0;

    // Create a TextPainter to measure text
    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );

    // Binary search for optimal font size
    double low = minFontSize;
    double high = maxFontSize;

    while (high - low > 0.5) {
      fontSize = (low + high) / 2;

      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize.sp,
          fontWeight: FontWeight.w600,
        ),
      );

      textPainter.layout();

      if (textPainter.width <= maxWidth && textPainter.height <= maxHeight) {
        low = fontSize;
      } else {
        high = fontSize;
      }
    }

    return low;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.r),
          color: isSelected
              ? const Color(0xFF4C3BCF)
              : const Color(0xFF6B46C1),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF4C3BCF).withOpacity(0.3),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate available space for text (accounting for padding)
              final availableWidth = constraints.maxWidth - 8.w; // Small buffer
              final availableHeight = constraints.maxHeight - 8.h; // Small buffer

              // Calculate optimal font size
              final optimalFontSize = _calculateOptimalFontSize(
                topic.displayName,
                availableWidth,
                availableHeight,
              );

              return Center(
                child: Text(
                  topic.displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: optimalFontSize.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}