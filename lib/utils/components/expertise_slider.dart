import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../features/personalization/models/expertise_level.dart';

class ExpertiseSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const ExpertiseSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 3.h,
            trackShape: const RoundedRectSliderTrackShape(),
            activeTrackColor: const Color(0xFF6750A4),
            inactiveTrackColor: Colors.grey[200],
            thumbShape: _CustomThumbShape(),
            overlayShape: RoundSliderOverlayShape(overlayRadius: 20.r),
            overlayColor: const Color(0xFF6750A4).withOpacity(0.2),
            thumbColor: const Color(0xFF6750A4),
            tickMarkShape: const RoundSliderTickMarkShape(),
            activeTickMarkColor: Colors.white,
            inactiveTickMarkColor: Colors.grey[300],
            valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
            valueIndicatorColor: const Color(0xFF6750A4),
            valueIndicatorTextStyle: TextStyle(color: Colors.white, fontSize: 12.sp),
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            divisions: 3,
            onChanged: onChanged,
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final level in expertiseLevels)
                Text(
                  level.title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: level.sliderValue == value ? FontWeight.bold : FontWeight.normal,
                    color: level.sliderValue == value ? const Color(0xFF6750A4) : Colors.grey[600],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CustomThumbShape extends SliderComponentShape {
  static const double _indicatorRadius = 14;
  static const double _enabledThumbRadius = 10;
  static const double _disabledThumbRadius = 8;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(isEnabled ? _enabledThumbRadius.r : _disabledThumbRadius.r);
  }

  @override
  void paint(
      PaintingContext context,
      Offset center, {
        required Animation<double> activationAnimation,
        required Animation<double> enableAnimation,
        required bool isDiscrete,
        required TextPainter labelPainter,
        required RenderBox parentBox,
        required SliderThemeData sliderTheme,
        required TextDirection textDirection,
        required double value,
        required double textScaleFactor,
        required Size sizeWithOverflow,
      }) {
    final Canvas canvas = context.canvas;

    final fillPaint = Paint()
      ..color = const Color(0xFF6750A4)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.w
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, _indicatorRadius.r, fillPaint);
    canvas.drawCircle(center, (_indicatorRadius - 1).r, borderPaint);
  }
}
