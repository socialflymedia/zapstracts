
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildSocialButton({required String text, IconData? icon, String? assetPath}) {
  return Container(
    height: 50.h,
    width: double.infinity,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black12),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) Icon(icon, size: 20.sp),
        if (assetPath != null) Image.asset(assetPath, height: 20.h, width: 20.w),
        SizedBox(width: 8.w),
        Text(text, style: TextStyle(fontSize: 14.sp)),
      ],
    ),
  );
}