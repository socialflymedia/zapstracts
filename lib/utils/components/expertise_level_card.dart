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
        padding: EdgeInsets.all(11.w),
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
              : [],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              level.emoji,
              style: TextStyle(fontSize: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? const Color(0xFF6750A4) : Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    level.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isSelected ? Colors.black87 : Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                margin: EdgeInsets.only(left: 8.w),
                child: Icon(
                  Icons.check_circle,
                  color: const Color(0xFF6750A4),
                  size: 24.sp,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
