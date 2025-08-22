// lib/features/characters/presentation/widgets/character_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../domain/entities/character.dart';
import 'character_traits_widget.dart';

/// Professional Character Card Widget für Avatales
/// Displays character information with modern design and animations
class CharacterCard extends StatefulWidget {
  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
    this.isSelectable = false,
    this.isSelected = false,
    this.compact = false,
    this.showStats = true,
    this.showTraits = false,
    this.showRarity = true,
  });

  final Character character;
  final VoidCallback onTap;
  final bool isSelectable;
  final bool isSelected;
  final bool compact;
  final bool showStats;
  final bool showTraits;
  final bool showRarity;

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard>
    with TickerProviderStateMixin {
  
  late AnimationController _hoverController;
  late AnimationController _pressController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) => _pressController.reverse(),
        onTapCancel: () => _pressController.reverse(),
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: Listenable.merge([_hoverController, _pressController]),
          builder: (context, child) {
            final scale = 1.0 - (_pressController.value * 0.05);
            final elevation = 4.0 + (_hoverController.value * 8.0);
            
            return Transform.scale(
              scale: scale,
              child: widget.compact ? _buildCompactCard(elevation) : _buildFullCard(elevation),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFullCard(double elevation) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: widget.isSelected
            ? Border.all(
                color: ModernDesignSystem.primaryColor,
                width: 2,
              )
            : Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: widget.isSelected
                ? ModernDesignSystem.primaryColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: elevation,
            offset: Offset(0, elevation / 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Avatar and Rarity
          _buildCardHeader(),
          
          // Character Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Level
                  _buildNameAndLevel(),
                  const SizedBox(height: 8),
                  
                  // Description
                  _buildDescription(),
                  
                  const Spacer(),
                  
                  // Stats or Traits
                  if (widget.showTraits) ...[
                    const SizedBox(height: 12),
                    CharacterTraitsWidget(
                      traits: widget.character.traits,
                      compact: true,
                      showLabels: false,
                    ),
                  ] else if (widget.showStats) ...[
                    const SizedBox(height: 12),
                    _buildStats(),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCard(double elevation) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: widget.isSelected
            ? Border.all(color: ModernDesignSystem.primaryColor, width: 2)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: widget.isSelected
                ? ModernDesignSystem.primaryColor.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: elevation,
            offset: Offset(0, elevation / 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            _buildAvatar(size: 50),
            const SizedBox(width: 12),
            
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Name and Rarity
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.character.displayName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.showRarity) _buildRarityBadge(compact: true),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Level and Category
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: ModernDesignSystem.primaryOrange,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Level ${widget.character.level}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ModernDesignSystem.secondaryTextColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.character.category.emoji,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Progress bar
                  _buildLevelProgress(compact: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: _getCharacterGradient(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _CharacterPatternPainter(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          
          // Avatar and Selection indicator
          Center(
            child: _buildAvatar(),
          ),
          
          // Rarity badge
          if (widget.showRarity)
            Positioned(
              top: 12,
              right: 12,
              child: _buildRarityBadge(),
            ),
          
          // Selection indicator
          if (widget.isSelectable && widget.isSelected)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check,
                  color: ModernDesignSystem.primaryColor,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar({double size = 60}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: widget.character.avatarUrl != null
          ? ClipOval(
              child: Image.network(
                widget.character.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildAvatarFallback(size),
              ),
            )
          : _buildAvatarFallback(size),
    );
  }

  Widget _buildAvatarFallback(double size) {
    return Container(
      decoration: BoxDecoration(
        gradient: ModernDesignSystem.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          widget.character.displayName[0].toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRarityBadge({bool compact = false}) {
    final rarity = widget.character.rarity;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: _getRarityColor(rarity),
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        boxShadow: [
          BoxShadow(
            color: _getRarityColor(rarity).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            rarity.emoji,
            style: TextStyle(fontSize: compact ? 8 : 10),
          ),
          if (!compact) ...[
            const SizedBox(width: 4),
            Text(
              rarity.displayName,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 8 : 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNameAndLevel() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.character.displayName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ModernDesignSystem.primaryOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ModernDesignSystem.primaryOrange.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                size: 14,
                color: ModernDesignSystem.primaryOrange,
              ),
              const SizedBox(width: 4),
              Text(
                '${widget.character.level}',
                style: TextStyle(
                  color: ModernDesignSystem.primaryOrange,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      widget.character.description,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: ModernDesignSystem.secondaryTextColor,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildStats() {
    return Column(
      children: [
        // Level Progress
        _buildLevelProgress(),
        const SizedBox(height: 8),
        
        // Stats Row
        Row(
          children: [
            _buildStatItem(
              icon: Icons.menu_book,
              value: widget.character.readCount.toString(),
              label: 'Geschichten',
            ),
            const SizedBox(width: 16),
            _buildStatItem(
              icon: Icons.psychology,
              value: widget.character.traits.averageValue.toStringAsFixed(0),
              label: 'Stärke',
            ),
            const Spacer(),
            Text(
              widget.character.category.emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLevelProgress({bool compact = false}) {
    return Column(
      children: [
        if (!compact) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level ${widget.character.level}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${widget.character.experienceToNextLevel} XP',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ModernDesignSystem.secondaryTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
        ],
        
        LinearProgressIndicator(
          value: widget.character.levelProgress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(_getCharacterGradient().colors.first),
          minHeight: compact ? 3 : 4,
          borderRadius: BorderRadius.circular(compact ? 1.5 : 2),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: ModernDesignSystem.secondaryTextColor,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ModernDesignSystem.secondaryTextColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Helper Methods
  void _onHoverChanged(bool isHovered) {
    setState(() => _isHovered = isHovered);
    if (isHovered) {
      _hoverController.forward();
    } else {
      _hoverController.reverse();
    }
  }

  LinearGradient _getCharacterGradient() {
    switch (widget.character.category) {
      case CharacterCategory.hero:
        return ModernDesignSystem.redGradient;
      case CharacterCategory.explorer:
        return ModernDesignSystem.primaryGradient;
      case CharacterCategory.helper:
        return ModernDesignSystem.greenGradient;
      case CharacterCategory.entertainer:
        return ModernDesignSystem.orangeGradient;
      case CharacterCategory.sage:
        return const LinearGradient(
          colors: [ModernDesignSystem.pastelPurple, Color(0xFF9C88FF)],
        );
      case CharacterCategory.balanced:
        return ModernDesignSystem.primaryGradient;
    }
  }

  Color _getRarityColor(CharacterRarity rarity) {
    switch (rarity) {
      case CharacterRarity.common:
        return Colors.grey.shade600;
      case CharacterRarity.uncommon:
        return Colors.green.shade600;
      case CharacterRarity.rare:
        return Colors.blue.shade600;
      case CharacterRarity.epic:
        return Colors.purple.shade600;
      case CharacterRarity.legendary:
        return Colors.amber.shade600;
    }
  }
}

/// Custom painter for character card background pattern
class _CharacterPatternPainter extends CustomPainter {
  final Color color;

  const _CharacterPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Create subtle dot pattern
    const spacing = 20.0;
    const dotSize = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x + (spacing * 0.5), y + (spacing * 0.5)),
          dotSize,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CharacterPatternPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}