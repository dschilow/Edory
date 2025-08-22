// lib/features/characters/presentation/pages/characters_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/gradient_card.dart';
import '../../../../shared/presentation/widgets/stats_row.dart';
import '../providers/characters_provider.dart';
import '../widgets/character_card.dart';
import '../../domain/entities/character.dart';

/// Überarbeitete Characters Page für Avatales - Ohne Overflow
/// Verwaltet Charaktere mit modernem Design und fehlerfreiem Layout
class CharactersPage extends ConsumerStatefulWidget {
  const CharactersPage({super.key});

  @override
  ConsumerState<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends ConsumerState<CharactersPage>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late AnimationController _refreshController;
  
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'Alle';
  String _searchQuery = '';
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // Load characters when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCharacters();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _refreshController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadCharacters() async {
    try {
      await ref.read(charactersProvider.notifier).loadCharacters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Laden: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final charactersState = ref.watch(charactersProvider);

    return AppScaffold(
      title: 'Avatare',
      subtitle: 'Deine digitalen Helden verwalten',
      showBackButton: false, // Top-level page
      actions: [
        _buildViewToggle(),
        _buildCreateButton(),
      ],
      floatingActionButton: _buildFAB(),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Search and Filter Bar
            SliverToBoxAdapter(
              child: _buildSearchAndFilter()
                  .animate(controller: _animationController)
                  .slideY(begin: -0.3, duration: 600.ms)
                  .fadeIn(),
            ),
            
            // Stats Overview
            SliverToBoxAdapter(
              child: _buildStatsOverview(charactersState)
                  .animate(controller: _animationController)
                  .slideY(begin: -0.2, duration: 600.ms, delay: 200.ms)
                  .fadeIn(),
            ),
            
            // Characters Content
            charactersState.when(
              data: (characters) => _buildCharactersContent(characters),
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(error),
            ),
            
            // Bottom spacing
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewButton(
            icon: Icons.grid_view,
            isSelected: _isGridView,
            onTap: () => setState(() => _isGridView = true),
          ),
          _buildViewButton(
            icon: Icons.view_list,
            isSelected: !_isGridView,
            onTap: () => setState(() => _isGridView = false),
          ),
        ],
      ),
    );
  }

  Widget _buildViewButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? ModernDesignSystem.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: ModernDesignSystem.primaryGradient,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: ModernDesignSystem.primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.go('/characters/create'),
          child: const Icon(
            Icons.add,
            size: 20,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Avatare durchsuchen...',
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Alle', 'Favoriten', 'Zuletzt verwendet', 'Neu']
                  .map((filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _buildFilterChip(filter),
                  ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter) {
    final isSelected = _selectedFilter == filter;
    
    return FilterChip(
      label: Text(filter),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _selectedFilter = selected ? filter : 'Alle');
      },
      backgroundColor: Colors.white,
      selectedColor: ModernDesignSystem.primaryColor.withOpacity(0.1),
      checkmarkColor: ModernDesignSystem.primaryColor,
      side: BorderSide(
        color: isSelected 
            ? ModernDesignSystem.primaryColor 
            : Colors.grey.shade300,
      ),
      labelStyle: TextStyle(
        color: isSelected 
            ? ModernDesignSystem.primaryColor 
            : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }

  Widget _buildStatsOverview(AsyncValue<List<Character>> charactersState) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: charactersState.when(
        data: (characters) => StatsRow(
          stats: [
            StatData(
              icon: '👤',
              value: characters.length.toString(),
              label: 'Avatare',
              gradient: ModernDesignSystem.primaryGradient,
            ),
            StatData(
              icon: '⭐',
              value: characters.where((c) => c.level >= 5).length.toString(),
              label: 'Erfahren',
              gradient: ModernDesignSystem.orangeGradient,
            ),
            StatData(
              icon: '🏆',
              value: _getAverageLevel(characters).toStringAsFixed(1),
              label: 'Ø Level',
              gradient: ModernDesignSystem.greenGradient,
            ),
          ],
        ),
        loading: () => _buildStatsPlaceholder(),
        error: (_, __) => _buildStatsPlaceholder(),
      ),
    );
  }

  double _getAverageLevel(List<Character> characters) {
    if (characters.isEmpty) return 0;
    return characters.map((c) => c.level).reduce((a, b) => a + b) / characters.length;
  }

  Widget _buildStatsPlaceholder() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildCharactersContent(List<Character> characters) {
    final filteredCharacters = _filterCharacters(characters);
    
    if (filteredCharacters.isEmpty) {
      return _buildEmptyState();
    }
    
    return _isGridView 
        ? _buildCharactersGrid(filteredCharacters)
        : _buildCharactersList(filteredCharacters);
  }

  List<Character> _filterCharacters(List<Character> characters) {
    var filtered = characters.where((character) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!character.displayName.toLowerCase().contains(query) &&
            !character.description.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Category filter
      switch (_selectedFilter) {
        case 'Favoriten':
          // TODO: Implement favorites functionality
          return false;
        case 'Zuletzt verwendet':
          return character.lastInteractionAt != null;
        case 'Neu':
          final daysSinceCreation = DateTime.now().difference(character.createdAt).inDays;
          return daysSinceCreation <= 7;
        default:
          return true;
      }
    }).toList();
    
    // Sort by last interaction or creation date
    filtered.sort((a, b) {
      final aTime = a.lastInteractionAt ?? a.createdAt;
      final bTime = b.lastInteractionAt ?? b.createdAt;
      return bTime.compareTo(aTime);
    });
    
    return filtered;
  }

  Widget _buildCharactersGrid(List<Character> characters) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < characters.length) {
              return _buildCharacterGridItem(characters[index], index);
            } else {
              return _buildAddCharacterCard();
            }
          },
          childCount: characters.length + 1,
        ),
      ),
    );
  }

  Widget _buildCharactersList(List<Character> characters) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index < characters.length) {
              return _buildCharacterListItem(characters[index], index);
            } else {
              return _buildAddCharacterListItem();
            }
          },
          childCount: characters.length + 1,
        ),
      ),
    );
  }

  Widget _buildCharacterGridItem(Character character, int index) {
    return CharacterCard(
      character: character,
      onTap: () => context.go('/characters/${character.id}'),
      isSelectable: false,
    )
        .animate(delay: (index * 100).ms)
        .slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOutCubic)
        .fadeIn();
  }

  Widget _buildCharacterListItem(Character character, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GradientCard(
        child: ListTile(
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: ModernDesignSystem.primaryColor,
            child: Text(
              character.displayName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          title: Text(
            character.displayName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                character.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 16,
                    color: ModernDesignSystem.primaryOrange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Level ${character.level}',
                    style: TextStyle(
                      color: ModernDesignSystem.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Icon(
            Icons.chevron_right,
            color: ModernDesignSystem.secondaryTextColor,
          ),
          onTap: () => context.go('/characters/${character.id}'),
        ),
      ),
    )
        .animate(delay: (index * 100).ms)
        .slideX(begin: -0.3, duration: 600.ms)
        .fadeIn();
  }

  Widget _buildAddCharacterCard() {
    return GestureDetector(
      onTap: () => context.go('/characters/create'),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ModernDesignSystem.primaryColor.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: ModernDesignSystem.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                size: 32,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Neuer Avatar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: ModernDesignSystem.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'Erstelle einen\nneuen Charakter',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ModernDesignSystem.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCharacterListItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: GradientCard(
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: ModernDesignSystem.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            'Neuen Avatar erstellen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: ModernDesignSystem.primaryColor,
            ),
          ),
          subtitle: const Text('Erschaffe deinen digitalen Helden'),
          trailing: Icon(
            Icons.arrow_forward_ios,
            color: ModernDesignSystem.primaryColor,
            size: 16,
          ),
          onTap: () => context.go('/characters/create'),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: GradientCard(
          child: Column(
            children: [
              Icon(
                Icons.person_add_rounded,
                size: 64,
                color: ModernDesignSystem.secondaryTextColor,
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty 
                    ? 'Keine Avatare gefunden'
                    : 'Noch keine Avatare erstellt',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Versuche einen anderen Suchbegriff'
                    : 'Erstelle deinen ersten Avatar und beginne dein Abenteuer!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ModernDesignSystem.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/characters/create'),
                icon: const Icon(Icons.add),
                label: const Text('Avatar erstellen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ModernDesignSystem.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          childAspectRatio: 0.8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildCharacterPlaceholder(),
          childCount: 6,
        ),
      ),
    );
  }

  Widget _buildCharacterPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: GradientCard(
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Fehler beim Laden',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ModernDesignSystem.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadCharacters,
                icon: const Icon(Icons.refresh),
                label: const Text('Erneut versuchen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => context.go('/characters/create-avatar'),
      backgroundColor: ModernDesignSystem.primaryColor,
      icon: const Icon(Icons.auto_awesome, color: Colors.white),
      label: const Text(
        'Avatar erstellen',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper Methods
  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 600) return 3;
    if (width > 400) return 2;
    return 1;
  }

  Future<void> _onRefresh() async {
    _refreshController.forward();
    await _loadCharacters();
    _refreshController.reset();
  }
}