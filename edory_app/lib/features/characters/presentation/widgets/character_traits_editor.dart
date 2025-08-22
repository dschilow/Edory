// lib/features/characters/presentation/widgets/character_traits_editor.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../domain/entities/character_traits.dart';

/// Professioneller Character Traits Editor
/// Ermöglicht die Bearbeitung aller 10 Charaktereigenschaften
class CharacterTraitsEditor extends StatefulWidget {
  const CharacterTraitsEditor({
    super.key,
    required this.initialTraits,
    required this.onChanged,
    this.maxPoints = 600, // Gesamtpunkte-Limit
    this.showPresets = true,
    this.animated = true,
  });

  final CharacterTraits initialTraits;
  final ValueChanged<CharacterTraits> onChanged;
  final int maxPoints;
  final bool showPresets;
  final bool animated;

  @override
  State<CharacterTraitsEditor> createState() => _CharacterTraitsEditorState();
}

class _CharacterTraitsEditorState extends State<CharacterTraitsEditor>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late CharacterTraits _currentTraits;
  
  // Individual Controllers für jede Eigenschaft
  late Map<String, double> _sliderValues;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _currentTraits = widget.initialTraits;
    _initializeSliderValues();
    
    if (widget.animated) {
      _animationController.forward();
    }
  }

  void _initializeSliderValues() {
    _sliderValues = {
      'courage': _currentTraits.courage.toDouble(),
      'creativity': _currentTraits.creativity.toDouble(),
      'helpfulness': _currentTraits.helpfulness.toDouble(),
      'humor': _currentTraits.humor.toDouble(),
      'wisdom': _currentTraits.wisdom.toDouble(),
      'curiosity': _currentTraits.curiosity.toDouble(),
      'empathy': _currentTraits.empathy.toDouble(),
      'persistence': _currentTraits.persistence.toDouble(),
      'intelligence': _currentTraits.intelligence.toDouble(),
      'kindness': _currentTraits.kindness.toDouble(),
    };
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateTraits() {
    final newTraits = CharacterTraits(
      courage: _sliderValues['courage']!.round(),
      creativity: _sliderValues['creativity']!.round(),
      helpfulness: _sliderValues['helpfulness']!.round(),
      humor: _sliderValues['humor']!.round(),
      wisdom: _sliderValues['wisdom']!.round(),
      curiosity: _sliderValues['curiosity']!.round(),
      empathy: _sliderValues['empathy']!.round(),
      persistence: _sliderValues['persistence']!.round(),
      intelligence: _sliderValues['intelligence']!.round(),
      kindness: _sliderValues['kindness']!.round(),
    );
    
    setState(() {
      _currentTraits = newTraits;
    });
    
    widget.onChanged(newTraits);
  }

  void _applyPreset(CharacterTraits preset) {
    setState(() {
      _sliderValues = {
        'courage': preset.courage.toDouble(),
        'creativity': preset.creativity.toDouble(),
        'helpfulness': preset.helpfulness.toDouble(),
        'humor': preset.humor.toDouble(),
        'wisdom': preset.wisdom.toDouble(),
        'curiosity': preset.curiosity.toDouble(),
        'empathy': preset.empathy.toDouble(),
        'persistence': preset.persistence.toDouble(),
        'intelligence': preset.intelligence.toDouble(),
        'kindness': preset.kindness.toDouble(),
      };
    });
    _updateTraits();
  }

  int get _totalPoints {
    return _sliderValues.values.map((v) => v.round()).reduce((a, b) => a + b);
  }

  bool get _isOverLimit => _totalPoints > widget.maxPoints;

  @override
  Widget build(BuildContext context) {
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mit Statistiken
          _buildHeader(),
          const SizedBox(height: 20),

          // Presets (optional)
          if (widget.showPresets) ...[
            _buildPresets(),
            const SizedBox(height: 24),
          ],

          // Traits Sliders
          _buildTraitSliders(),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Text('⚡', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Eigenschaften bearbeiten',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: ModernDesignSystem.primaryTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Punkte: $_totalPoints/${widget.maxPoints}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _isOverLimit 
                          ? ModernDesignSystem.pastelRed 
                          : ModernDesignSystem.secondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Ø ${_currentTraits.averageValue.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ModernDesignSystem.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Reset Button
        IconButton(
          onPressed: () => _applyPreset(widget.initialTraits),
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Zurücksetzen',
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey.shade100,
            foregroundColor: ModernDesignSystem.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPresets() {
    final presets = [
      _PresetData('Ausgewogen', CharacterTraits.neutral(), '⚖️', Colors.blue),
      _PresetData('Held', CharacterTraits.heroic(), '🦸', Colors.red),
      _PresetData('Künstler', CharacterTraits.creative(), '🎨', Colors.purple),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vorlagen',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: presets.map((preset) => 
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _buildPresetCard(preset),
              ),
            ).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPresetCard(_PresetData preset) {
    return GestureDetector(
      onTap: () => _applyPreset(preset.traits),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              preset.color.withOpacity(0.1),
              preset.color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: preset.color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(preset.emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              preset.name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: preset.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraitSliders() {
    final traits = [
      _TraitSliderData('courage', 'Mut', '🦁', ModernDesignSystem.redGradient),
      _TraitSliderData('creativity', 'Kreativität', '🎨', ModernDesignSystem.orangeGradient),
      _TraitSliderData('helpfulness', 'Hilfsbereitschaft', '🤝', ModernDesignSystem.greenGradient),
      _TraitSliderData('humor', 'Humor', '😄', ModernDesignSystem.primaryGradient),
      _TraitSliderData('wisdom', 'Weisheit', '🦉', const LinearGradient(
        colors: [ModernDesignSystem.pastelPurple, Color(0xFF9C88FF)],
      )),
      _TraitSliderData('curiosity', 'Neugier', '🔍', ModernDesignSystem.primaryGradient),
      _TraitSliderData('empathy', 'Empathie', '❤️', ModernDesignSystem.redGradient),
      _TraitSliderData('persistence', 'Ausdauer', '💪', ModernDesignSystem.greenGradient),
      _TraitSliderData('intelligence', 'Intelligenz', '🧠', const LinearGradient(
        colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
      )),
      _TraitSliderData('kindness', 'Freundlichkeit', '🌟', const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFEAB308)],
      )),
    ];

    return Column(
      children: traits.asMap().entries.map((entry) {
        final index = entry.key;
        final trait = entry.value;
        
        Widget slider = _buildTraitSlider(trait);
        
        if (widget.animated) {
          slider = slider
              .animate(delay: (index * 50).ms)
              .slideX(begin: -0.2, duration: 400.ms)
              .fadeIn(duration: 400.ms);
        }
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: slider,
        );
      }).toList(),
    );
  }

  Widget _buildTraitSlider(_TraitSliderData trait) {
    final value = _sliderValues[trait.key]!;
    final color = trait.gradient is LinearGradient 
        ? (trait.gradient as LinearGradient).colors.first
        : ModernDesignSystem.primaryColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Text(trait.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  trait.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  value.round().toString(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              thumbColor: color,
              overlayColor: color.withOpacity(0.2),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: (newValue) {
                setState(() {
                  _sliderValues[trait.key] = newValue;
                });
                _updateTraits();
              },
            ),
          ),
          
          // Labels
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('50', style: TextStyle(fontSize: 12, color: Colors.grey)),
              Text('100', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Balance Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _applyPreset(_currentTraits.balance()),
            icon: const Icon(Icons.balance_rounded),
            label: const Text('Ausbalancieren'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernDesignSystem.pastelBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Random Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _generateRandomTraits,
            icon: const Icon(Icons.shuffle_rounded),
            label: const Text('Zufällig'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _generateRandomTraits() {
    final random = DateTime.now().microsecond;
    final traits = <String, double>{};
    
    // Generiere Zufallswerte mit leichter Gewichtung zur Mitte
    for (final key in _sliderValues.keys) {
      final base = 50 + (random % 41) - 20; // 30-70 Basis
      final variation = (random % 31) - 15; // ±15 Variation
      traits[key] = (base + variation).clamp(10, 90).toDouble();
    }
    
    setState(() {
      _sliderValues = traits;
    });
    _updateTraits();
  }
}

// Helper Classes
class _PresetData {
  const _PresetData(this.name, this.traits, this.emoji, this.color);
  final String name;
  final CharacterTraits traits;
  final String emoji;
  final Color color;
}

class _TraitSliderData {
  const _TraitSliderData(this.key, this.name, this.emoji, this.gradient);
  final String key;
  final String name;
  final String emoji;
  final dynamic gradient;
}