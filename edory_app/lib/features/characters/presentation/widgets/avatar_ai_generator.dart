// lib/features/characters/presentation/widgets/avatar_ai_generator.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/gradient_card.dart';
import '../pages/avatar_creation_page.dart';

/// AI Avatar Generator Widget für Avatales
/// Ermöglicht die Konfiguration und Generierung von KI-Avataren
class AvatarAIGenerator extends StatefulWidget {
  const AvatarAIGenerator({
    super.key,
    required this.appearance,
    required this.onAppearanceChanged,
    required this.onGeneratePressed,
    required this.isGenerating,
    this.generatedImageUrl,
  });

  final AvatarAppearance appearance;
  final ValueChanged<AvatarAppearance> onAppearanceChanged;
  final VoidCallback onGeneratePressed;
  final bool isGenerating;
  final String? generatedImageUrl;

  @override
  State<AvatarAIGenerator> createState() => _AvatarAIGeneratorState();
}

class _AvatarAIGeneratorState extends State<AvatarAIGenerator>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Avatar Preview
        _buildAvatarPreview(),
        const SizedBox(height: 24),
        
        // Appearance Configuration
        _buildAppearanceConfiguration(),
        const SizedBox(height: 24),
        
        // Generate Button
        _buildGenerateButton(),
      ],
    );
  }

  Widget _buildAvatarPreview() {
    return GradientCard(
      child: Column(
        children: [
          Text(
            'Avatar-Vorschau',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              gradient: widget.isGenerating 
                  ? null 
                  : ModernDesignSystem.primaryGradient,
              color: widget.isGenerating 
                  ? Colors.grey.shade200 
                  : null,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.isGenerating 
                      ? Colors.grey.withOpacity(0.3)
                      : ModernDesignSystem.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: widget.isGenerating
                ? _buildGeneratingAnimation()
                : widget.generatedImageUrl != null
                    ? _buildGeneratedAvatar()
                    : _buildPlaceholder(),
          ),
          
          if (widget.isGenerating) ...[
            const SizedBox(height: 16),
            Text(
              'Avatar wird generiert...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ModernDesignSystem.secondaryTextColor,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(ModernDesignSystem.primaryColor),
            ),
          ],
          
          if (widget.generatedImageUrl != null && !widget.isGenerating) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: widget.onGeneratePressed,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Neu generieren',
                  style: IconButton.styleFrom(
                    backgroundColor: ModernDesignSystem.primaryColor.withOpacity(0.1),
                    foregroundColor: ModernDesignSystem.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    // TODO: Save/Download avatar
                  },
                  icon: const Icon(Icons.download),
                  tooltip: 'Herunterladen',
                  style: IconButton.styleFrom(
                    backgroundColor: ModernDesignSystem.greenGradient.colors.first.withOpacity(0.1),
                    foregroundColor: ModernDesignSystem.greenGradient.colors.first,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGeneratingAnimation() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing circle
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 120 + (_pulseController.value * 20),
              height: 120 + (_pulseController.value * 20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ModernDesignSystem.primaryColor.withOpacity(
                    0.5 - (_pulseController.value * 0.3),
                  ),
                  width: 2,
                ),
              ),
            );
          },
        ),
        
        // Shimmer effect
        AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) {
            return Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + _shimmerController.value * 2, 0),
                  end: Alignment(-0.5 + _shimmerController.value * 2, 0),
                  colors: [
                    Colors.grey.shade300,
                    Colors.white,
                    Colors.grey.shade300,
                  ],
                ),
              ),
            );
          },
        ),
        
        // AI icon
        Icon(
          Icons.auto_awesome,
          size: 40,
          color: ModernDesignSystem.primaryColor,
        ),
      ],
    );
  }

  Widget _buildGeneratedAvatar() {
    return ClipOval(
      child: Image.network(
        widget.generatedImageUrl!,
        width: 160,
        height: 160,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 160,
            height: 160,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.white),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      ),
    )
        .animate()
        .scale(duration: 600.ms, curve: Curves.elasticOut)
        .fadeIn();
  }

  Widget _buildPlaceholder() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          Icons.person,
          size: 80,
          color: Colors.white,
        ),
        Positioned(
          bottom: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.auto_awesome,
              size: 20,
              color: ModernDesignSystem.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceConfiguration() {
    return Column(
      children: [
        // Basic Settings
        _buildConfigurationCard(
          title: 'Grundeinstellungen',
          icon: Icons.face,
          children: [
            _buildDropdownRow(
              'Alter',
              widget.appearance.age.displayName,
              AvatarAge.values.map((e) => e.displayName).toList(),
              (value) => _updateAppearance(
                widget.appearance.copyWith(
                  age: AvatarAge.values.firstWhere((e) => e.displayName == value),
                ),
              ),
            ),
            _buildDropdownRow(
              'Geschlecht',
              widget.appearance.gender.displayName,
              AvatarGender.values.map((e) => e.displayName).toList(),
              (value) => _updateAppearance(
                widget.appearance.copyWith(
                  gender: AvatarGender.values.firstWhere((e) => e.displayName == value),
                ),
              ),
            ),
            _buildDropdownRow(
              'Stil',
              widget.appearance.style.displayName,
              AvatarStyle.values.map((e) => e.displayName).toList(),
              (value) => _updateAppearance(
                widget.appearance.copyWith(
                  style: AvatarStyle.values.firstWhere((e) => e.displayName == value),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Physical Features
        _buildConfigurationCard(
          title: 'Aussehen',
          icon: Icons.palette,
          children: [
            _buildDropdownRow(
              'Hautton',
              widget.appearance.skinTone.displayName,
              SkinTone.values.map((e) => e.displayName).toList(),
              (value) => _updateAppearance(
                widget.appearance.copyWith(
                  skinTone: SkinTone.values.firstWhere((e) => e.displayName == value),
                ),
              ),
            ),
            _buildDropdownRow(
              'Haarfarbe',
              widget.appearance.hairColor.displayName,
              HairColor.values.map((e) => e.displayName).toList(),
              (value) => _updateAppearance(
                widget.appearance.copyWith(
                  hairColor: HairColor.values.firstWhere((e) => e.displayName == value),
                ),
              ),
            ),
            _buildDropdownRow(
              'Frisur',
              widget.appearance.hairStyle.displayName,
              HairStyle.values.map((e) => e.displayName).toList(),
              (value) => _updateAppearance(
                widget.appearance.copyWith(
                  hairStyle: HairStyle.values.firstWhere((e) => e.displayName == value),
                ),
              ),
            ),
            _buildDropdownRow(
              'Augenfarbe',
              widget.appearance.eyeColor.displayName,
              EyeColor.values.map((e) => e.displayName).toList(),
              (value) => _updateAppearance(
                widget.appearance.copyWith(
                  eyeColor: EyeColor.values.firstWhere((e) => e.displayName == value),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfigurationCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: ModernDesignSystem.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdownRow(
    String label,
    String value,
    List<String> options,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: value,
                  isExpanded: true,
                  items: options.map((option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  )).toList(),
                  onChanged: (newValue) {
                    if (newValue != null) onChanged(newValue);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton() {
    final canGenerate = !widget.isGenerating;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canGenerate ? widget.onGeneratePressed : null,
        icon: widget.isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(
          widget.isGenerating 
              ? 'Wird generiert...' 
              : widget.generatedImageUrl != null
                  ? 'Neu generieren'
                  : 'Avatar generieren',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isGenerating 
              ? Colors.grey.shade400 
              : ModernDesignSystem.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: widget.isGenerating ? 0 : 8,
          shadowColor: ModernDesignSystem.primaryColor.withOpacity(0.3),
        ),
      ),
    );
  }

  void _updateAppearance(AvatarAppearance newAppearance) {
    widget.onAppearanceChanged(newAppearance);
  }
}