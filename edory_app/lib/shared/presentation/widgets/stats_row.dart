// lib/shared/presentation/widgets/stats_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/modern_design_system.dart';

/// Stats Row Widget für Avatales
/// Displays statistics in a row of animated cards
class StatsRow extends StatefulWidget {
  const StatsRow({
    super.key,
    required this.stats,
    this.animated = true,
    this.compact = false,
  });

  final List<StatData> stats;
  final bool animated;
  final bool compact;

  @override
  State<StatsRow> createState() => _StatsRowState();
}

class _StatsRowState extends State<StatsRow>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late List<AnimationController> _countControllers;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _countControllers = List.generate(
      widget.stats.length,
      (index) => AnimationController(
        duration: Duration(milliseconds: 1000 + (index * 200)),
        vsync: this,
      ),
    );
    
    if (widget.animated) {
      _startAnimations();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _countControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startAnimations() {
    _animationController.forward();
    
    for (int i = 0; i < _countControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 200), () {
        if (mounted) {
          _countControllers[i].forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.compact ? 80 : 100,
      child: Row(
        children: widget.stats.asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index < widget.stats.length - 1 ? 12 : 0,
              ),
              child: widget.animated
                  ? _buildAnimatedStatCard(stat, index)
                  : _buildStatCard(stat, index),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAnimatedStatCard(StatData stat, int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return _buildStatCard(stat, index)
            .animate(delay: (index * 100).ms)
            .slideY(begin: 0.5, duration: 600.ms, curve: Curves.easeOutCubic)
            .fadeIn();
      },
    );
  }

  Widget _buildStatCard(StatData stat, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.white.withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(widget.compact ? 16 : 20),
        border: Border.all(
          color: Colors.black.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: stat.gradient?.colors.first.withOpacity(0.1) ?? 
                   ModernDesignSystem.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(widget.compact ? 16 : 20),
        child: InkWell(
          borderRadius: BorderRadius.circular(widget.compact ? 16 : 20),
          onTap: stat.onTap,
          child: Padding(
            padding: EdgeInsets.all(widget.compact ? 12 : 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon/Emoji
                _buildStatIcon(stat),
                
                SizedBox(height: widget.compact ? 6 : 8),
                
                // Value
                _buildStatValue(stat, index),
                
                SizedBox(height: widget.compact ? 2 : 4),
                
                // Label
                _buildStatLabel(stat),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatIcon(StatData stat) {
    if (stat.icon != null) {
      // Use emoji/text icon
      return Text(
        stat.icon!,
        style: TextStyle(
          fontSize: widget.compact ? 20 : 24,
        ),
      );
    } else if (stat.iconData != null) {
      // Use IconData
      return Container(
        padding: EdgeInsets.all(widget.compact ? 8 : 10),
        decoration: BoxDecoration(
          gradient: stat.gradient ?? ModernDesignSystem.primaryGradient,
          borderRadius: BorderRadius.circular(widget.compact ? 8 : 12),
          boxShadow: [
            BoxShadow(
              color: (stat.gradient?.colors.first ?? ModernDesignSystem.primaryColor)
                  .withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          stat.iconData!,
          color: Colors.white,
          size: widget.compact ? 16 : 20,
        ),
      );
    }
    
    // Fallback
    return Container(
      width: widget.compact ? 32 : 40,
      height: widget.compact ? 32 : 40,
      decoration: BoxDecoration(
        gradient: stat.gradient ?? ModernDesignSystem.primaryGradient,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildStatValue(StatData stat, int index) {
    if (!widget.animated) {
      return Text(
        stat.value,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: ModernDesignSystem.primaryTextColor,
          fontSize: widget.compact ? 18 : 22,
        ),
        textAlign: TextAlign.center,
      );
    }

    return AnimatedBuilder(
      animation: _countControllers[index],
      builder: (context, child) {
        // Try to animate numeric values
        final numericValue = double.tryParse(stat.value);
        String displayValue;
        
        if (numericValue != null) {
          final animatedValue = (numericValue * _countControllers[index].value);
          displayValue = animatedValue.toStringAsFixed(
            stat.value.contains('.') ? 1 : 0,
          );
        } else {
          // For non-numeric values, just fade in
          displayValue = stat.value;
        }
        
        return Opacity(
          opacity: _countControllers[index].value,
          child: Text(
            displayValue,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: ModernDesignSystem.primaryTextColor,
              fontSize: widget.compact ? 18 : 22,
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildStatLabel(StatData stat) {
    return Text(
      stat.label,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: ModernDesignSystem.secondaryTextColor,
        fontWeight: FontWeight.w600,
        fontSize: widget.compact ? 11 : 12,
      ),
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Stat Data Model
class StatData {
  const StatData({
    required this.value,
    required this.label,
    this.icon,
    this.iconData,
    this.gradient,
    this.onTap,
    this.trend,
    this.trendValue,
  });

  final String value;
  final String label;
  final String? icon;           // Emoji or text icon
  final IconData? iconData;     // Material icon
  final LinearGradient? gradient;
  final VoidCallback? onTap;
  final StatTrend? trend;
  final String? trendValue;

  StatData copyWith({
    String? value,
    String? label,
    String? icon,
    IconData? iconData,
    LinearGradient? gradient,
    VoidCallback? onTap,
    StatTrend? trend,
    String? trendValue,
  }) {
    return StatData(
      value: value ?? this.value,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      iconData: iconData ?? this.iconData,
      gradient: gradient ?? this.gradient,
      onTap: onTap ?? this.onTap,
      trend: trend ?? this.trend,
      trendValue: trendValue ?? this.trendValue,
    );
  }
}

/// Stat Trend Enum
enum StatTrend {
  up('⬆️', Colors.green),
  down('⬇️', Colors.red),
  stable('➡️', Colors.grey);

  const StatTrend(this.icon, this.color);
  
  final String icon;
  final Color color;
}

/// Stats Row Variants for different use cases
class StatsRowVariants {
  /// User overview stats
  static Widget userOverview({
    required int storiesCount,
    required int charactersCount,
    required int totalLevel,
  }) {
    return StatsRow(
      stats: [
        StatData(
          icon: '📚',
          value: storiesCount.toString(),
          label: 'Geschichten',
          gradient: ModernDesignSystem.redGradient,
        ),
        StatData(
          icon: '👥',
          value: charactersCount.toString(),
          label: 'Avatare',
          gradient: ModernDesignSystem.primaryGradient,
        ),
        StatData(
          icon: '🏆',
          value: totalLevel.toString(),
          label: 'Gesamt Level',
          gradient: ModernDesignSystem.greenGradient,
        ),
      ],
    );
  }

  /// Character stats
  static Widget characterStats({
    required int level,
    required int storiesRead,
    required double traitAverage,
  }) {
    return StatsRow(
      stats: [
        StatData(
          icon: '⭐',
          value: level.toString(),
          label: 'Level',
          gradient: ModernDesignSystem.orangeGradient,
        ),
        StatData(
          icon: '📖',
          value: storiesRead.toString(),
          label: 'Geschichten',
          gradient: ModernDesignSystem.primaryGradient,
        ),
        StatData(
          icon: '💪',
          value: traitAverage.toStringAsFixed(0),
          label: 'Stärke',
          gradient: ModernDesignSystem.greenGradient,
        ),
      ],
    );
  }

  /// Story stats
  static Widget storyStats({
    required int totalStories,
    required int readingTime,
    required int favorites,
  }) {
    return StatsRow(
      stats: [
        StatData(
          icon: '📚',
          value: totalStories.toString(),
          label: 'Erstellt',
          gradient: ModernDesignSystem.primaryGradient,
        ),
        StatData(
          icon: '⏱️',
          value: '${readingTime}m',
          label: 'Lesezeit',
          gradient: ModernDesignSystem.orangeGradient,
        ),
        StatData(
          icon: '❤️',
          value: favorites.toString(),
          label: 'Favoriten',
          gradient: ModernDesignSystem.redGradient,
        ),
      ],
    );
  }

  /// Learning progress stats
  static Widget learningProgress({
    required int completedLessons,
    required int totalXP,
    required int streak,
  }) {
    return StatsRow(
      stats: [
        StatData(
          icon: '✅',
          value: completedLessons.toString(),
          label: 'Abgeschlossen',
          gradient: ModernDesignSystem.greenGradient,
        ),
        StatData(
          icon: '⚡',
          value: totalXP.toString(),
          label: 'XP',
          gradient: ModernDesignSystem.primaryGradient,
        ),
        StatData(
          icon: '🔥',
          value: streak.toString(),
          label: 'Streak',
          gradient: ModernDesignSystem.orangeGradient,
        ),
      ],
    );
  }

  /// Compact stats for cards
  static Widget compact({
    required List<StatData> stats,
  }) {
    return StatsRow(
      stats: stats,
      compact: true,
    );
  }
}

/// Animated Counter Widget for individual stats
class AnimatedCounter extends StatefulWidget {
  const AnimatedCounter({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 1000),
    this.style,
  });

  final double value;
  final Duration duration;
  final TextStyle? style;

  @override
  State<AnimatedCounter> createState() => _AnimatedCounterState();
}

class _AnimatedCounterState extends State<AnimatedCounter>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Text(
          _animation.value.toStringAsFixed(
            widget.value % 1 == 0 ? 0 : 1,
          ),
          style: widget.style,
        );
      },
    );
  }
}