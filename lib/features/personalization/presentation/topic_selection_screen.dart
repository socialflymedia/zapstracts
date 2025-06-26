import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zapstract/features/homeScreen/home_screen.dart';

import '../../../utils/components/personalization_header.dart';
import '../../../utils/components/topic selection/topic_card.dart';
//import '../../../utils/components/topic_card.dart';
import '../bloc/personalization_bloc.dart';
import '../bloc/personalization_event.dart';
import '../bloc/personalization_state.dart';
import '../models/topic.dart';

class TopicSelectionScreen extends StatefulWidget {
  const TopicSelectionScreen({super.key});

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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

  void _toggleTopic(String topicId) {
    context.read<PersonalizationBloc>().add(ToggleTopic(topicId));
  }

  void _skipSelection() {
    context.read<PersonalizationBloc>().add(const CompletePersonalization());
    Navigator.of(context).pop();
  }

  void _continueWithSelection() {
    final state = context.read<PersonalizationBloc>().state;
    if (state.selectedTopicIds.isNotEmpty) {
      context.read<PersonalizationBloc>().add(const CompletePersonalization());
     // Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one topic to continue'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonalizationBloc, PersonalizationState>(
      listener: (context, state) {
        if (state.status == PersonalizationStatus.completed) {
          Navigator.pushReplacement(context,MaterialPageRoute(builder: (_)=> HomeScreen())); // or use your specific HomeScreen route
        }

      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: state.status == PersonalizationStatus.loading
            ? const Center(child: CircularProgressIndicator()) // 👈 Loader shown
            :
        Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PersonalizationHeader(
                      currentStep: 3,
                      totalSteps: 3,
                    ),
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ListView(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'What topics do you want to explore ?',
                                        style: TextStyle(
                                          fontSize: 24.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1F2937),
                                          height: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Optional Skip Button
                              ],
                            ),
                            SizedBox(height: 32.h),
                            Text(
                              'Choose precisely',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            SizedBox(height: 16.h),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12.w,
                                mainAxisSpacing: 12.h,
                                childAspectRatio: 2.5,
                              ),
                              itemCount: availableTopics.length,
                              itemBuilder: (context, index) {
                                final topic = availableTopics[index];
                                final isSelected = state.selectedTopicIds.contains(topic.id);

                                return TopicCard(
                                  topic: topic,
                                  isSelected: isSelected,
                                  onTap: () => _toggleTopic(topic.id),
                                );
                              },
                            ),
                            SizedBox(height: 100.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  bottom: 24.h,
                  right: 24.w,
                  child: GestureDetector(
                    onTap: _continueWithSelection,
                    child: Text(
                      "continue",
                      style: TextStyle(
                        color: const Color(0xFF4C3BCF),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}