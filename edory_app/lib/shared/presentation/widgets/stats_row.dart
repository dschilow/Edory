// lib/shared/presentation/widgets/stats_row.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/modern_design_system.dart';


class StatsRow extends StatelessWidget {
  const StatsRow({
    super.key,
    required this.stats,
  });

  final List<StatData> stats;

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return const SizedBox.shrink();
    }

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
      padding: const EdgeInsets.all(20),
      child: Row(
        children: stats.asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          
          return Expanded(
            child: _buildStatItem(context, stat)
                .animate(delay: (index * 100).ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, duration: 600.ms),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, StatData stat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            stat.gradient.colors.first.withOpacity(0.1),
            stat.gradient.colors.last.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            stat.icon,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 8),
          Text(
            stat.value,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: stat.gradient.colors.first,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: ModernDesignSystem.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class StatData {
  const StatData({
    required this.icon,
    required this.value,
    required this.label,
    required this.gradient,
  });

  final String icon;
  final String value;
  final String label;
  final LinearGradient gradient;
}
