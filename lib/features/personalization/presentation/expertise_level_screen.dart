import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/components/expertise_level_card.dart';
import '../../../utils/components/expertise_slider.dart';
import '../../../utils/components/personalization_header.dart';
import '../bloc/personalization_bloc.dart';
import '../bloc/personalization_event.dart';
import '../bloc/personalization_state.dart';
import '../models/expertise_level.dart';

class ExpertiseLevelScreen extends StatefulWidget {
  const ExpertiseLevelScreen({super.key});

  @override
  State<ExpertiseLevelScreen> createState() => _ExpertiseLevelScreenState();
}

class _ExpertiseLevelScreenState extends State<ExpertiseLevelScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedLevelId = 'novice';
  double _sliderValue = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateSelectedLevel(ExpertiseLevel level) {
    setState(() {
      _selectedLevelId = level.id;
      _sliderValue = level.sliderValue;
    });

    context.read<PersonalizationBloc>().add(
      SelectExpertiseLevel(level.id, level.sliderValue),
    );
  }

  void _onSliderChanged(double value) {
    setState(() {
      _sliderValue = value;

      final nearestLevel = expertiseLevels.reduce((current, next) {
        return (current.sliderValue - value).abs() <
            (next.sliderValue - value).abs()
            ? current
            : next;
      });

      _selectedLevelId = nearestLevel.id;
    });

    context.read<PersonalizationBloc>().add(
      SelectExpertiseLevel(_selectedLevelId, value),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PersonalizationBloc, PersonalizationState>(
      listener: (context, state) {
        if (state.status == PersonalizationStatus.completed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Personalization completed!')),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PersonalizationHeader(
                currentStep: 2,
                totalSteps: 2,
              ),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    children: [
                      SizedBox(height: 12.h),
                      ...expertiseLevels.map((level) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: ExpertiseLevelCard(
                            level: level,
                            isSelected: _selectedLevelId == level.id,
                            onTap: () => _updateSelectedLevel(level),
                          ),
                        );
                      }).toList(),
                      SizedBox(height: 15.h),
                      Text(
                        'Adjust your Science meter',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 18.sp,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ExpertiseSlider(
                        value: _sliderValue,
                        onChanged: _onSliderChanged,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
