// lib/features/stories/presentation/pages/story_detail_page.dart
import 'package:flutter/material.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';

class StoryDetailPage extends StatelessWidget {
  const StoryDetailPage({
    super.key,
    required this.storyId,
  });

  final String storyId;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Geschichte',
      subtitle: 'ID: $storyId',
      body: const Center(
        child: Text('Story Detail Page - Coming Soon!'),
      ),
    );
  }
}
