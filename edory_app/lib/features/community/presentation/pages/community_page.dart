// lib/features/community/presentation/pages/community_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';

class CommunityPage extends ConsumerStatefulWidget {
  const CommunityPage({super.key});

  @override
  ConsumerState<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends ConsumerState<CommunityPage>
    with TickerProviderStateMixin {
  
  late AnimationController _searchAnimationController;
  late AnimationController _tabController;
  late AnimationController _gridController;
  late TabController _tabBarController;
  
  final _searchController = TextEditingController();
  String _selectedTab = 'Beliebt';
  String _searchQuery = '';
  
  final List<String> _tabs = ['Beliebt', 'Neu', 'Themen'];

  @override
  void initState() {
    super.initState();
    
    _searchAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _tabController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _gridController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tabBarController = TabController(length: _tabs.length, vsync: this);
    
    _searchAnimationController.forward();
    _tabController.forward();
    _gridController.forward();
    
    _tabBarController.addListener(() {
      if (_tabBarController.indexIsChanging) {
        setState(() => _selectedTab = _tabs[_tabBarController.index]);
      }
    });
  }

  @override
  void dispose() {
    _searchAnimationController.dispose();
    _tabController.dispose();
    _gridController.dispose();
    _tabBarController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Community',
      subtitle: 'Entdecke magische Geschichten',
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
            // Search Bar
            SliverToBoxAdapter(
              child: _buildSearchBar()
                .animate(controller: _searchAnimationController)
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.3, curve: Curves.easeOutCubic),
            ),
            
            // Tab Bar
            SliverToBoxAdapter(
              child: _buildTabBar()
                .animate(controller: _tabController)
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideX(begin: -0.2, curve: Curves.easeOutCubic),
            ),
            
            // Featured Section
            if (_selectedTab == 'Beliebt')
              SliverToBoxAdapter(
                child: _buildFeaturedSection()
                  .animate(controller: _gridController)
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutBack),
              ),
            
            // Content Grid
            _buildContentGrid(),
            
            // Bottom padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28), // lg corner
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
          const Icon(
            Icons.search_rounded,
            color: Color(0xFF6E77FF),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0F172A),
              ),
              decoration: const InputDecoration(
                hintText: 'Suche Geschichten oder Avatare',
                hintStyle: TextStyle(
                  color: Color(0xFF475569),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6E77FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Color(0xFF6E77FF),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: _tabs.map((tab) {
          final isSelected = _selectedTab == tab;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                final index = _tabs.indexOf(tab);
                _tabBarController.animateTo(index);
                setState(() => _selectedTab = tab);
              },
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
                  tab,
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

  Widget _buildFeaturedSection() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('⭐', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Featured',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6E77FF).withOpacity(0.2),
                  const Color(0xFF8EE2D2).withOpacity(0.2),
                  const Color(0xFFFF89B3).withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6E77FF).withOpacity(0.2),
              ),
            ),
            child: Stack(
              children: [
                // Background Pattern
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: StarPatternPainter(),
                    ),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Geschichte des Monats',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF6E77FF),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Das Geheimnis der Sternenfee',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Eine magische Reise durch das Sternenland mit Luna und ihren Freunden.',
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF475569).withOpacity(0.8),
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6E77FF), Color(0xFF4B55E6)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Jetzt lesen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      
                      Container(
                        width: 100,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text('🧚‍♀️', style: TextStyle(fontSize: 48)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentGrid() {
    final content = _getFilteredContent();
    
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = content[index];
            return _buildContentCard(item, index)
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
          childCount: content.length,
        ),
      ),
    );
  }

  Widget _buildContentCard(Map<String, dynamic> item, int index) {
    final isStory = item['type'] == 'story';
    
    return GestureDetector(
      onTap: () {
        if (isStory) {
          context.go('/stories/${item['id']}');
        } else {
          context.go('/characters/${item['id']}');
        }
      },
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover/Avatar Image
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getItemGradient(index),
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      item['emoji'] as String,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  
                  // Type Badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isStory 
                          ? const Color(0xFF6E77FF)
                          : const Color(0xFF8EE2D2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isStory ? 'Story' : 'Avatar',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  // Stats Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.favorite_rounded,
                            size: 12,
                            color: Color(0xFFFF89B3),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            item['likes'].toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Content Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      item['title'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Author
                    Row(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6E77FF).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              (item['author'] as String).substring(0, 1),
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6E77FF),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'von ${item['author']}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    
                    // Tags
                    if (item['tags'] != null)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: (item['tags'] as List<String>).take(2).map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6E77FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              tag,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFF6E77FF),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          );
                        }).toList(),
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

  List<Color> _getItemGradient(int index) {
    final gradients = [
      [const Color(0xFF6E77FF).withOpacity(0.3), const Color(0xFF8EE2D2).withOpacity(0.3)],
      [const Color(0xFF8EE2D2).withOpacity(0.3), const Color(0xFFFF89B3).withOpacity(0.3)],
      [const Color(0xFFFF89B3).withOpacity(0.3), const Color(0xFFFFC66E).withOpacity(0.3)],
      [const Color(0xFFFFC66E).withOpacity(0.3), const Color(0xFF9E8CFF).withOpacity(0.3)],
    ];
    return gradients[index % gradients.length];
  }

  List<Map<String, dynamic>> _getFilteredContent() {
    // Mock Community Data - StoryTile und AvatarTile
    final allContent = [
      {
        'id': '1',
        'type': 'story',
        'title': 'Die Reise zum Regenbogenschloss',
        'author': 'Emma',
        'emoji': '🌈',
        'likes': 142,
        'tags': ['Fantasy', 'Abenteuer', 'Magie'],
      },
      {
        'id': '2',
        'type': 'avatar',
        'title': 'Drachen-Ritter Finn',
        'author': 'Max',
        'emoji': '🐉',
        'likes': 89,
        'tags': ['Ritter', 'Mut', 'Drachen'],
      },
      {
        'id': '3',
        'type': 'story',
        'title': 'Das Geheimnis der Mondblumen',
        'author': 'Lila',
        'emoji': '🌙',
        'likes': 276,
        'tags': ['Mystisch', 'Nacht', 'Blumen'],
      },
      {
        'id': '4',
        'type': 'avatar',
        'title': 'Piratin Celeste',
        'author': 'Tom',
        'emoji': '🏴‍☠️',
        'likes': 156,
        'tags': ['Piraten', 'Abenteuer', 'Meer'],
      },
      {
        'id': '5',
        'type': 'story',
        'title': 'Der singende Wald',
        'author': 'Ana',
        'emoji': '🎵',
        'likes': 198,
        'tags': ['Musik', 'Wald', 'Tiere'],
      },
      {
        'id': '6',
        'type': 'avatar',
        'title': 'Zauberin Nova',
        'author': 'Sophie',
        'emoji': '🔮',
        'likes': 234,
        'tags': ['Magie', 'Zauberin', 'Sterne'],
      },
    ];

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      return allContent.where((item) =>
        (item['title'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
        (item['author'] as String).toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Filter by tab
    switch (_selectedTab) {
      case 'Beliebt':
        allContent.sort((a, b) => (b['likes'] as int).compareTo(a['likes'] as int));
        return allContent;
      case 'Neu':
        return allContent.reversed.toList(); // Mock: newest first
      case 'Themen':
        return allContent.where((item) => 
          (item['tags'] as List<String>).contains('Fantasy') ||
          (item['tags'] as List<String>).contains('Abenteuer')
        ).toList();
      default:
        return allContent;
    }
  }
}

// Custom Painter für Sterne-Muster im Featured Bereich
class StarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF6E77FF).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw small stars scattered across the canvas
    for (int i = 0; i < 20; i++) {
      final x = (i * 37) % size.width;
      final y = (i * 23) % size.height;
      _drawStar(canvas, paint, Offset(x, y), 3);
    }
  }

  void _drawStar(Canvas canvas, Paint paint, Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * 3.14159) / 5;
      final x = center.dx + radius * (i % 2 == 0 ? 1 : 0.5) * 
          (i % 2 == 0 ? 1 : 1) * (angle < 3.14159 ? 1 : -1).abs();
      final y = center.dy + radius * (i % 2 == 0 ? 1 : 0.5) * 
          (i % 2 == 0 ? 1 : 1) * (angle < 3.14159 ? 1 : -1).abs();
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}