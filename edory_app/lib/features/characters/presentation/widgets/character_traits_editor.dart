// lib/features/characters/presentation/widgets/character_traits_editor.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../domain/entities/character_traits.dart';

class CharacterTraitsEditor extends StatelessWidget {
  const CharacterTraitsEditor({
    super.key,
    required this.traits,
    required this.onTraitsChanged,
  });

  final CharacterTraits traits;
  final Function(CharacterTraits) onTraitsChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildTraitSlider(
          'Mut', 
          '🦁', 
          traits.courage, 
          (value) => onTraitsChanged(traits.copyWith(courage: value)),
          ModernDesignSystem.redGradient,
        ),
        const SizedBox(height: 16),
        _buildTraitSlider(
          'Kreativität', 
          '🎨', 
          traits.creativity, 
          (value) => onTraitsChanged(traits.copyWith(creativity: value)),
          ModernDesignSystem.orangeGradient,
        ),
        const SizedBox(height: 16),
        _buildTraitSlider(
          'Hilfsbereitschaft', 
          '🤝', 
          traits.helpfulness, 
          (value) => onTraitsChanged(traits.copyWith(helpfulness: value)),
          ModernDesignSystem.greenGradient,
        ),
        const SizedBox(height: 16),
        _buildTraitSlider(
          'Humor', 
          '😄', 
          traits.humor, 
          (value) => onTraitsChanged(traits.copyWith(humor: value)),
          ModernDesignSystem.primaryGradient,
        ),
        const SizedBox(height: 16),
        _buildTraitSlider(
          'Weisheit', 
          '🦉', 
          traits.wisdom, 
          (value) => onTraitsChanged(traits.copyWith(wisdom: value)),
          const LinearGradient(colors: [ModernDesignSystem.pastelPurple, Color(0xFF9C88FF)]),
        ),
        const SizedBox(height: 16),
        _buildTraitSlider(
          'Neugier', 
          '🔍', 
          traits.curiosity, 
          (value) => onTraitsChanged(traits.copyWith(curiosity: value)),
          ModernDesignSystem.primaryGradient,
        ),
        const SizedBox(height: 16),
        _buildTraitSlider(
          'Empathie', 
          '❤️', 
          traits.empathy, 
          (value) => onTraitsChanged(traits.copyWith(empathy: value)),
          ModernDesignSystem.redGradient,
        ),
        const SizedBox(height: 16),
        _buildTraitSlider(
          'Ausdauer', 
          '💪', 
          traits.persistence, 
          (value) => onTraitsChanged(traits.copyWith(persistence: value)),
          ModernDesignSystem.greenGradient,
        ),
      ],
    );
  }

  Widget _buildTraitSlider(
    String name,
    String emoji,
    int value,
    Function(int) onChanged,
    LinearGradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradient.colors.first.withOpacity(0.1),
            gradient.colors.last.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: gradient.colors.first.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: ModernDesignSystem.primaryTextColor,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: gradient.colors.first,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$value%',
                  style: const TextStyle(
                    color: ModernDesignSystem.whiteTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 8,
              activeTrackColor: gradient.colors.first,
              inactiveTrackColor: gradient.colors.first.withOpacity(0.2),
              thumbColor: gradient.colors.first,
              overlayColor: gradient.colors.first.withOpacity(0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: (newValue) => onChanged(newValue.round()),
            ),
          ),
        ],
      ),
    );
  }
}
