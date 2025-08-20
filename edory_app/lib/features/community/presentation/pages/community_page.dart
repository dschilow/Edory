// lib/features/community/presentation/pages/community_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/gradient_card.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  String _selectedTab = 'Entdecken';
  final List<String> _tabs = ['Entdecken', 'Beliebt', 'Neu', 'Meine'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: ModernDesignSystem.durationMedium,
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Community',
      subtitle: 'Entdecke und teile Charaktere',
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 150), // Account for app bar
                
                // Search Bar
                _buildSearchBar(),
                
                const SizedBox(height: 24),
                
                // Tab Selector
                _buildTabSelector(),
                
                const SizedBox(height: 24),
                
                // Community Stats
                _buildCommunityStats(),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
          
          // Character Gallery
          _buildCharacterGallery(),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GradientCard(
        animationDelay: 100.ms,
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Charaktere suchen...',
            hintStyle: TextStyle(color: ModernDesignSystem.textSecondary),
            prefixIcon: Icon(
              CupertinoIcons.search,
              color: ModernDesignSystem.textSecondary,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
          style: TextStyle(color: ModernDesignSystem.textPrimary),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: ModernDesignSystem.systemGray6.withOpacity(0.5),
          borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
        ),
        child: Row(
          children: _tabs.map((tab) {
            final isSelected = _selectedTab == tab;
            return Expanded(
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(vertical: 8),
                onPressed: () => setState(() => _selectedTab = tab),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSmall),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: Text(
                    tab,
                    style: TextStyle(
                      color: isSelected ? ModernDesignSystem.textPrimary : ModernDesignSystem.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildCommunityStats() {
    return GradientCard(
      animationDelay: 200.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🌟', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Community-Highlights',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: ModernDesignSystem.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildStatCard('2.4k', 'Charaktere\ngeteilt')),
              Expanded(child: _buildStatCard('890', 'Aktive\nNutzer')),
              Expanded(child: _buildStatCard('4.8', 'Bewertung\n⭐⭐⭐⭐⭐')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: ModernDesignSystem.systemGray6.withOpacity(0.3),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSmall),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: ModernDesignSystem.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ModernDesignSystem.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterGallery() {
    // Demo Community Characters
    final characters = [
      _CommunityCharacter('Luna die Zauberkatze', 'Max M.', '4.9', '🐱'),
      _CommunityCharacter('Captain Sternwind', 'Anna K.', '4.8', '🚀'),
      _CommunityCharacter('Pixel der Roboter', 'Tom B.', '4.7', '🤖'),
      _CommunityCharacter('Flora Naturherz', 'Lisa S.', '4.9', '🌸'),
      _CommunityCharacter('Shadow der Ninja', 'Ben W.', '4.6', '🥷'),
      _CommunityCharacter('Melody Musikzauber', 'Emma R.', '4.8', '🎵'),
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final character = characters[index];
            return GradientCard(
              animationDelay: (300 + index * 100).ms,
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showCharacterDetails(character),
                child: Column(
                  children: [
                    // Character Avatar
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ModernDesignSystem.systemBlue,
                            ModernDesignSystem.systemPurple,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Center(
                        child: Text(
                          character.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    
                    // Character Name
                    Text(
                      character.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ModernDesignSystem.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Creator
                    Text(
                      'von ${character.creator}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ModernDesignSystem.textSecondary,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: ModernDesignSystem.systemYellow,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          character.rating,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ModernDesignSystem.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          childCount: characters.length,
        ),
      ),
    );
  }

  void _showCharacterDetails(_CommunityCharacter character) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(character.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(character.emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text('Erstellt von ${character.creator}'),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: ModernDesignSystem.systemYellow, size: 16),
                Text(' ${character.rating} Bewertung'),
              ],
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              // TODO: Import character functionality
            },
            child: const Text('Importieren'),
          ),
        ],
      ),
    );
  }
}

class _CommunityCharacter {
  final String name;
  final String creator;
  final String rating;
  final String emoji;

  _CommunityCharacter(this.name, this.creator, this.rating, this.emoji);
}
