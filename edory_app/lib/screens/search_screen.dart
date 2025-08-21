// Avatales.Screens.SearchScreen
import 'package:flutter/material.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/theme/app_colors.dart';
import 'package:edory_app/shared/presentation/widgets/gradient_background.dart';
import 'package:edory_app/shared/presentation/widgets/animated_card.dart';
import 'package:edory_app/shared/presentation/widgets/custom_button.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with TickerProviderStateMixin {
  late AnimationController _searchController;
  late AnimationController _resultsController;
  late Animation<double> _searchAnimation;
  late Animation<double> _resultsAnimation;

  final TextEditingController _searchTextController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  bool _isSearching = false;
  bool _hasResults = false;
  String _searchQuery = '';
  List<String> _recentSearches = [
    'Gaming Avatare',
    'Anime Charaktere',
    'Fantasy Heroes',
    'Cute Animals',
  ];

  List<String> _trendingTags = [
    '#Gaming',
    '#Anime',
    '#Kawaii',
    '#Fantasy',
    '#Cyberpunk',
    '#Minimalist',
    '#Colorful',
    '#Dark',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupSearchListener();
  }

  void _initializeAnimations() {
    _searchController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _resultsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _searchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _searchController,
      curve: AppTheme.elasticOutCurve,
    ));

    _resultsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultsController,
      curve: Curves.easeOutBack,
    ));

    // Starte die initiale Animation
    Future.delayed(const Duration(milliseconds: 200), () {
      _searchController.forward();
    });
  }

  void _setupSearchListener() {
    _searchTextController.addListener(() {
      setState(() {
        _searchQuery = _searchTextController.text;
        _isSearching = _searchQuery.isNotEmpty;
        _hasResults = _searchQuery.length > 2;
      });

      if (_hasResults) {
        _resultsController.forward();
      } else {
        _resultsController.reverse();
      }
    });

    _searchFocusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _resultsController.dispose();
    _searchTextController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _buildSearchHeader() {
    return AnimatedBuilder(
      animation: _searchAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _searchAnimation.value)),
          child: Opacity(
            opacity: _searchAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppTheme.paddingMedium),
            Text(
              'Entdecke Avatare',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryText,
              ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              'Finde den perfekten Avatar für dich',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildSearchBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return AnimatedCard(
      backgroundColor: AppColors.white,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
      customShadow: _searchFocusNode.hasFocus
          ? [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ]
          : AppTheme.softShadow,
      child: TextField(
        controller: _searchTextController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Avatar suchen...',
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.primaryBlue,
          ),
          suffixIcon: _isSearching
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                  color: AppColors.secondaryText,
                )
              : IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _searchByImage,
                  color: AppColors.secondaryText,
                ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: AppTheme.paddingMedium,
          ),
          hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (_isSearching || _recentSearches.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Letzte Suchen',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              CustomButton(
                text: 'Löschen',
                type: ButtonType.ghost,
                size: ButtonSize.small,
                onPressed: _clearRecentSearches,
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          ..._recentSearches.map((search) => _buildRecentSearchItem(search)),
        ],
      ),
    );
  }

  Widget _buildRecentSearchItem(String search) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingSmall),
      child: AnimatedCard(
        onTap: () => _performSearch(search),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(AppTheme.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: const Icon(
              Icons.history,
              color: AppColors.primaryBlue,
              size: 20,
            ),
          ),
          title: Text(search),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => _removeRecentSearch(search),
            color: AppColors.secondaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingSection() {
    if (_isSearching) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trending Tags',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Wrap(
            spacing: AppTheme.paddingSmall,
            runSpacing: AppTheme.paddingSmall,
            children: _trendingTags.map((tag) => _buildTrendingTag(tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingTag(String tag) {
    final colors = [
      AppColors.primaryBlue,
      AppColors.primaryPink,
      AppColors.primaryMint,
      AppColors.primaryPurple,
      AppColors.primaryPeach,
      AppColors.primaryLavender,
    ];
    
    final color = colors[tag.hashCode % colors.length];

    return GestureDetector(
      onTap: () => _performSearch(tag),
      child: AnimatedContainer(
        duration: AppTheme.animationMedium,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingMedium,
          vertical: AppTheme.paddingSmall,
        ),
        decoration: BoxDecoration(
          gradient: AppColors.createCustomGradient(
            startColor: color.withOpacity(0.2),
            endColor: color.withOpacity(0.1),
          ),
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          tag,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (!_hasResults) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _resultsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _resultsAnimation.value)),
          child: Opacity(
            opacity: _resultsAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suchergebnisse für "$_searchQuery"',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            _buildFilterChips(),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildResultsGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Alle', 'Neu', 'Beliebt', 'Bewertung'];
    
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = index == 0; // Erstes Element ist ausgewählt
          
          return Container(
            margin: const EdgeInsets.only(right: AppTheme.paddingSmall),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) => _filterResults(filter),
              backgroundColor: AppColors.lightGray,
              selectedColor: AppColors.primaryBlue,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.white : AppColors.primaryText,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppTheme.paddingMedium,
        mainAxisSpacing: AppTheme.paddingMedium,
      ),
      itemCount: 8,
      itemBuilder: (context, index) {
        return _buildResultItem(index);
      },
    );
  }

  Widget _buildResultItem(int index) {
    final colors = [
      AppColors.primaryBlue,
      AppColors.primaryPink,
      AppColors.primaryMint,
      AppColors.primaryPurple,
      AppColors.primaryPeach,
      AppColors.primaryLavender,
    ];
    
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () => _viewAvatar(index),
      child: AnimatedCard(
        gradient: AppColors.createCustomGradient(
          startColor: color,
          endColor: color.withOpacity(0.7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: const Center(
                  child: Icon(
                    Icons.account_circle,
                    size: 60,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              'Avatar ${index + 1}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                const Icon(
                  Icons.star,
                  color: AppColors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '4.${8 - (index % 3)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
                const Spacer(),
                const Icon(
                  Icons.favorite_outline,
                  color: AppColors.white,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Event Handlers
  void _clearSearch() {
    _searchTextController.clear();
    _searchFocusNode.unfocus();
  }

  void _searchByImage() {
    // Implementierung für Bildsuche
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bildsuche wird geöffnet...'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _performSearch(String query) {
    _searchTextController.text = query;
    _searchFocusNode.unfocus();
    
    // Zur Liste der letzten Suchen hinzufügen
    if (!_recentSearches.contains(query)) {
      setState(() {
        _recentSearches.insert(0, query);
        if (_recentSearches.length > 5) {
          _recentSearches.removeLast();
        }
      });
    }
  }

  void _clearRecentSearches() {
    setState(() {
      _recentSearches.clear();
    });
  }

  void _removeRecentSearch(String search) {
    setState(() {
      _recentSearches.remove(search);
    });
  }

  void _filterResults(String filter) {
    // Implementierung für Filter
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filter: $filter'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _viewAvatar(int index) {
    Navigator.pushNamed(context, '/avatar-detail', arguments: index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CloudBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildSearchHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildRecentSearches(),
                      _buildTrendingSection(),
                      _buildSearchResults(),
                      const SizedBox(height: AppTheme.paddingXLarge * 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}