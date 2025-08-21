// Avatales.Screens.FavoritesScreen
import 'package:flutter/material.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/theme/app_colors.dart';
import 'package:edory_app/shared/presentation/widgets/gradient_background.dart';
import 'package:edory_app/shared/presentation/widgets/animated_card.dart';
import 'package:edory_app/shared/presentation/widgets/custom_button.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _listController;
  late Animation<double> _headerAnimation;
  late Animation<double> _listAnimation;

  bool _hasContent = true;
  int _selectedFilter = 0;
  bool _isGridView = true;

  final List<String> _filterOptions = [
    'Alle',
    'Kürzlich',
    'Meist gelikt',
    'Kategorien',
  ];

  final List<FavoriteAvatar> _favoriteAvatars = [
    FavoriteAvatar(
      id: '1',
      name: 'Cyber Ninja',
      category: 'Gaming',
      author: 'PixelMaster',
      likes: 1245,
      dateAdded: DateTime.now().subtract(const Duration(days: 2)),
      color: AppColors.primaryBlue,
    ),
    FavoriteAvatar(
      id: '2',
      name: 'Kawaii Cat',
      category: 'Anime',
      author: 'CuteDesigner',
      likes: 892,
      dateAdded: DateTime.now().subtract(const Duration(days: 5)),
      color: AppColors.primaryPink,
    ),
    FavoriteAvatar(
      id: '3',
      name: 'Forest Guardian',
      category: 'Fantasy',
      author: 'MysticArt',
      likes: 2103,
      dateAdded: DateTime.now().subtract(const Duration(days: 1)),
      color: AppColors.primaryMint,
    ),
    FavoriteAvatar(
      id: '4',
      name: 'Space Explorer',
      category: 'Sci-Fi',
      author: 'CosmicCreator',
      likes: 567,
      dateAdded: DateTime.now().subtract(const Duration(days: 7)),
      color: AppColors.primaryPurple,
    ),
    FavoriteAvatar(
      id: '5',
      name: 'Royal Dragon',
      category: 'Fantasy',
      author: 'DragonLord',
      likes: 3456,
      dateAdded: DateTime.now().subtract(const Duration(days: 3)),
      color: AppColors.primaryPeach,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _listController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: AppTheme.elasticOutCurve,
    ));

    _listAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _listController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _headerController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _listController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Favoriten',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingSmall / 2),
                    Text(
                      '${_favoriteAvatars.length} gespeicherte Avatare',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isGridView ? Icons.view_list : Icons.grid_view,
                        color: AppColors.primaryBlue,
                      ),
                      onPressed: () => _toggleViewMode(),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.sort,
                        color: AppColors.primaryBlue,
                      ),
                      onPressed: () => _showSortOptions(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildFilterTabs(),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedFilter == index;
          
          return Container(
            margin: const EdgeInsets.only(right: AppTheme.paddingSmall),
            child: GestureDetector(
              onTap: () => _selectFilter(index),
              child: AnimatedContainer(
                duration: AppTheme.animationMedium,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.paddingMedium,
                  vertical: AppTheme.paddingSmall,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? AppColors.createCustomGradient(
                          startColor: AppColors.primaryBlue,
                          endColor: AppColors.primaryMint,
                        )
                      : null,
                  color: isSelected ? null : AppColors.lightGray,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                ),
                child: Text(
                  _filterOptions[index],
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected ? AppColors.white : AppColors.primaryText,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    if (!_hasContent) {
      return _buildEmptyState();
    }

    return AnimatedBuilder(
      animation: _listAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _listAnimation.value)),
          child: Opacity(
            opacity: _listAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
        child: _isGridView ? _buildGridView() : _buildListView(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingXLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppColors.createCustomGradient(
                startColor: AppColors.primaryPink.withOpacity(0.3),
                endColor: AppColors.primaryBlue.withOpacity(0.3),
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              size: 60,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppTheme.paddingLarge),
          Text(
            'Noch keine Favoriten',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            'Entdecke Avatare und markiere sie als Favoriten,\num sie hier zu sammeln.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.secondaryText,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppTheme.paddingXLarge),
          GradientButton(
            text: 'Avatare entdecken',
            gradient: AppColors.createCustomGradient(
              startColor: AppColors.primaryBlue,
              endColor: AppColors.primaryMint,
            ),
            onPressed: () => _exploreAvatars(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: AppTheme.paddingMedium,
        mainAxisSpacing: AppTheme.paddingMedium,
      ),
      itemCount: _favoriteAvatars.length,
      itemBuilder: (context, index) {
        return _buildGridItem(_favoriteAvatars[index], index);
      },
    );
  }

  Widget _buildGridItem(FavoriteAvatar avatar, int index) {
    return GestureDetector(
      onTap: () => _viewAvatar(avatar),
      child: AnimatedCard(
        gradient: AppColors.createCustomGradient(
          startColor: avatar.color,
          endColor: avatar.color.withOpacity(0.7),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
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
                  Positioned(
                    top: AppTheme.paddingSmall,
                    right: AppTheme.paddingSmall,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(avatar),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.favorite,
                          color: AppColors.primaryPink,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              avatar.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'von ${avatar.author}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withOpacity(0.8),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppTheme.paddingSmall / 2),
            Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: AppColors.white,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatNumber(avatar.likes),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
                const Spacer(),
                Text(
                  avatar.category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _favoriteAvatars.length,
      itemBuilder: (context, index) {
        return _buildListItem(_favoriteAvatars[index], index);
      },
    );
  }

  Widget _buildListItem(FavoriteAvatar avatar, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      child: AnimatedCard(
        onTap: () => _viewAvatar(avatar),
        child: ListTile(
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.createCustomGradient(
                startColor: avatar.color,
                endColor: avatar.color.withOpacity(0.7),
              ),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: const Icon(
              Icons.account_circle,
              color: AppColors.white,
              size: 30,
            ),
          ),
          title: Text(
            avatar.name,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('von ${avatar.author}'),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.paddingSmall,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: avatar.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Text(
                      avatar.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: avatar.color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingSmall),
                  const Icon(
                    Icons.favorite,
                    size: 14,
                    color: AppColors.primaryPink,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _formatNumber(avatar.likes),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => _handleMenuAction(value, avatar),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'share',
                child: ListTile(
                  leading: Icon(Icons.share),
                  title: Text('Teilen'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'download',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Herunterladen'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: ListTile(
                  leading: Icon(Icons.delete, color: AppColors.error),
                  title: Text('Entfernen', style: TextStyle(color: AppColors.error)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Event Handlers
  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _selectFilter(int index) {
    setState(() {
      _selectedFilter = index;
    });
    
    // Hier würde die Filterlogik implementiert werden
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filter: ${_filterOptions[index]}'),
        backgroundColor: AppColors.primaryBlue,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.borderRadiusLarge),
          ),
        ),
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sortieren nach',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            ListTile(
              title: const Text('Datum hinzugefügt'),
              onTap: () => _sortBy('date'),
            ),
            ListTile(
              title: const Text('Name'),
              onTap: () => _sortBy('name'),
            ),
            ListTile(
              title: const Text('Beliebtheit'),
              onTap: () => _sortBy('likes'),
            ),
            ListTile(
              title: const Text('Kategorie'),
              onTap: () => _sortBy('category'),
            ),
          ],
        ),
      ),
    );
  }

  void _sortBy(String criteria) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sortiert nach $criteria'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _toggleFavorite(FavoriteAvatar avatar) {
    setState(() {
      _favoriteAvatars.remove(avatar);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${avatar.name} aus Favoriten entfernt'),
        backgroundColor: AppColors.error,
        action: SnackBarAction(
          label: 'Rückgängig',
          onPressed: () {
            setState(() {
              _favoriteAvatars.add(avatar);
            });
          },
        ),
      ),
    );
  }

  void _viewAvatar(FavoriteAvatar avatar) {
    Navigator.pushNamed(context, '/avatar-detail', arguments: avatar.id);
  }

  void _exploreAvatars() {
    // Wechsel zur Suchseite oder Explore-Seite
    DefaultTabController.of(context)?.animateTo(1); // Zur Search-Tab
  }

  void _handleMenuAction(String action, FavoriteAvatar avatar) {
    switch (action) {
      case 'share':
        _shareAvatar(avatar);
        break;
      case 'download':
        _downloadAvatar(avatar);
        break;
      case 'remove':
        _toggleFavorite(avatar);
        break;
    }
  }

  void _shareAvatar(FavoriteAvatar avatar) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${avatar.name} geteilt'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _downloadAvatar(FavoriteAvatar avatar) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${avatar.name} wird heruntergeladen...'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}k';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SunsetBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildContent(),
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

class FavoriteAvatar {
  final String id;
  final String name;
  final String category;
  final String author;
  final int likes;
  final DateTime dateAdded;
  final Color color;

  const FavoriteAvatar({
    required this.id,
    required this.name,
    required this.category,
    required this.author,
    required this.likes,
    required this.dateAdded,
    required this.color,
  });
}