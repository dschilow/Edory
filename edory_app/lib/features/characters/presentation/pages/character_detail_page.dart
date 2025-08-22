// lib/features/characters/presentation/pages/character_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../providers/characters_provider.dart';
import '../widgets/character_traits_widget.dart';

class CharacterDetailPage extends ConsumerStatefulWidget {
  const CharacterDetailPage({
    super.key,
    required this.characterId,
  });

  final String characterId;

  @override
  ConsumerState<CharacterDetailPage> createState() => _CharacterDetailPageState();
}

class _CharacterDetailPageState extends ConsumerState<CharacterDetailPage>
    with TickerProviderStateMixin {
  
  late AnimationController _heroController;
  late AnimationController _contentController;
  late TabController _tabController;
  
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _contentController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _tabController = TabController(length: 3, vsync: this);
    
    _heroController.forward();
    _contentController.forward();
    
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() => _selectedTabIndex = _tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _contentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final charactersState = ref.watch(charactersProvider);

    return charactersState.when(
      data: (characters) {
        final character = characters.where((c) => c.id == widget.characterId).firstOrNull;
        
        if (character == null) {
          return _buildNotFoundState();
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0E1324), // dark bg
          body: CustomScrollView(
            slivers: [
              // Hero App Bar
              _buildHeroAppBar(character),
              
              // Character Stats Hero
              SliverToBoxAdapter(
                child: _buildCharacterHero(character)
                  .animate(controller: _heroController)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOutBack),
              ),
              
              // Action Buttons
              SliverToBoxAdapter(
                child: _buildActionButtons(character)
                  .animate(controller: _contentController)
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
              ),
              
              // Tab Bar
              SliverToBoxAdapter(
                child: _buildTabBar()
                  .animate(controller: _contentController)
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .slideX(begin: -0.2, curve: Curves.easeOutCubic),
              ),
              
              // Tab Content
              SliverToBoxAdapter(
                child: _buildTabContent(character)
                  .animate(controller: _contentController)
                  .fadeIn(delay: 600.ms, duration: 500.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOutBack),
              ),
              
              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
      },
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState(),
    );
  }

  Widget _buildHeroAppBar(dynamic character) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF171C30).withOpacity(0.95),
      leading: IconButton(
        onPressed: () => context.go('/characters'),
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.arrow_back_rounded,
            color: Color(0xFFF8FAFC),
            size: 20,
          ),
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Show character menu
          },
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.more_vert_rounded,
              color: Color(0xFFF8FAFC),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          character.displayName ?? 'Avatar',
          style: const TextStyle(
            color: Color(0xFFF8FAFC),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF8D95FF).withOpacity(0.3),
                const Color(0xFF9EF0DE).withOpacity(0.2),
                const Color(0xFF0E1324),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCharacterHero(dynamic character) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF171C30),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF8D95FF).withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8D95FF).withOpacity(0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar Image (größer für Detail-View)
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF8D95FF).withOpacity(0.4),
                  const Color(0xFF9EF0DE).withOpacity(0.4),
                  const Color(0xFFFF9BC4).withOpacity(0.3),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF8D95FF).withOpacity(0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8D95FF).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                character.displayName?.substring(0, 1).toUpperCase() ?? '?',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFF8FAFC),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Name & Level
          Text(
            character.displayName ?? 'Unbekannt',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8D95FF), Color(0xFF6E77FF)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Level ${character.traits?.courage ?? 1}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // Stats Overview
          _buildStatsOverview(character),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(dynamic character) {
    final stats = [
      {
        'label': 'Mut',
        'value': character.traits?.courage ?? 50,
        'emoji': '🦁',
        'color': const Color(0xFF8D95FF),
      },
      {
        'label': 'Stärke',
        'value': character.traits?.strength ?? 50,
        'emoji': '💪',
        'color': const Color(0xFF9EF0DE),
      },
      {
        'label': 'Kreativität',
        'value': character.traits?.creativity ?? 50,
        'emoji': '🎨',
        'color': const Color(0xFFFF9BC4),
      },
      {
        'label': 'Weisheit',
        'value': character.traits?.wisdom ?? 50,
        'emoji': '🧠',
        'color': const Color(0xFFFFD489),
      },
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: stats.map((stat) => _buildStatColumn(
        emoji: stat['emoji'] as String,
        label: stat['label'] as String,
        value: stat['value'] as int,
        color: stat['color'] as Color,
      )).toList(),
    );
  }

  Widget _buildStatColumn({
    required String emoji,
    required String label,
    required int value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFFCBD5E1),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(dynamic character) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // Primary Action: Neue Geschichte
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () => context.go('/stories/create?characterId=${character.id}'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8D95FF), Color(0xFF6E77FF)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8D95FF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_stories_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Neue Geschichte',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Secondary Action: Avatar bearbeiten
          Expanded(
            child: GestureDetector(
              onTap: () {
                // Navigate to edit character
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF8D95FF).withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_rounded, color: Color(0xFF8D95FF), size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Bearbeiten',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8D95FF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    const tabs = ['Entwicklung', 'Aussehen', 'Einstellungen'];
    
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF171C30),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: const Color(0xFF8D95FF).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = _selectedTabIndex == index;
          
          return Expanded(
            child: GestureDetector(
              onTap: () {
                _tabController.animateTo(index);
                setState(() => _selectedTabIndex = index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? const Color(0xFF8D95FF)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFF8D95FF).withOpacity(0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  tab,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected 
                      ? Colors.white
                      : const Color(0xFF8D95FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(dynamic character) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(minHeight: 400),
      child: IndexedStack(
        index: _selectedTabIndex,
        children: [
          _buildDevelopmentTab(character),
          _buildAppearanceTab(character),
          _buildSettingsTab(character),
        ],
      ),
    );
  }

  Widget _buildDevelopmentTab(dynamic character) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF171C30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8D95FF).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📈 Charakterentwicklung',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 16),
          
          // Progress Chart
          _buildProgressChart(character),
          const SizedBox(height: 24),
          
          // Recent Stories
          const Text(
            '📚 Letzte Geschichten',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 12),
          
          _buildRecentStoriesList(),
        ],
      ),
    );
  }

  Widget _buildProgressChart(dynamic character) {
    final traits = [
      {'name': 'Mut', 'value': character.traits?.courage ?? 50, 'color': const Color(0xFF8D95FF)},
      {'name': 'Stärke', 'value': character.traits?.strength ?? 50, 'color': const Color(0xFF9EF0DE)},
      {'name': 'Kreativität', 'value': character.traits?.creativity ?? 50, 'color': const Color(0xFFFF9BC4)},
      {'name': 'Weisheit', 'value': character.traits?.wisdom ?? 50, 'color': const Color(0xFFFFD489)},
    ];

    return Column(
      children: traits.map((trait) {
        final value = trait['value'] as int;
        final color = trait['color'] as Color;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  trait['name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFCBD5E1),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecentStoriesList() {
    final stories = [
      {'title': 'Das magische Abenteuer', 'date': '2 Tage', 'progress': 1.0},
      {'title': 'Die Wolkenbahn', 'date': '1 Woche', 'progress': 0.6},
      {'title': 'Unterwasser-Expedition', 'date': '2 Wochen', 'progress': 0.3},
    ];

    return Column(
      children: stories.map((story) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF8D95FF).withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF8D95FF).withOpacity(0.3),
                      const Color(0xFF9EF0DE).withOpacity(0.3),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('📖', style: TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF8FAFC),
                      ),
                    ),
                    Text(
                      'vor ${story['date']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFCBD5E1),
                      ),
                    ),
                  ],
                ),
              ),
              CircularProgressIndicator(
                value: story['progress'] as double,
                backgroundColor: const Color(0xFF8D95FF).withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8D95FF)),
                strokeWidth: 3,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAppearanceTab(dynamic character) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF171C30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8D95FF).withOpacity(0.2),
        ),
      ),
      child: const Column(
        children: [
          Icon(Icons.palette_rounded, size: 64, color: Color(0xFF8D95FF)),
          SizedBox(height: 16),
          Text(
            'Avatar-Anpassung',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF8FAFC),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Hier kannst du das Aussehen deines Avatars anpassen.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFFCBD5E1),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          Text(
            'Coming Soon! 🎨',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF8D95FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTab(dynamic character) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF171C30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF8D95FF).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚙️ Avatar-Einstellungen',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFF8FAFC),
            ),
          ),
          const SizedBox(height: 20),
          
          _buildSettingItem(
            icon: Icons.public_rounded,
            title: 'Öffentlich sichtbar',
            subtitle: 'Anderen Nutzern in der Community zeigen',
            value: character.isPublic ?? false,
            onChanged: (value) {
              // Update character visibility
            },
          ),
          const SizedBox(height: 16),
          
          _buildSettingItem(
            icon: Icons.notifications_rounded,
            title: 'Benachrichtigungen',
            subtitle: 'Über neue Geschichten informieren',
            value: true,
            onChanged: (value) {
              // Update notifications
            },
          ),
          const SizedBox(height: 24),
          
          // Delete Button
          GestureDetector(
            onTap: () {
              _showDeleteDialog();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF89B3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF89B3).withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.delete_outline_rounded, color: Color(0xFFFF89B3)),
                  SizedBox(width: 12),
                  Text(
                    'Avatar löschen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF89B3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF8D95FF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: const Color(0xFF8D95FF), size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFF8FAFC),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFFCBD5E1),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF8D95FF),
        ),
      ],
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF171C30),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Avatar löschen?',
          style: TextStyle(color: Color(0xFFF8FAFC)),
        ),
        content: const Text(
          'Dieser Vorgang kann nicht rückgängig gemacht werden. Alle Geschichten mit diesem Avatar bleiben erhalten.',
          style: TextStyle(color: Color(0xFFCBD5E1)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen', style: TextStyle(color: Color(0xFF8D95FF))),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Delete character
              context.go('/characters');
            },
            child: const Text('Löschen', style: TextStyle(color: Color(0xFFFF89B3))),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState() {
    return AppScaffold(
      title: 'Avatar nicht gefunden',
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Color(0xFF475569)),
            SizedBox(height: 16),
            Text(
              'Avatar nicht gefunden',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      backgroundColor: Color(0xFF0E1324),
      body: Center(
        child: CircularProgressIndicator(color: Color(0xFF8D95FF)),
      ),
    );
  }

  Widget _buildErrorState() {
    return AppScaffold(
      title: 'Fehler',
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Color(0xFFFF89B3)),
            SizedBox(height: 16),
            Text(
              'Fehler beim Laden',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}