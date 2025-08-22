// lib/features/stories/presentation/pages/stories_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';

class StoriesPage extends ConsumerStatefulWidget {
  const StoriesPage({super.key});

  @override
  ConsumerState<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends ConsumerState<StoriesPage>
    with TickerProviderStateMixin {
  
  late AnimationController _filterController;
  late AnimationController _gridController;
  
  String _selectedFilter = 'alle';
  final List<String> _filters = ['alle', 'fortsetzen', 'abgeschlossen'];

  @override
  void initState() {
    super.initState();
    
    _filterController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _gridController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _filterController.forward();
    _gridController.forward();
  }

  @override
  void dispose() {
    _filterController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Geschichten',
      subtitle: 'Deine magischen Abenteuer',
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 20),
          child: IconButton(
            onPressed: () => context.go('/stories/create'),
            icon: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6E77FF), Color(0xFF4B55E6)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6E77FF).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF6F8FF), // bg from JSON
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Filter Tabs
            SliverToBoxAdapter(
              child: _buildFilterTabs()
                .animate(controller: _filterController)
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.2, curve: Curves.easeOutCubic),
            ),
            
            // Statistics Overview
            SliverToBoxAdapter(
              child: _buildStatsOverview()
                .animate(controller: _filterController)
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideY(begin: 0.2, curve: Curves.easeOutCubic),
            ),
            
            // Stories Grid
            _buildStoriesGrid(),
            
            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40), // radius.xl
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected 
                    ? const Color(0xFF6E77FF)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: const Color(0xFF6E77FF).withOpacity(0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  _getFilterLabel(filter),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected 
                      ? Colors.white
                      : const Color(0xFF6E77FF),
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

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'alle': return 'Alle Geschichten';
      case 'fortsetzen': return 'Fortsetzen';
      case 'abgeschlossen': return 'Abgeschlossen';
      default: return filter;
    }
  }

  Widget _buildStatsOverview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6E77FF).withOpacity(0.1),
            const Color(0xFF8EE2D2).withOpacity(0.1),
            const Color(0xFFFF89B3).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF6E77FF).withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('📊', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Deine Statistiken',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildStatCard(
                icon: '📚',
                value: '12',
                label: 'Geschichten',
                color: const Color(0xFF6E77FF),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: '⏱️',
                value: '3.2h',
                label: 'Lesezeit',
                color: const Color(0xFF8EE2D2),
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: '🏆',
                value: '8',
                label: 'Abgeschlossen',
                color: const Color(0xFFFF89B3),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
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
                color: Color(0xFF475569),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesGrid() {
    final stories = _getFilteredStories();
    
    if (stories.isEmpty) {
      return SliverFillRemaining(
        child: _buildEmptyState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, // Single column für StoryTile
          mainAxisSpacing: 16,
          childAspectRatio: 2.8, // Breiter für Thumbnail + Text
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final story = stories[index];
            return _buildStoryTile(story, index)
              .animate(controller: _gridController)
              .fadeIn(
                delay: Duration(milliseconds: 100 * index),
                duration: 500.ms,
              )
              .slideY(
                begin: 0.3,
                curve: Curves.easeOutBack,
              );
          },
          childCount: stories.length,
        ),
      ),
    );
  }

  Widget _buildStoryTile(Map<String, dynamic> story, int index) {
    return GestureDetector(
      onTap: () => context.go('/stories/${story['id']}'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF6E77FF).withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Cover Image (16:9 aspect ratio)
            Container(
              width: 120,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getStoryGradient(index),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      story['emoji'] as String,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 4),
                    if (story['isNew'] == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF89B3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'NEU',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      story['title'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Meta: Avatar, Date, Progress
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6E77FF).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              (story['avatar'] as String).substring(0, 1),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6E77FF),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          story['avatar'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: Color(0xFF475569))),
                        const SizedBox(width: 8),
                        Text(
                          story['date'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Progress Bar
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Fortschritt',
                              style: TextStyle(
                                fontSize: 11,
                                color: const Color(0xFF475569).withOpacity(0.8),
                              ),
                            ),
                            Text(
                              '${((story['progress'] as double) * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6E77FF),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: story['progress'] as double,
                          backgroundColor: const Color(0xFF6E77FF).withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6E77FF)),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions Menu
            PopupMenuButton<String>(
              icon: const Icon(
                Icons.more_vert_rounded,
                color: Color(0xFF475569),
                size: 20,
              ),
              onSelected: (value) => _handleStoryAction(value, story),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'continue',
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow_rounded, size: 18, color: Color(0xFF6E77FF)),
                      SizedBox(width: 8),
                      Text('Fortsetzen'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share_rounded, size: 18, color: Color(0xFF8EE2D2)),
                      SizedBox(width: 8),
                      Text('Teilen'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFFF89B3)),
                      SizedBox(width: 8),
                      Text('Löschen'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  List<Color> _getStoryGradient(int index) {
    final gradients = [
      [const Color(0xFF6E77FF).withOpacity(0.3), const Color(0xFF8EE2D2).withOpacity(0.3)],
      [const Color(0xFF8EE2D2).withOpacity(0.3), const Color(0xFFFF89B3).withOpacity(0.3)],
      [const Color(0xFFFF89B3).withOpacity(0.3), const Color(0xFFFFC66E).withOpacity(0.3)],
      [const Color(0xFFFFC66E).withOpacity(0.3), const Color(0xFF9E8CFF).withOpacity(0.3)],
    ];
    return gradients[index % gradients.length];
  }

  List<Map<String, dynamic>> _getFilteredStories() {
    // Mock data - StoryTile Structure aus JSON
    final allStories = [
      {
        'id': '1',
        'title': 'Die Wolkenbahn',
        'avatar': 'Luna',
        'date': 'vor 2 Tagen',
        'progress': 0.6,
        'emoji': '🌙',
        'isNew': false,
        'isCompleted': false,
      },
      {
        'id': '2',
        'title': 'Das magische Abenteuer im Zauberwald',
        'avatar': 'Kiko',
        'date': 'vor 1 Woche',
        'progress': 1.0,
        'emoji': '🌲',
        'isNew': false,
        'isCompleted': true,
      },
      {
        'id': '3',
        'title': 'Unterwasser-Expedition',
        'avatar': 'Luna',
        'date': 'vor 3 Tagen',
        'progress': 0.3,
        'emoji': '🐠',
        'isNew': true,
        'isCompleted': false,
      },
      {
        'id': '4',
        'title': 'Der fliegende Teppich',
        'avatar': 'Max',
        'date': 'vor 2 Wochen',
        'progress': 0.8,
        'emoji': '🧞‍♂️',
        'isNew': false,
        'isCompleted': false,
      },
      {
        'id': '5',
        'title': 'Reise zu den Sternen',
        'avatar': 'Kiko',
        'date': 'vor 1 Monat',
        'progress': 1.0,
        'emoji': '🚀',
        'isNew': false,
        'isCompleted': true,
      },
    ];

    switch (_selectedFilter) {
      case 'fortsetzen':
        return allStories.where((story) => 
          (story['progress'] as double) < 1.0
        ).toList();
      case 'abgeschlossen':
        return allStories.where((story) => 
          story['isCompleted'] == true
        ).toList();
      default:
        return allStories;
    }
  }

  void _handleStoryAction(String action, Map<String, dynamic> story) {
    switch (action) {
      case 'continue':
        context.go('/stories/${story['id']}');
        break;
      case 'share':
        // Share story functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geschichte wird geteilt...'),
            backgroundColor: Color(0xFF8EE2D2),
          ),
        );
        break;
      case 'delete':
        _showDeleteDialog(story);
        break;
    }
  }

  void _showDeleteDialog(Map<String, dynamic> story) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Geschichte löschen?'),
        content: Text('Möchtest du "${story['title']}" wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen', style: TextStyle(color: Color(0xFF6E77FF))),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Delete story
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Geschichte wurde gelöscht'),
                  backgroundColor: Color(0xFFFF89B3),
                ),
              );
            },
            child: const Text('Löschen', style: TextStyle(color: Color(0xFFFF89B3))),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String title, subtitle, buttonText;
    String emoji = '☁️';
    
    switch (_selectedFilter) {
      case 'fortsetzen':
        title = 'Alle Geschichten gelesen!';
        subtitle = 'Du hast alle deine Geschichten abgeschlossen.';
        buttonText = 'Neue Geschichte erstellen';
        emoji = '🎉';
        break;
      case 'abgeschlossen':
        title = 'Noch keine Geschichten abgeschlossen';
        subtitle = 'Lies deine ersten Geschichten zu Ende.';
        buttonText = 'Geschichten ansehen';
        emoji = '📖';
        break;
      default:
        title = 'Noch keine Geschichten';
        subtitle = 'Erstelle deine erste magische Geschichte!';
        buttonText = 'Erste Geschichte erstellen';
        emoji = '✨';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6E77FF).withOpacity(0.1),
                    const Color(0xFF8EE2D2).withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 60)),
              ),
            ),
            const SizedBox(height: 24),
            
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF475569),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // CTA Button
            GestureDetector(
              onTap: () {
                if (_selectedFilter == 'abgeschlossen') {
                  setState(() => _selectedFilter = 'alle');
                } else {
                  context.go('/stories/create');
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6E77FF), Color(0xFF4B55E6)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6E77FF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      buttonText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}