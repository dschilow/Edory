// lib/features/characters/presentation/widgets/character_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../domain/entities/character.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    super.key,
    required this.character,
    this.onTap,
    this.isSelectable = false,
    this.isSelected = false,
  });

  final Character character;
  final VoidCallback? onTap;
  final bool isSelectable;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.95),
              Colors.white.withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: ModernDesignSystem.primaryGradient.colors.first, width: 2)
              : Border.all(color: Colors.black.withOpacity(0.08), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Character Avatar
              _buildAvatar(),
              const SizedBox(height: 16),
              
              // Character Name
              Text(
                character.displayName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: ModernDesignSystem.primaryTextColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              
              // Character Stats
              Text(
                '${character.experienceCount} Geschichten • Level ${character.level}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ModernDesignSystem.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              if (character.isActive) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ModernDesignSystem.pastelGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '🔥 Aktiv',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: ModernDesignSystem.pastelGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              
              if (character.isPublic) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ModernDesignSystem.pastelBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '🌍 Öffentlich',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: ModernDesignSystem.pastelBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms, delay: 100.ms)
        .slideY(begin: 0.2, end: 0, duration: 600.ms, delay: 100.ms)
        .then()
        .shimmer(delay: 1000.ms, duration: 2000.ms);
  }

  Widget _buildAvatar() {
    // Create gradient based on character name
    final gradients = [
      ModernDesignSystem.redGradient,
      ModernDesignSystem.primaryGradient,
      ModernDesignSystem.greenGradient,
      ModernDesignSystem.orangeGradient,
      const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [ModernDesignSystem.pastelPurple, ModernDesignSystem.pastelPink],
      ),
    ];
    
    final gradientIndex = character.name.hashCode.abs() % gradients.length;
    final selectedGradient = gradients[gradientIndex];
    
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        gradient: selectedGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: selectedGradient.colors.first.withOpacity(0.3),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Center(
        child: Text(
          character.name.isNotEmpty ? character.name[0].toUpperCase() : '?',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: ModernDesignSystem.whiteTextColor,
          ),
        ),
      ),
    );
  }
}
