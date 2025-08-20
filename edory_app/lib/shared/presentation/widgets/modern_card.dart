// lib/shared/presentation/widgets/modern_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/modern_design_system.dart';

/// Modern Card Widget - Clean, Professional Design
class ModernCard extends StatelessWidget {
  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.elevation = 0,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.animationDelay,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final int elevation;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Duration? animationDelay;

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: ModernDesignSystem.spacing20,
        vertical: ModernDesignSystem.spacing8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? ModernDesignSystem.cardBackground,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLarge),
        border: Border.all(
          color: borderColor ?? ModernDesignSystem.borderColor,
          width: 1,
        ),
        boxShadow: elevation > 0 ? ModernDesignSystem.shadowMedium : ModernDesignSystem.shadowSmall,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLarge),
          child: Container(
            padding: padding ?? const EdgeInsets.all(ModernDesignSystem.spacing20),
            child: child,
          ),
        ),
      ),
    );

    if (animationDelay != null) {
      return cardWidget
          .animate(delay: animationDelay!)
          .fadeIn(duration: ModernDesignSystem.durationMedium)
          .slideY(begin: 0.1, duration: ModernDesignSystem.durationMedium);
    }

    return cardWidget;
  }
}

/// Modern List Item Card
class ModernListCard extends StatelessWidget {
  const ModernListCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.animationDelay,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Duration? animationDelay;

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      onTap: onTap,
      animationDelay: animationDelay,
      padding: const EdgeInsets.all(ModernDesignSystem.spacing16),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: ModernDesignSystem.spacing16),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ModernDesignSystem.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: ModernDesignSystem.spacing4),
                  Text(
                    subtitle!,
                    style: ModernDesignSystem.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: ModernDesignSystem.spacing16),
            trailing!,
          ],
        ],
      ),
    );
  }
}

/// Modern Stats Card
class ModernStatsCard extends StatelessWidget {
  const ModernStatsCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.color,
    this.animationDelay,
  });

  final String value;
  final String label;
  final IconData? icon;
  final Color? color;
  final Duration? animationDelay;

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      animationDelay: animationDelay,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: (color ?? ModernDesignSystem.accentBlue).withOpacity(0.1),
                borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
              ),
              child: Icon(
                icon,
                color: color ?? ModernDesignSystem.accentBlue,
                size: 24,
              ),
            ),
            const SizedBox(height: ModernDesignSystem.spacing12),
          ],
          Text(
            value,
            style: ModernDesignSystem.h3.copyWith(
              color: color ?? ModernDesignSystem.accentBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: ModernDesignSystem.spacing4),
          Text(
            label,
            style: ModernDesignSystem.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
