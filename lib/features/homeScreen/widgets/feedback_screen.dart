import 'package:flutter/material.dart';

import '../../../utils/components/feedback_form/feedback_form_widget.dart';

class FeedbackScreenWidget extends StatelessWidget {
  const FeedbackScreenWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildFeedbackHeader(),
                  const SizedBox(height: 24),
                  const FeedbackFormWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6750A4).withOpacity(0.1),
            const Color(0xFF6750A4).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6750A4).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration,
              color: Color(0xFF6750A4),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Thank you for exploring!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6750A4),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You\'ve viewed 3 research summaries. Your feedback helps us improve the experience for everyone.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
