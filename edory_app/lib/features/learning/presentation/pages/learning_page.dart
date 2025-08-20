// lib/features/learning/presentation/pages/learning_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';

/// Professional Learning Mode - Vollständige pädagogische Features
class LearningPage extends ConsumerStatefulWidget {
  const LearningPage({super.key});

  @override
  ConsumerState<LearningPage> createState() => _LearningPageState();
}

class _LearningPageState extends ConsumerState<LearningPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _animationController = AnimationController(
      duration: ModernDesignSystem.durationMedium,
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Lernziele',
      subtitle: 'Pädagogische Fortschritte verfolgen',
      body: Column(
        children: [
          const SizedBox(height: 150),
          
          // Tab Bar mit Modern Design
          Container(
            margin: const EdgeInsets.symmetric(horizontal: ModernDesignSystem.spacing16),
            decoration: BoxDecoration(
              color: ModernDesignSystem.cardBackground,
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
              border: Border.all(color: ModernDesignSystem.borderColor, width: 1),
              boxShadow: ModernDesignSystem.shadowSmall,
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: ModernDesignSystem.accentBlue,
                borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: ModernDesignSystem.textSecondary,
              labelStyle: ModernDesignSystem.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: ModernDesignSystem.bodyMedium,
              tabs: const [
                Tab(text: 'Lernziele'),
                Tab(text: 'Fortschritt'),
                Tab(text: 'Einstellungen'),
              ],
            ),
          ).animate(controller: _animationController)
           .slideY(begin: -0.2, end: 0)
           .fadeIn(),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLearningObjectivesTab(),
                _buildProgressTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningObjectivesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: ModernDesignSystem.spacing16),
      child: Column(
        children: [
          // Aktive Lernziele Card
          iOSCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(ModernDesignSystem.spacing8),
                      decoration: BoxDecoration(
                        color: ModernDesignSystem.accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSmall),
                      ),
                      child: Icon(Icons.flag, color: ModernDesignSystem.accentGreen, size: 24),
                    ),
                    const SizedBox(width: ModernDesignSystem.spacing12),
                    Text('Aktive Lernziele', style: ModernDesignSystem.title3),
                  ],
                ),
                const SizedBox(height: ModernDesignSystem.spacing20),
                
                _buildLearningGoalItem('🦁', 'Mut entwickeln', 0.75, '7/10 Geschichten'),
                _buildLearningGoalItem('📖', 'Vokabular erweitern', 0.60, '9/15 Geschichten'),
                _buildLearningGoalItem('❤️', 'Empathie fördern', 0.85, '7/8 Geschichten'),
                
                const SizedBox(height: ModernDesignSystem.spacing12),
                iOSButton(
                  text: 'Neue Lernziele hinzufügen',
                  onPressed: () {},
                  isPrimary: true,
                  icon: const Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
          ),
          
          // Altersgerechte Ziele
          iOSCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Altersgerechte Lernziele', style: ModernDesignSystem.title3),
                const SizedBox(height: ModernDesignSystem.spacing16),
                Text('Wähle die passende Altersgruppe:', 
                     style: ModernDesignSystem.subheadline.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: ModernDesignSystem.spacing12),
                
                _buildAgeGroup('3-5 Jahre', ['Farben', 'Zählen', 'Emotionen'], false),
                _buildAgeGroup('6-8 Jahre', ['Lesen', 'Freundschaft', 'Kreativität'], true),
                _buildAgeGroup('9-12 Jahre', ['Komplexe Geschichten', 'Moral'], false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningGoalItem(String icon, String title, double progress, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: ModernDesignSystem.spacing12),
      padding: const EdgeInsets.all(ModernDesignSystem.spacing16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.backgroundTertiary,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
        border: Border.all(color: ModernDesignSystem.borderColor, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: ModernDesignSystem.spacing8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ModernDesignSystem.headline.copyWith(fontWeight: FontWeight.w600)),
                    Text(subtitle, style: ModernDesignSystem.footnote.copyWith(color: ModernDesignSystem.textSecondary)),
                  ],
                ),
              ),
              Text('${(progress * 100).round()}%', 
                   style: ModernDesignSystem.caption1.copyWith(color: ModernDesignSystem.accentBlue, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: ModernDesignSystem.spacing12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: ModernDesignSystem.systemGray6,
            valueColor: AlwaysStoppedAnimation(ModernDesignSystem.accentGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeGroup(String title, List<String> goals, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: ModernDesignSystem.spacing8),
      padding: const EdgeInsets.all(ModernDesignSystem.spacing16),
      decoration: BoxDecoration(
        color: isSelected ? ModernDesignSystem.accentBlue.withOpacity(0.1) : ModernDesignSystem.backgroundTertiary,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
        border: Border.all(
          color: isSelected ? ModernDesignSystem.accentBlue : ModernDesignSystem.borderColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: ModernDesignSystem.headline.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? ModernDesignSystem.accentBlue : ModernDesignSystem.textPrimary,
              )),
              const Spacer(),
              if (isSelected) Icon(Icons.check_circle, color: ModernDesignSystem.accentBlue, size: 20),
            ],
          ),
          const SizedBox(height: ModernDesignSystem.spacing8),
          Wrap(
            spacing: 6,
            children: goals.map((goal) => Container(
              padding: const EdgeInsets.symmetric(horizontal: ModernDesignSystem.spacing8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? ModernDesignSystem.accentBlue.withOpacity(0.1) : ModernDesignSystem.systemGray6,
                borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
              ),
              child: Text(goal, style: ModernDesignSystem.caption1.copyWith(
                color: isSelected ? ModernDesignSystem.accentBlue : ModernDesignSystem.textSecondary,
              )),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: ModernDesignSystem.spacing16),
      child: Column(
        children: [
          // Gesamtfortschritt
          iOSCard(
            child: Column(
              children: [
                Text('Gesamtfortschritt', style: ModernDesignSystem.title3),
                const SizedBox(height: ModernDesignSystem.spacing20),
                SizedBox(
                  width: 120,
                  height: 120,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: 0.68,
                        strokeWidth: 8,
                        backgroundColor: ModernDesignSystem.systemGray6,
                        valueColor: AlwaysStoppedAnimation(ModernDesignSystem.accentGreen),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('68%', style: ModernDesignSystem.h2.copyWith(
                              color: ModernDesignSystem.accentGreen, fontWeight: FontWeight.w800)),
                            Text('erreicht', style: ModernDesignSystem.caption1.copyWith(
                              color: ModernDesignSystem.textSecondary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ModernDesignSystem.spacing20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Geschichten', '47', ModernDesignSystem.accentBlue),
                    _buildStatItem('Lernziele', '12', ModernDesignSystem.accentGreen),
                    _buildStatItem('Abzeichen', '8', ModernDesignSystem.accentOrange),
                  ],
                ),
              ],
            ),
          ),
          
          // Wöchentlicher Fortschritt
          iOSCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Diese Woche', style: ModernDesignSystem.title3),
                const SizedBox(height: 16),
                _buildWeeklyGoal('📚', 'Lesen', 4, 5),
                _buildWeeklyGoal('🎨', 'Kreativität', 3, 3),
                _buildWeeklyGoal('🧩', 'Problemlösung', 2, 4),
                _buildWeeklyGoal('👥', 'Soziales', 5, 6),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: ModernDesignSystem.h2.copyWith(color: color, fontWeight: FontWeight.w700)),
        Text(label, style: ModernDesignSystem.caption1.copyWith(color: ModernDesignSystem.textSecondary)),
      ],
    );
  }

  Widget _buildWeeklyGoal(String icon, String title, int completed, int target) {
    final progress = completed / target;
    return Container(
      margin: const EdgeInsets.only(bottom: ModernDesignSystem.spacing12),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: ModernDesignSystem.spacing12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: ModernDesignSystem.body.copyWith(fontWeight: FontWeight.w600)),
                    Text('$completed/$target', style: ModernDesignSystem.caption1.copyWith(color: ModernDesignSystem.accentBlue)),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress > 1.0 ? 1.0 : progress,
                  backgroundColor: ModernDesignSystem.systemGray6,
                  valueColor: AlwaysStoppedAnimation(
                    completed >= target ? ModernDesignSystem.accentGreen : ModernDesignSystem.accentBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: ModernDesignSystem.spacing16),
      child: Column(
        children: [
          iOSCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lernpräferenzen', style: ModernDesignSystem.title3),
                const SizedBox(height: 16),
                _buildToggle('Audiobook-Modus', true),
                _buildToggle('Interaktive Elemente', true),
                _buildToggle('Wiederholungsmodus', false),
                _buildToggle('Fortschritt-Benachrichtigungen', true),
              ],
            ),
          ),
          
          iOSCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Schwierigkeitsgrad', style: ModernDesignSystem.title3),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'easy', label: Text('Einfach')),
                    ButtonSegment(value: 'medium', label: Text('Mittel')),
                    ButtonSegment(value: 'hard', label: Text('Schwer')),
                  ],
                  selected: {'medium'},
                  onSelectionChanged: (selection) {},
                ),
                const SizedBox(height: 16),
                _buildToggle('Automatisch anpassen', true),
              ],
            ),
          ),
          
          iOSCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Elternkontrolle', style: ModernDesignSystem.title3),
                const SizedBox(height: 16),
                _buildControlItem('Tägliche Bildschirmzeit', '45 Min', Icons.schedule),
                _buildControlItem('Inhaltsbeschränkungen', 'Aktiviert', Icons.security),
                _buildControlItem('Fortschrittsberichte', 'Wöchentlich', Icons.assessment),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String title, bool value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: ModernDesignSystem.body),
          Switch(value: value, onChanged: (newValue) {}),
        ],
      ),
    );
  }

  Widget _buildControlItem(String title, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ModernDesignSystem.backgroundTertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: ModernDesignSystem.accentBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: ModernDesignSystem.body)),
          Text(value, style: ModernDesignSystem.caption1.copyWith(
            color: ModernDesignSystem.textSecondary)),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: ModernDesignSystem.systemGray, size: 16),
        ],
      ),
    );
  }
}
