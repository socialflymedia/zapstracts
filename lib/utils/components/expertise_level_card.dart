import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/personalization/models/expertise_level.dart';

class ExpertiseLevelCard extends StatelessWidget {
  final ExpertiseLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const ExpertiseLevelCard({
    super.key,
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        height: double.infinity, // Fill the available height
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEDE7F6) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF6750A4) : Colors.grey[200]!,
            width: 1.5.w,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF6750A4).withOpacity(0.1),
              spreadRadius: 1.r,
              blurRadius: 6.r,
              offset: Offset(0, 2.h),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 0.5.r,
              blurRadius: 2.r,
              offset: Offset(0, 1.h),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emoji container with consistent sizing
            Container(
              width: 40.w,
              height: 40.w,
              alignment: Alignment.center,
              child: Text(
                level.emoji,
                style: TextStyle(fontSize: 26.sp),
              ),
            ),
            SizedBox(width: 16.w),
            // Content section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h), // Small top padding for alignment
                  Text(
                    level.title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF6750A4) : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Flexible(
                    child: Text(
                      level.description,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: isSelected ? Colors.black87 : Colors.black54,
                        fontStyle: FontStyle.italic,
                        height: 1.4, // Better line height for readability
                      ),
                      maxLines: 4, // Limit max lines to prevent overflow
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: isSelected ? 30.w : 0,
              height: 30.w,
              margin: EdgeInsets.only(left: isSelected ? 8.w : 0),
              child: isSelected
                  ? Icon(
                Icons.check_circle,
                color: const Color(0xFF6750A4),
                size: 24.sp,
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}