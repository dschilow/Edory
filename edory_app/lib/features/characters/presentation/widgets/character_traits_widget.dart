// lib/features/characters/presentation/widgets/character_traits_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../domain/entities/character_traits.dart';

/// Professionelles Character Traits Widget - Behebt Overflow Probleme
/// Zeigt alle 10 Charaktereigenschaften mit modernem Design
class CharacterTraitsWidget extends StatelessWidget {
  const CharacterTraitsWidget({
    super.key,
    required this.traits,
    this.showLabels = true,
    this.compact = false,
    this.animated = true,
  });

  final CharacterTraits traits;
  final bool showLabels;
  final bool compact;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    // Alle 10 Charaktereigenschaften definiert
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
      TraitData('Intelligenz', traits.intelligence, '🧠', const LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
      )),
      TraitData('Freundlichkeit', traits.kindness, '🌟', const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
      )),
    ];

    if (compact) {
      return _buildCompactView(context, traitsList);
    }

    return _buildFullView(context, traitsList);
  }

  /// Vollständige Ansicht mit allen Details
  Widget _buildFullView(BuildContext context, List<TraitData> traitsList) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 600), // Verhindert overflow
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Verhindert overflow
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mit Statistiken
          Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Charaktereigenschaften',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: ModernDesignSystem.primaryTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          'Durchschnitt: ${traits.averageValue.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ModernDesignSystem.secondaryTextColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStrengthColor(traits.overallStrength),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${traits.overallStrength.emoji} ${traits.overallStrength.displayName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Traits Grid - Verhindert overflow
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 400 ? 2 : 1;
              return GridView.builder(
                shrinkWrap: true, // Wichtig: Verhindert overflow
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 4, // Kompakte Höhe
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: traitsList.length,
                itemBuilder: (context, index) {
                  final trait = traitsList[index];
                  Widget child = _buildTraitBar(context, trait);
                  
                  if (animated) {
                    child = child
                        .animate(delay: (index * 100).ms)
                        .slideX(begin: -0.3, duration: 600.ms)
                        .fadeIn(duration: 600.ms);
                  }
                  
                  return child;
                },
              );
            },
          ),

          if (showLabels) ...[
            const SizedBox(height: 16),
            _buildDominantTraitInfo(context),
          ],
        ],
      ),
    );
  }

  /// Kompakte Ansicht für kleine Räume
  Widget _buildCompactView(BuildContext context, List<TraitData> traitsList) {
    return Container(
      constraints: const BoxConstraints(maxHeight: 120), // Höhe begrenzen
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Eigenschaften',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${traits.averageValue.toStringAsFixed(0)}/100',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ModernDesignSystem.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Compact Traits - 2 Zeilen à 5 Traits
          Expanded(
            child: Column(
              children: [
                // Erste Zeile
                Expanded(
                  child: Row(
                    children: traitsList.take(5).map((trait) => 
                      Expanded(child: _buildCompactTrait(context, trait))
                    ).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                // Zweite Zeile
                Expanded(
                  child: Row(
                    children: traitsList.skip(5).take(5).map((trait) => 
                      Expanded(child: _buildCompactTrait(context, trait))
                    ).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Einzelner Trait Bar für Full View
  Widget _buildTraitBar(BuildContext context, TraitData trait) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Text(trait.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      trait.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: ModernDesignSystem.primaryTextColor,
                      ),
                    ),
                    Text(
                      '${trait.value}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _getValueColor(trait.value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: trait.value / 100,
                  backgroundColor: Colors.black.withOpacity(0.08),
                  valueColor: AlwaysStoppedAnimation(
                    trait.gradient is LinearGradient 
                        ? (trait.gradient as LinearGradient).colors.first
                        : ModernDesignSystem.primaryColor,
                  ),
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Einzelner Trait für Compact View
  Widget _buildCompactTrait(BuildContext context, TraitData trait) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(trait.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 2),
          Expanded(
            child: LinearProgressIndicator(
              value: trait.value / 100,
              backgroundColor: Colors.black.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation(
                trait.gradient is LinearGradient 
                    ? (trait.gradient as LinearGradient).colors.first
                    : ModernDesignSystem.primaryColor,
              ),
              minHeight: 3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            trait.value.toString(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: ModernDesignSystem.secondaryTextColor,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  /// Dominante Eigenschaft Info
  Widget _buildDominantTraitInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ModernDesignSystem.primaryColor.withOpacity(0.1),
            ModernDesignSystem.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ModernDesignSystem.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.star_rounded,
            color: ModernDesignSystem.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Stärkste Eigenschaft: ${traits.dominantTrait}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ModernDesignSystem.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Farbe basierend auf Charakterstärke
  Color _getStrengthColor(CharacterStrength strength) {
    switch (strength) {
      case CharacterStrength.legendary:
        return const Color(0xFFFFD700); // Gold
      case CharacterStrength.strong:
        return ModernDesignSystem.primaryColor;
      case CharacterStrength.balanced:
        return ModernDesignSystem.pastelGreen;
      case CharacterStrength.developing:
        return ModernDesignSystem.primaryOrange;
      case CharacterStrength.weak:
        return ModernDesignSystem.pastelRed;
    }
  }

  /// Farbe basierend auf Eigenschaftswert
  Color _getValueColor(int value) {
    if (value >= 80) return const Color(0xFF10B981); // Grün
    if (value >= 60) return const Color(0xFF3B82F6); // Blau
    if (value >= 40) return const Color(0xFFF59E0B); // Orange
    return const Color(0xFFEF4444); // Rot
  }
}