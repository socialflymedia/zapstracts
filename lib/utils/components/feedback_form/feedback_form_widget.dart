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
  String? _mostUsedMode;
  double _summaryQualityRating = 3.0;
  double _summaryModesUsefulnessRating = 3.0;
  String? _languageLevelAppropriate;
  String? _errorsNoticed;
  final TextEditingController _errorsSpecificationController = TextEditingController();
  String? _mostValuableFeature;
  final TextEditingController _otherValuableFeatureController = TextEditingController();
  String? _wouldRecommend;
  final TextEditingController _whyNotRecommendController = TextEditingController();
  double _overallExperienceRating = 3.0;
  final TextEditingController _additionalCommentsController = TextEditingController();
  List<String> _improvementSuggestions = [];
  final TextEditingController _otherImprovementController = TextEditingController();

  @override
  void dispose() {
    _errorsSpecificationController.dispose();
    _otherValuableFeatureController.dispose();
    _whyNotRecommendController.dispose();
    _additionalCommentsController.dispose();
    _otherImprovementController.dispose();
    super.dispose();
  }

  bool get _isFormValid =>
      _mostUsedMode != null &&
          _languageLevelAppropriate != null &&
          _errorsNoticed != null &&
          _mostValuableFeature != null &&
          _wouldRecommend != null;

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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMostUsedModeSection(),
            const SizedBox(height: 24),
            _buildSliderSection(
              title: '2. How satisfied are you with the quality of the summaries?',
              subtitle: '(1 - Not Satisfied to 5 - Very Satisfied)',
              value: _summaryQualityRating,
              onChanged: (value) => setState(() => _summaryQualityRating = value),
            ),
            const SizedBox(height: 24),
            _buildSliderSection(
              title: '3. How useful did you find the summary modes for personalising the scientific papers?',
              subtitle: '(1 - Not useful to 5 - Very useful)',
              value: _summaryModesUsefulnessRating,
              onChanged: (value) => setState(() => _summaryModesUsefulnessRating = value),
            ),
            const SizedBox(height: 24),
            _buildRadioSection(
              title: '4. Was the language level in your selected mode appropriate for your understanding?',
              options: ['Yes', 'No'],
              selectedValue: _languageLevelAppropriate,
              onChanged: (value) => setState(() => _languageLevelAppropriate = value),
            ),
            const SizedBox(height: 24),
            _buildErrorsSection(),
            const SizedBox(height: 24),
            _buildMostValuableFeatureSection(),
            const SizedBox(height: 24),
            _buildRecommendationSection(),
            const SizedBox(height: 24),
            _buildSliderSection(
              title: '8. Please rate your overall experience.',
              subtitle: '(1 - Bad to 5 - Excellent)',
              value: _overallExperienceRating,
              onChanged: (value) => setState(() => _overallExperienceRating = value),
            ),
            const SizedBox(height: 24),
            _buildAdditionalCommentsSection(),
            const SizedBox(height: 24),
            _buildImprovementSuggestionsSection(),
            const SizedBox(height: 24),
            _buildActionButtons(),
          ],
        ),
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
            const Expanded(
              child: Text(
                'Thank you for using Zapstracts!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6750A4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Please help us improve by providing your feedback below.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildMostUsedModeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. Which summary mode did you use most often?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...['Novice', 'Learning', 'Student'].map((mode) =>
            RadioListTile<String>(
              title: Text(mode),
              value: mode,
              groupValue: _mostUsedMode,
              onChanged: (value) => setState(() => _mostUsedMode = value),
              contentPadding: EdgeInsets.zero,
            ),
        ),
      ],
    );
  }

  Widget _buildSliderSection({
    required String title,
    required String subtitle,
    required double value,
    required Function(double) onChanged,
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
          children: [
            const Text('1', style: TextStyle(fontSize: 12)),
            Expanded(
              child: Slider(
                value: value,
                min: 1.0,
                max: 5.0,
                divisions: 4,
                label: value.round().toString(),
                onChanged: onChanged,
                activeColor: const Color(0xFF6750A4),
              ),
            ),
            const Text('5', style: TextStyle(fontSize: 12)),
          ],
        ),
        Center(
          child: Text(
            value.round().toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6750A4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioSection({
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onChanged,
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
        const SizedBox(height: 12),
        ...options.map((option) =>
            RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: selectedValue,
              onChanged: onChanged,
              contentPadding: EdgeInsets.zero,
            ),
        ),
      ],
    );
  }

  Widget _buildErrorsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5. Did you notice any errors or inaccuracies in the summaries?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...['Yes', 'No'].map((option) =>
            RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _errorsNoticed,
              onChanged: (value) => setState(() => _errorsNoticed = value),
              contentPadding: EdgeInsets.zero,
            ),
        ),
        if (_errorsNoticed == 'Yes') ...[
          const SizedBox(height: 12),
          const Text(
            'If yes, please specify:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _errorsSpecificationController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Please describe the errors you noticed...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMostValuableFeatureSection() {
    final features = [
      'Different summary modes',
      'Conciseness of summaries',
      'Simplicity of language',
      'Other'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '6. Which feature did you find most valuable?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...features.map((feature) =>
            RadioListTile<String>(
              title: Text(feature),
              value: feature,
              groupValue: _mostValuableFeature,
              onChanged: (value) => setState(() => _mostValuableFeature = value),
              contentPadding: EdgeInsets.zero,
            ),
        ),
        if (_mostValuableFeature == 'Other') ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _otherValuableFeatureController,
              decoration: const InputDecoration(
                hintText: 'Please specify...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRecommendationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '7. Would you recommend Zapstracts to others?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...['Yes', 'No'].map((option) =>
            RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _wouldRecommend,
              onChanged: (value) => setState(() => _wouldRecommend = value),
              contentPadding: EdgeInsets.zero,
            ),
        ),
        if (_wouldRecommend == 'No') ...[
          const SizedBox(height: 12),
          const Text(
            'If no, why not? What can we do to improve this?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _whyNotRecommendController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Please tell us how we can improve...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAdditionalCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '9. Any additional comments or suggestions?',
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
            controller: _additionalCommentsController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Share any additional thoughts...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImprovementSuggestionsSection() {
    final improvements = [
      'Add more summary modes for greater personalization',
      'Improve summary accuracy',
      'Make summaries shorter',
      'Make summaries longer/more detailed',
      'Provide summaries in other languages',
      'Enhance the clarity of scientific terms',
      'Allow direct export of summaries (PDF, Word, etc.)',
      'Add audio summaries',
      'Provide summary figures (charts/diagrams)',
      'Make navigation in the app easier',
      'Offer more examples or tutorials on using modes',
      'Other'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '10. How can Zapstracts improve?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '(Select all improvements you would like to see)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        ...improvements.map((improvement) =>
            CheckboxListTile(
              title: Text(
                improvement,
                style: const TextStyle(fontSize: 14),
              ),
              value: _improvementSuggestions.contains(improvement),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _improvementSuggestions.add(improvement);
                  } else {
                    _improvementSuggestions.remove(improvement);
                  }
                });
              },
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
        ),
        if (_improvementSuggestions.contains('Other')) ...[
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: _otherImprovementController,
              decoration: const InputDecoration(
                hintText: 'Please specify other improvements...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(12),
              ),
            ),
          ),
        ],
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
      mostUsedMode: _mostUsedMode ?? '',
      summaryQualityRating: _summaryQualityRating.round(),
      summaryModesUsefulnessRating: _summaryModesUsefulnessRating.round(),
      languageLevelAppropriate: _languageLevelAppropriate ?? '',
      errorsNoticed: _errorsNoticed ?? '',
      errorsSpecification: _errorsSpecificationController.text.trim(),
      mostValuableFeature: _mostValuableFeature ?? '',
      otherValuableFeature: _otherValuableFeatureController.text.trim(),
      wouldRecommend: _wouldRecommend ?? '',
      whyNotRecommend: _whyNotRecommendController.text.trim(),
      overallExperienceRating: _overallExperienceRating.round(),
      additionalComments: _additionalCommentsController.text.trim(),
      improvementSuggestions: _improvementSuggestions,
      otherImprovement: _otherImprovementController.text.trim(),
      submittedAt: DateTime.now(),
    );

    context.read<HomeBloc>().add(SubmitFeedback(feedback));
  }
}

// Updated FeedbackModel to match new structure

