import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/components/goal_card.dart';
import '../../../utils/components/personalization_header.dart';
import '../bloc/personalization_bloc.dart';
import '../bloc/personalization_event.dart';
import '../bloc/personalization_state.dart';
import '../models/science_goal.dart';
import 'expertise_level_screen.dart';


class GoalSelectionScreen extends StatelessWidget {
  const GoalSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PersonalizationBloc, PersonalizationState>(
      listener: (context, state) {
        if (state.status == PersonalizationStatus.goalsSelected) {
          // Navigate to the next screen
          Navigator.push(
            context, 
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => const ExpertiseLevelScreen(),
              transitionDuration: const Duration(milliseconds: 400),
              transitionsBuilder: (_, animation, __, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                  )),
                  child: child,
                );
              },
            ),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const PersonalizationHeader(
                currentStep: 1,
                totalSteps: 3,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Text(
                  'What is your Science goal?',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  itemCount: scienceGoals.length,
                  itemBuilder: (context, index) {
                    final goal = scienceGoals[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GoalCard(
                        goal: goal,
                        onTap: () {
                          context.read<PersonalizationBloc>().add(
                            SelectScienceGoal(goal.id),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}