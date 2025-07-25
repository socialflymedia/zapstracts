import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../features/homeScreen/bloc/home_bloc.dart';
import '../../../features/homeScreen/bloc/home_event.dart';
import '../../../features/homeScreen/model/feedback_form_modal.dart';


class FeedbackFormWidget extends StatefulWidget {
  const FeedbackFormWidget({super.key});

  @override
  State<FeedbackFormWidget> createState() => _FeedbackFormWidgetState();
}

class _FeedbackFormWidgetState extends State<FeedbackFormWidget> {
  int _uiRating = 0;
  int _summaryAccuracyRating = 0;
  int _overallExperienceRating = 0;
  final TextEditingController _commentsController = TextEditingController();

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _uiRating > 0 &&
          _summaryAccuracyRating > 0 &&
          _overallExperienceRating > 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 24),
          _buildRatingSection(
            title: 'How would you rate the app\'s user interface?',
            subtitle: 'Design, ease of use, and navigation',
            rating: _uiRating,
            onRatingChanged: (rating) => setState(() => _uiRating = rating),
          ),
          const SizedBox(height: 24),
          _buildRatingSection(
            title: 'How accurate are the research summaries?',
            subtitle: 'Quality and relevance of summarized content',
            rating: _summaryAccuracyRating,
            onRatingChanged: (rating) => setState(() => _summaryAccuracyRating = rating),
          ),
          const SizedBox(height: 24),
          _buildRatingSection(
            title: 'Overall experience with the app',
            subtitle: 'General satisfaction and likelihood to recommend',
            rating: _overallExperienceRating,
            onRatingChanged: (rating) => setState(() => _overallExperienceRating = rating),
          ),
          const SizedBox(height: 24),
          _buildCommentsSection(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6750A4).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.feedback,
                color: Color(0xFF6750A4),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Your Feedback Matters',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6750A4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Help us improve your experience by sharing your thoughts on the app.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection({
    required String title,
    required String subtitle,
    required int rating,
    required Function(int) onRatingChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () => onRatingChanged(index + 1),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                child: Icon(
                  index < rating ? Icons.star : Icons.star_border,
                  color: index < rating ? Colors.amber : Colors.grey[400],
                  size: 28,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Comments (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _commentsController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Share any suggestions or thoughts...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              context.read<HomeBloc>().add(DismissFeedbackForm());
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF6750A4)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Maybe Later',
              style: TextStyle(
                color: Color(0xFF6750A4),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: _isFormValid ? _submitFeedback : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6750A4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Submit Feedback',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitFeedback() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final feedback = FeedbackModel(
      userId: userId,
      uiRating: _uiRating,
      summaryAccuracyRating: _summaryAccuracyRating,
      overallExperienceRating: _overallExperienceRating,
      additionalComments: _commentsController.text.trim(),
      submittedAt: DateTime.now(),
    );

    context.read<HomeBloc>().add(SubmitFeedback(feedback));
  }
}