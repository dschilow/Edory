// lib/features/stories/presentation/widgets/story_generation_result.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../core/services/openai_service.dart';

/// Story Generation Result Widget - Zeigt generierte Geschichten an
class StoryGenerationResultWidget extends StatelessWidget {
  final StoryGenerationResult result;
  
  const StoryGenerationResultWidget({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    return iOSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: result.isAiGenerated 
                      ? ModernDesignSystem.accentGreen.withOpacity(0.1)
                      : ModernDesignSystem.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSmall),
                ),
                child: Icon(
                  result.isAiGenerated ? Icons.auto_awesome : Icons.warning,
                  color: result.isAiGenerated ? ModernDesignSystem.accentGreen : ModernDesignSystem.accentOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: ModernDesignSystem.spacing12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.isAiGenerated ? 'KI-Geschichte erstellt' : 'Fallback-Geschichte',
                      style: ModernDesignSystem.title3.copyWith(
                        color: ModernDesignSystem.textPrimary,
                      ),
                    ),
                    Text(
                      'mit ${result.model}',
                      style: ModernDesignSystem.footnote.copyWith(
                        color: ModernDesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernDesignSystem.spacing20),
          
          // Story Content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ModernDesignSystem.spacing16),
            decoration: BoxDecoration(
              color: ModernDesignSystem.backgroundTertiary,
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
            ),
            child: SelectableText(
              result.content,
              style: ModernDesignSystem.body.copyWith(
                height: 1.6,
                color: ModernDesignSystem.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: ModernDesignSystem.spacing16),
          
          // Story Info
          Container(
            padding: const EdgeInsets.all(ModernDesignSystem.spacing12),
            decoration: BoxDecoration(
              color: ModernDesignSystem.systemGray6,
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSmall),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem('Charakter', result.settings.characterName),
                    _buildInfoItem('Genre', result.settings.genre),
                  ],
                ),
                const SizedBox(height: ModernDesignSystem.spacing8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem('Länge', result.settings.length.displayName),
                    _buildInfoItem('Alter', '${result.settings.targetAge} Jahre'),
                  ],
                ),
                if (result.tokensUsed > 0) ...[
                  const SizedBox(height: ModernDesignSystem.spacing8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem('Tokens', '${result.tokensUsed}'),
                      _buildInfoItem('Erstellt', _formatTime(result.generatedAt)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: ModernDesignSystem.spacing16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: iOSButton(
                  text: 'Speichern',
                  onPressed: () {
                    // TODO: Save story
                  },
                  isPrimary: true,
                  icon: const Icon(Icons.bookmark, color: Colors.white),
                ),
              ),
              const SizedBox(width: ModernDesignSystem.spacing12),
              Expanded(
                child: iOSButton(
                  text: 'Teilen',
                  onPressed: () {
                    // TODO: Share story
                  },
                  icon: const Icon(Icons.share),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate()
     .fadeIn(duration: const Duration(milliseconds: 600))
     .slideY(begin: 0.2, end: 0);
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ModernDesignSystem.caption2.copyWith(
            color: ModernDesignSystem.tertiaryLabel,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: ModernDesignSystem.caption1.copyWith(
            color: ModernDesignSystem.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Jetzt';
    } else if (difference.inMinutes < 60) {
      return 'vor ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'vor ${difference.inHours}h';
    } else {
      return 'vor ${difference.inDays}d';
    }
  }
}