// lib/features/characters/presentation/widgets/character_traits_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../domain/entities/character_traits.dart';

class CharacterTraitsWidget extends StatelessWidget {
  const CharacterTraitsWidget({
    super.key,
    required this.traits,
    this.showLabels = true,
    this.compact = false,
  });

  final CharacterTraits traits;
  final bool showLabels;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final traitsList = [
      TraitData('Mut', traits.courage, '🦁', ModernDesignSystem.redGradient),
      TraitData('Kreativität', traits.creativity, '🎨', ModernDesignSystem.orangeGradient),
      TraitData('Hilfsbereitschaft', traits.helpfulness, '🤝', ModernDesignSystem.greenGradient),
      TraitData('Humor', traits.humor, '😄', ModernDesignSystem.primaryGradient),
      TraitData('Weisheit', traits.wisdom, '🦉', const LinearGradient(
        colors: [ModernDesignSystem.pastelPurple, Color(0xFF9C88FF)],
      )),
      TraitData('Neugier', traits.curiosity, '🔍', ModernDesignSystem.primaryGradient),
      TraitData('Empathie', traits.empathy, '❤️', ModernDesignSystem.redGradient),
      TraitData('Ausdauer', traits.persistence, '💪', ModernDesignSystem.greenGradient),
    ];

    if (compact) {
      return _buildCompactView(context, traitsList);
    }

    return _buildFullView(context, traitsList);
  }

  Widget _buildFullView(BuildContext context, List<TraitData> traitsList) {
    return Container(
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
        border: Border.all(color: Colors.black.withOpacity(0.08), width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '⚡',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Charaktereigenschaften',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: ModernDesignSystem.primaryTextColor,
                      ),
                    ),
                    Text(
                      'Durchschnitt: ${traits.averageValue.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ModernDesignSystem.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...traitsList.asMap().entries.map((entry) {
            final index = entry.key;
            final trait = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTraitBar(context, trait)
                  .animate(delay: (index * 100).ms)
                  .slideX(begin: -0.3, duration: 600.ms)
                  .fadeIn(duration: 600.ms),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCompactView(BuildContext context, List<TraitData> traitsList) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: traitsList.take(4).map((trait) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(
                children: [
                  Text(trait.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: trait.value / 100,
                    backgroundColor: Colors.black.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation(trait.gradient.colors.first),
                    minHeight: 4,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trait.value.toString(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: ModernDesignSystem.secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTraitBar(BuildContext context, TraitData trait) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(trait.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  trait.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ModernDesignSystem.primaryTextColor,
                  ),
                ),
              ],
            ),
            Text(
              '${trait.value}/100',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: trait.gradient.colors.first,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: trait.value / 100,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(trait.gradient.colors.first),
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }
}

class TraitData {
  const TraitData(this.name, this.value, this.emoji, this.gradient);
  
  final String name;
  final int value;
  final String emoji;
  final LinearGradient gradient;
}
