// lib/features/home/presentation/widgets/recent_stories_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/gradient_card.dart';
import '../../../features/stories/domain/entities/story.dart';

/// Recent Stories Card Widget für die Avatales Homepage
/// Zeigt die zuletzt gelesenen/erstellten Geschichten in einer ansprechenden Card
class RecentStoriesCard extends StatefulWidget {
  const RecentStoriesCard({
    super.key,
    required this.stories,
    required this.onStoryTap,
    this.onCreateStoryTap,
    this.maxStories = 3,
  });

  final List<Story> stories;
  final Function(Story) onStoryTap;
  final VoidCallback? onCreateStoryTap;
  final int maxStories;

  @override
  State<RecentStoriesCard> createState() => _RecentStoriesCardState();
}

class _RecentStoriesCardState extends State<RecentStoriesCard>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) {
      return _buildEmptyState();
    }

    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 16),
          
          // Stories List
          SizedBox(
            height: 140,
            child: widget.stories.length == 1
                ? _buildSingleStory(widget.stories.first)
                : _buildStoriesCarousel(),
          ),
          
          if (widget.stories.length > 1) ...[
            const SizedBox(height: 12),
            _buildPageIndicator(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: ModernDesignSystem.primaryGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.auto_stories,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Letzte Geschichten',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${widget.stories.length} Geschichten bereit',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ModernDesignSystem.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    )
        .animate(controller: _animationController)
        .slideX(begin: -0.3, duration: 600.ms)
        .fadeIn();
  }

  Widget _buildSingleStory(Story story) {
    return _buildStoryCard(story, 0);
  }

  Widget _buildStoriesCarousel() {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) => setState(() => _currentPage = index),
      itemCount: widget.stories.take(widget.maxStories).length,
      itemBuilder: (context, index) {
        final story = widget.stories[index];
        return Padding(
          padding: const EdgeInsets.only(right: 16),
          child: _buildStoryCard(story, index),
        );
      },
    );
  }

  Widget _buildStoryCard(Story story, int index) {
    return GestureDetector(
      onTap: () => widget.onStoryTap(story),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getGenreColor(story.genre).withOpacity(0.1),
              _getGenreColor(story.genre).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getGenreColor(story.genre).withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Story Header
              Row(
                children: [
                  _buildGenreIcon(story.genre),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          story.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'mit ${story.characterName}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ModernDesignSystem.secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildReadTimeChip(story),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Story Preview
              Text(
                story.content,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.4,
                  color: ModernDesignSystem.secondaryTextColor,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Story Metadata
              Row(
                children: [
                  _buildMetadataChip(
                    icon: Icons.child_care,
                    text: '${story.targetAge}+',
                    color: ModernDesignSystem.pastelGreen,
                  ),
                  const SizedBox(width: 8),
                  _buildMetadataChip(
                    icon: Icons.auto_awesome,
                    text: story.isAiGenerated ? 'KI' : 'Custom',
                    color: story.isAiGenerated 
                        ? ModernDesignSystem.primaryColor
                        : ModernDesignSystem.primaryOrange,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: _getGenreColor(story.genre),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (index * 100).ms)
        .slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOutCubic)
        .fadeIn();
  }

  Widget _buildGenreIcon(String genre) {
    IconData iconData;
    Color color;
    
    switch (genre.toLowerCase()) {
      case 'abenteuer':
        iconData = Icons.explore;
        color = ModernDesignSystem.primaryColor;
        break;
      case 'freundschaft':
        iconData = Icons.favorite;
        color = ModernDesignSystem.pastelRed;
        break;
      case 'fantasy':
        iconData = Icons.auto_awesome;
        color = ModernDesignSystem.pastelPurple;
        break;
      case 'lernen':
        iconData = Icons.school;
        color = ModernDesignSystem.pastelGreen;
        break;
      case 'tiere':
        iconData = Icons.pets;
        color = ModernDesignSystem.primaryOrange;
        break;
      default:
        iconData = Icons.book;
        color = ModernDesignSystem.primaryColor;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        size: 16,
        color: color,
      ),
    );
  }

  Widget _buildReadTimeChip(Story story) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ModernDesignSystem.pastelBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernDesignSystem.pastelBlue.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 12,
            color: ModernDesignSystem.pastelBlue,
          ),
          const SizedBox(width: 4),
          Text(
            '${story.calculatedReadingTime} Min.',
            style: TextStyle(
              color: ModernDesignSystem.pastelBlue,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    if (widget.stories.length <= 1) return const SizedBox.shrink();
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.stories.take(widget.maxStories).length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: _currentPage == index ? 20 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? ModernDesignSystem.primaryColor
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    )
        .animate()
        .slideY(begin: 0.5, duration: 400.ms, delay: 600.ms)
        .fadeIn();
  }

  Widget _buildEmptyState() {
    return GradientCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ModernDesignSystem.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.auto_stories,
              size: 32,
              color: ModernDesignSystem.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          
          Text(
            'Noch keine Geschichten',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          Text(
            'Erstelle deine erste magische Geschichte mit deinen Avataren!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ModernDesignSystem.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          
          if (widget.onCreateStoryTap != null)
            ElevatedButton.icon(
              onPressed: widget.onCreateStoryTap,
              icon: const Icon(Icons.add),
              label: const Text('Erste Geschichte erstellen'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernDesignSystem.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    )
        .animate()
        .scale(duration: 600.ms, curve: Curves.elasticOut)
        .fadeIn();
  }

  Color _getGenreColor(String genre) {
    switch (genre.toLowerCase()) {
      case 'abenteuer':
        return ModernDesignSystem.primaryColor;
      case 'freundschaft':
        return ModernDesignSystem.pastelRed;
      case 'fantasy':
        return ModernDesignSystem.pastelPurple;
      case 'lernen':
        return ModernDesignSystem.pastelGreen;
      case 'tiere':
        return ModernDesignSystem.primaryOrange;
      case 'musik':
        return const Color(0xFFE91E63);
      case 'sport':
        return const Color(0xFF4CAF50);
      default:
        return ModernDesignSystem.primaryColor;
    }
  }
}

/// Recent Stories Card Variants
class RecentStoriesCardVariants {
  /// Compact version for smaller spaces
  static Widget compact({
    required List<Story> stories,
    required Function(Story) onStoryTap,
  }) {
    return Container(
      height: 100,
      child: RecentStoriesCard(
        stories: stories,
        onStoryTap: onStoryTap,
        maxStories: 2,
      ),
    );
  }

  /// Extended version with more stories
  static Widget extended({
    required List<Story> stories,
    required Function(Story) onStoryTap,
    VoidCallback? onCreateStoryTap,
  }) {
    return RecentStoriesCard(
      stories: stories,
      onStoryTap: onStoryTap,
      onCreateStoryTap: onCreateStoryTap,
      maxStories: 5,
    );
  }

  /// Favorites only
  static Widget favorites({
    required List<Story> stories,
    required Function(Story) onStoryTap,
  }) {
    final favoriteStories = stories.where((story) => story.isFavorite).toList();
    
    return RecentStoriesCard(
      stories: favoriteStories,
      onStoryTap: onStoryTap,
      maxStories: 3,
    );
  }
}