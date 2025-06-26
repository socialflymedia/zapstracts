import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapstract/features/homeScreen/home_screen.dart';
import 'package:zapstract/features/personalization/presentation/expertise_level_screen.dart';
import 'package:zapstract/features/personalization/presentation/topic_selection_screen.dart';

import '../../features/personalization/bloc/personalization_bloc.dart';
import '../../features/personalization/bloc/personalization_event.dart';
import '../../features/personalization/bloc/personalization_state.dart';

class PersonalizationHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const PersonalizationHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });


  @override
  @override
  Widget build(BuildContext context) {


    return BlocConsumer<PersonalizationBloc, PersonalizationState>(
      listener: (context, state) {
        if (state.status == PersonalizationStatus.completed) {
          print("here");
          // Navigator.pushReplacement(
          //   context,
          //   MaterialPageRoute(builder: (context) => HomeScreen()),
          // );// or your home route
        }

      },
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(22.w, 8.h, 22.w, 0.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Personalize Your Account',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  TextButton(
                    onPressed: () {
                         print(state.status.toString());

                      if(state.status == PersonalizationStatus.goalsSelected) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>ExpertiseLevelScreen()),
                        );
                      } else if (state.status == PersonalizationStatus.expertiseLevelSelected) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => TopicSelectionScreen()),
                        );
                      } else if (state.status == PersonalizationStatus.topicsSelected) {
                        context.read<PersonalizationBloc>().add(CompletePersonalization());
                      }

                      // context.read<PersonalizationBloc>().add(SkipPersonalization());
                      // ScaffoldMessenger.of(context).showSnackBar(
                      //   const SnackBar(content: Text('Personalization skipped')),
                      // );
                    },
                    child: Text(
                       state.slidertext,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w500,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'Stay informed with updates that resonate with your preferences.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: _buildProgressBar(),
            ),
            SizedBox(height: 16.h),
          ],
        );
      },
    );
  }


  Widget _buildProgressBar() {
    final double progress = currentStep / totalSteps;

    return Stack(
      children: [
        Container(
          height: 3.h,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFF6750A4),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
      ],
    );
  }
}
