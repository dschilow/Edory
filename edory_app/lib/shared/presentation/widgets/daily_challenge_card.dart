// lib/features/home/presentation/widgets/daily_challenge_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/gradient_card.dart';

/// Daily Challenge Card Widget für die Avatales Homepage
/// Zeigt die tägliche Herausforderung mit Progress und Belohnung
class DailyChallengeCard extends StatefulWidget {
  const DailyChallengeCard({
    super.key,
    required this.title,
    required this.description,
    required this.progress,
    this.reward,
    this.timeLeft,
    this.onStartTap,
    this.onContinueTap,
    this.isCompleted = false,
    this.difficulty = ChallengeDifficulty.medium,
  });

  final String title;
  final String description;
  final double progress; // 0.0 - 1.0
  final String? reward;
  final Duration? timeLeft;
  final VoidCallback? onStartTap;
  final VoidCallback? onContinueTap;
  final bool isCompleted;
  final ChallengeDifficulty difficulty;

  @override
  State<DailyChallengeCard> createState() => _DailyChallengeCardState();
}

class _DailyChallengeCardState extends State<DailyChallengeCard>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _completionController;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _completionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _startAnimations();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _progressController.dispose();
    _pulseController.dispose();
    _completionController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _animationController.forward();
    _pulseController.repeat();
    
    // Animate progress bar
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        _progressController.animateTo(widget.progress);
      }
    });
    
    // Completion animation
    if (widget.isCompleted) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          _completionController.forward();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: widget.isCompleted
          ? LinearGradient(
              colors: [
                ModernDesignSystem.greenGradient.colors.first.withOpacity(0.1),
                ModernDesignSystem.greenGradient.colors.last.withOpacity(0.05),
              ],
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with challenge info
          _buildChallengeHeader()
              .animate(controller: _animationController)
              .slideX(begin: -0.3, duration: 600.ms)
              .fadeIn(),
          
          const SizedBox(height: 16),
          
          // Challenge content
          _buildChallengeContent()
              .animate(controller: _animationController)
              .slideY(begin: 0.3, duration: 600.ms, delay: 200.ms)
              .fadeIn(),
          
          const SizedBox(height: 20),
          
          // Progress section
          _buildProgressSection()
              .animate(controller: _animationController)
              .slideY(begin: 0.3, duration: 600.ms, delay: 400.ms)
              .fadeIn(),
          
          const SizedBox(height: 20),
          
          // Action button
          _buildActionButton()
              .animate(controller: _animationController)
              .slideY(begin: 0.3, duration: 600.ms, delay: 600.ms)
              .fadeIn(),
        ],
      ),
    );
  }

  Widget _buildChallengeHeader() {
    return Row(
      children: [
        // Challenge icon
        Stack(
          alignment: Alignment.center,
          children: [
            // Pulse background for active challenges
            if (!widget.isCompleted)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 50 + (_pulseController.value * 10),
                    height: 50 + (_pulseController.value * 10),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor().withOpacity(
                        0.2 - (_pulseController.value * 0.1),
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
            
            // Main icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: widget.isCompleted
                    ? ModernDesignSystem.greenGradient
                    : LinearGradient(
                        colors: [
                          _getDifficultyColor(),
                          _getDifficultyColor().withOpacity(0.8),
                        ],
                      ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _getDifficultyColor().withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                widget.isCompleted 
                    ? Icons.check_circle
                    : _getDifficultyIcon(),
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
        
        const SizedBox(width: 16),
        
        // Challenge info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: widget.isCompleted 
                            ? ModernDesignSystem.greenGradient.colors.first
                            : null,
                      ),
                    ),
                  ),
                  _buildDifficultyBadge(),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: ModernDesignSystem.secondaryTextColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    widget.timeLeft != null 
                        ? _formatTimeLeft(widget.timeLeft!)
                        : 'Heute verfügbar',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: ModernDesignSystem.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getDifficultyColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getDifficultyColor().withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...List.generate(
            widget.difficulty.stars,
            (index) => Icon(
              Icons.star,
              size: 10,
              color: _getDifficultyColor(),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            widget.difficulty.displayName,
            style: TextStyle(
              color: _getDifficultyColor(),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.5,
            color: ModernDesignSystem.primaryTextColor,
          ),
        ),
        
        if (widget.reward != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.amber.withOpacity(0.1),
                  Colors.orange.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belohnung',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade800,
                        ),
                      ),
                      Text(
                        widget.reward!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fortschritt',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              widget.isCompleted 
                  ? 'Abgeschlossen!'
                  : '${(widget.progress * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: widget.isCompleted 
                    ? ModernDesignSystem.greenGradient.colors.first
                    : _getDifficultyColor(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Progress bar
        Stack(
          children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Container(
                  height: 8,
                  width: MediaQuery.of(context).size.width * 
                         _progressController.value,
                  decoration: BoxDecoration(
                    gradient: widget.isCompleted
                        ? ModernDesignSystem.greenGradient
                        : LinearGradient(
                            colors: [
                              _getDifficultyColor(),
                              _getDifficultyColor().withOpacity(0.8),
                            ],
                          ),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: [
                      BoxShadow(
                        color: _getDifficultyColor().withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                );
              },
            ),
            
            // Completion sparkles
            if (widget.isCompleted)
              AnimatedBuilder(
                animation: _completionController,
                builder: (context, child) {
                  return Positioned.fill(
                    child: CustomPaint(
                      painter: _SparklesPainter(
                        animationValue: _completionController.value,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    if (widget.isCompleted) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: ModernDesignSystem.greenGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ModernDesignSystem.greenGradient.colors.first.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Challenge abgeschlossen!',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      )
          .animate(controller: _completionController)
          .scale(duration: 600.ms, curve: Curves.elasticOut)
          .shimmer(duration: 1000.ms, color: Colors.white.withOpacity(0.3));
    }

    final isStarted = widget.progress > 0;
    final onPressed = isStarted ? widget.onContinueTap : widget.onStartTap;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(
          isStarted ? Icons.play_arrow : Icons.rocket_launch,
          color: Colors.white,
        ),
        label: Text(
          isStarted ? 'Fortsetzen' : 'Challenge starten',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _getDifficultyColor(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: _getDifficultyColor().withOpacity(0.3),
        ),
      ),
    );
  }

  // Helper methods
  Color _getDifficultyColor() {
    switch (widget.difficulty) {
      case ChallengeDifficulty.easy:
        return ModernDesignSystem.pastelGreen;
      case ChallengeDifficulty.medium:
        return ModernDesignSystem.primaryColor;
      case ChallengeDifficulty.hard:
        return ModernDesignSystem.pastelRed;
      case ChallengeDifficulty.expert:
        return ModernDesignSystem.pastelPurple;
    }
  }

  IconData _getDifficultyIcon() {
    switch (widget.difficulty) {
      case ChallengeDifficulty.easy:
        return Icons.sentiment_satisfied;
      case ChallengeDifficulty.medium:
        return Icons.psychology;
      case ChallengeDifficulty.hard:
        return Icons.local_fire_department;
      case ChallengeDifficulty.expert:
        return Icons.auto_awesome;
    }
  }

  String _formatTimeLeft(Duration timeLeft) {
    if (timeLeft.inHours > 0) {
      return '${timeLeft.inHours}h ${timeLeft.inMinutes % 60}m verbleibend';
    } else if (timeLeft.inMinutes > 0) {
      return '${timeLeft.inMinutes}m verbleibend';
    } else {
      return 'Läuft bald ab!';
    }
  }
}

/// Challenge Difficulty Enum
enum ChallengeDifficulty {
  easy('Einfach', 1),
  medium('Mittel', 2),
  hard('Schwer', 3),
  expert('Expert', 4);

  const ChallengeDifficulty(this.displayName, this.stars);
  
  final String displayName;
  final int stars;
}

/// Challenge Type Enum
enum ChallengeType {
  story('Geschichten-Challenge', Icons.auto_stories),
  character('Charakter-Challenge', Icons.person),
  creative('Kreativ-Challenge', Icons.palette),
  learning('Lern-Challenge', Icons.school),
  social('Social-Challenge', Icons.group);

  const ChallengeType(this.displayName, this.icon);
  
  final String displayName;
  final IconData icon;
}

/// Sparkles Painter for completion animation
class _SparklesPainter extends CustomPainter {
  final double animationValue;

  const _SparklesPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    if (animationValue <= 0) return;

    final paint = Paint()
      ..color = Colors.white.withOpacity(animationValue * 0.8)
      ..style = PaintingStyle.fill;

    // Create sparkle positions
    final sparkles = [
      Offset(size.width * 0.2, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.2),
      Offset(size.width * 0.6, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 0.4),
    ];

    for (int i = 0; i < sparkles.length; i++) {
      final sparkleSize = 2.0 + (animationValue * 3.0);
      canvas.drawCircle(sparkles[i], sparkleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Daily Challenge Card Variants
class DailyChallengeCardVariants {
  /// Story writing challenge
  static Widget storyChallenge({
    required VoidCallback onStartTap,
    double progress = 0.0,
  }) {
    return DailyChallengeCard(
      title: 'Geschichten-Meister',
      description: 'Schreibe eine Geschichte über Freundschaft zwischen zwei ungewöhnlichen Charakteren.',
      progress: progress,
      reward: '100 XP + Spezial-Avatar',
      difficulty: ChallengeDifficulty.medium,
      onStartTap: onStartTap,
      timeLeft: const Duration(hours: 18, minutes: 30),
    );
  }

  /// Character creation challenge
  static Widget characterChallenge({
    required VoidCallback onStartTap,
    double progress = 0.0,
  }) {
    return DailyChallengeCard(
      title: 'Charakter-Designer',
      description: 'Erstelle einen neuen Avatar mit mindestens 3 verschiedenen Eigenschaften über 80.',
      progress: progress,
      reward: '75 XP + Premium-Trait',
      difficulty: ChallengeDifficulty.easy,
      onStartTap: onStartTap,
      timeLeft: const Duration(hours: 12, minutes: 15),
    );
  }

  /// Learning challenge
  static Widget learningChallenge({
    required VoidCallback onStartTap,
    double progress = 0.0,
  }) {
    return DailyChallengeCard(
      title: 'Wissens-Champion',
      description: 'Löse 5 Lernaufgaben in verschiedenen Kategorien und erreiche mindestens 80% Erfolgsquote.',
      progress: progress,
      reward: '150 XP + Weisheits-Boost',
      difficulty: ChallengeDifficulty.hard,
      onStartTap: onStartTap,
      timeLeft: const Duration(hours: 6, minutes: 45),
    );
  }

  /// Completed challenge
  static Widget completed({
    required String title,
    required String reward,
  }) {
    return DailyChallengeCard(
      title: title,
      description: 'Herzlichen Glückwunsch! Du hast die heutige Challenge erfolgreich abgeschlossen.',
      progress: 1.0,
      reward: reward,
      isCompleted: true,
      difficulty: ChallengeDifficulty.medium,
    );
  }
}