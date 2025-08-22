// lib/features/stories/presentation/widgets/story_generation_result.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/gradient_card.dart';
import '../../domain/entities/story.dart';
import '../pages/story_display_page.dart';

/// Story Generation Result Widget für Avatales
/// Displays the generated story with actions and animations
class StoryGenerationResult extends StatefulWidget {
  const StoryGenerationResult({
    super.key,
    required this.story,
    this.onRegeneratePressed,
    this.onSavePressed,
    this.onSharePressed,
    this.showFullContent = false,
  });

  final Story story;
  final VoidCallback? onRegeneratePressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onSharePressed;
  final bool showFullContent;

  @override
  State<StoryGenerationResult> createState() => _StoryGenerationResultState();
}

class _StoryGenerationResultState extends State<StoryGenerationResult>
    with TickerProviderStateMixin {
  
  late AnimationController _appearController;
  late AnimationController _sparkleController;
  late AnimationController _textController;
  
  bool _isExpanded = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    
    _appearController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _startAnimations();
  }

  @override
  void dispose() {
    _appearController.dispose();
    _sparkleController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _appearController.forward();
    _sparkleController.repeat();
    
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _appearController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_appearController.value * 0.2),
          child: Opacity(
            opacity: _appearController.value,
            child: _buildContent(),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success Header with Animation
          _buildSuccessHeader()
              .animate(controller: _appearController)
              .slideY(begin: -0.3, duration: 600.ms)
              .fadeIn(),
          
          const SizedBox(height: 20),
          
          // Story Preview Card
          _buildStoryPreviewCard()
              .animate(controller: _textController)
              .slideY(begin: 0.3, duration: 800.ms, curve: Curves.elasticOut)
              .fadeIn(delay: 200.ms),
          
          const SizedBox(height: 20),
          
          // Story Metadata
          _buildStoryMetadata()
              .animate(controller: _textController)
              .slideX(begin: -0.2, duration: 600.ms, delay: 400.ms)
              .fadeIn(),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          _buildActionButtons()
              .animate(controller: _textController)
              .slideY(begin: 0.2, duration: 600.ms, delay: 600.ms)
              .fadeIn(),
        ],
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Sparkle Background
        AnimatedBuilder(
          animation: _sparkleController,
          builder: (context, child) {
            return CustomPaint(
              painter: _SparklePainter(
                animationValue: _sparkleController.value,
              ),
              size: const Size(double.infinity, 60),
            );
          },
        ),
        
        // Success Content
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: ModernDesignSystem.greenGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: ModernDesignSystem.pastelGreen.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_stories,
                color: Colors.white,
                size: 24,
              ),
            )
                .animate(controller: _appearController)
                .scale(delay: 300.ms, duration: 600.ms, curve: Curves.elasticOut),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Geschichte erstellt! ✨',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: ModernDesignSystem.primaryTextColor,
                    ),
                  ),
                  Text(
                    'Deine magische Geschichte ist bereit',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ModernDesignSystem.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStoryPreviewCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Story Header
          _buildStoryHeader(),
          
          // Story Content Preview
          _buildStoryContentPreview(),
          
          // Expand/Collapse Toggle
          _buildExpandToggle(),
        ],
      ),
    );
  }

  Widget _buildStoryHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: ModernDesignSystem.primaryGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            widget.story.isAiGenerated ? Icons.auto_awesome : Icons.edit,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.story.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              widget.story.genre,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryContentPreview() {
    final previewLength = _isExpanded || widget.showFullContent ? null : 300;
    final displayContent = previewLength != null && 
                          widget.story.content.length > previewLength
        ? '${widget.story.content.substring(0, previewLength)}...'
        : widget.story.content;

    return Container(
      constraints: BoxConstraints(
        maxHeight: _isExpanded || widget.showFullContent ? double.infinity : 200,
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: SelectableText(
            displayContent,
            key: ValueKey(_isExpanded),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.6,
              color: ModernDesignSystem.primaryTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandToggle() {
    if (widget.showFullContent || widget.story.content.length <= 300) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _isExpanded = !_isExpanded);
            if (_isExpanded) {
              Future.delayed(const Duration(milliseconds: 100), () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              });
            }
          },
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: ModernDesignSystem.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  _isExpanded ? 'Weniger anzeigen' : 'Mehr anzeigen',
                  style: TextStyle(
                    color: ModernDesignSystem.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryMetadata() {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _buildMetadataChip(
          icon: Icons.schedule,
          label: '${widget.story.calculatedReadingTime} Min.',
          color: ModernDesignSystem.primaryOrange,
        ),
        _buildMetadataChip(
          icon: Icons.person,
          label: widget.story.characterName,
          color: ModernDesignSystem.pastelBlue,
        ),
        _buildMetadataChip(
          icon: Icons.child_care,
          label: '${widget.story.targetAge}+ Jahre',
          color: ModernDesignSystem.pastelGreen,
        ),
        if (widget.story.learningObjectives.isNotEmpty)
          _buildMetadataChip(
            icon: Icons.lightbulb_outline,
            label: '${widget.story.learningObjectives.length} Lernziele',
            color: ModernDesignSystem.pastelPurple,
          ),
        if (widget.story.isAiGenerated)
          _buildMetadataChip(
            icon: Icons.auto_awesome,
            label: 'KI-Generiert',
            color: ModernDesignSystem.primaryColor,
          ),
      ],
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary Action - Read Story
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _readStory,
            icon: const Icon(Icons.menu_book),
            label: const Text('Geschichte lesen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernDesignSystem.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: ModernDesignSystem.primaryColor.withOpacity(0.3),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Secondary Actions
        Row(
          children: [
            // Regenerate
            if (widget.onRegeneratePressed != null)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onRegeneratePressed,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Neu generieren'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            
            if (widget.onRegeneratePressed != null) const SizedBox(width: 12),
            
            // Save
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onSavePressed ?? _saveStory,
                icon: const Icon(Icons.bookmark),
                label: const Text('Speichern'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernDesignSystem.pastelGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Share
            ElevatedButton(
              onPressed: widget.onSharePressed ?? _shareStory,
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernDesignSystem.pastelBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(48, 48),
              ),
              child: const Icon(Icons.share, size: 20),
            ),
          ],
        ),
      ],
    );
  }

  // Action Methods
  void _readStory() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
            StoryDisplayPage(story: widget.story),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _saveStory() {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.bookmark,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text('Geschichte "${widget.story.title}" gespeichert!'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _shareStory() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.share,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text('Geschichte "${widget.story.title}" wird geteilt...'),
          ],
        ),
        backgroundColor: ModernDesignSystem.pastelBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

/// Custom Painter für Sparkle-Effekt
class _SparklePainter extends CustomPainter {
  final double animationValue;

  const _SparklePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ModernDesignSystem.primaryColor.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    // Create sparkle effect
    final sparkles = [
      Offset(size.width * 0.2, size.height * 0.3),
      Offset(size.width * 0.4, size.height * 0.7),
      Offset(size.width * 0.6, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.6),
    ];

    for (int i = 0; i < sparkles.length; i++) {
      final opacity = (animationValue + (i * 0.25)) % 1.0;
      final sparkleSize = 2.0 + (opacity * 3.0);
      
      paint.color = ModernDesignSystem.primaryColor.withOpacity(
        (0.5 - (opacity - 0.5).abs()) * 0.6,
      );
      
      canvas.drawCircle(sparkles[i], sparkleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}