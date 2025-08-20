// lib/features/learning/presentation/pages/learning_objective_detail_page.dart
import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';

class LearningObjectiveDetailPage extends StatelessWidget {
  const LearningObjectiveDetailPage({
    super.key,
    required this.objectiveId,
  });

  final String objectiveId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Lernziel',
      subtitle: 'ID: $objectiveId',
      body: const Center(
        child: Text('Learning Objective Detail Page - Coming Soon!'),
      ),
    );
  }
}
