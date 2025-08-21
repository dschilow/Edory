// Avatales.Screens.HomeScreen
import 'package:flutter/material.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/theme/app_colors.dart';
import 'package:edory_app/shared/presentation/widgets/gradient_background.dart';
import 'package:edory_app/shared/presentation/widgets/animated_card.dart';
import 'package:edory_app/shared/presentation/widgets/custom_button.dart' hide FloatingActionButton;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _cardsController;
  late Animation<double> _headerAnimation;
  late Animation<double> _cardsAnimation;

  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButton = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _startAnimations();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _cardsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: AppTheme.elasticOutCurve,
    ));

    _cardsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _cardsController,
      curve: Curves.easeOutBack,
    ));
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final showButton = _scrollController.offset > 200;
      if (showButton != _showFloatingButton) {
        setState(() {
          _showFloatingButton = showButton;
        });
      }
    });
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _headerController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _cardsController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _cardsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _headerAnimation.value)),
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
                      'Willkommen zurück',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: AppTheme.paddingSmall / 2),
                    Text(
                      'Avatar Explorer',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _navigateToProfile(),
                  child: AnimatedCard(
                    padding: const EdgeInsets.all(AppTheme.paddingSmall),
                    backgroundColor: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    child: const Icon(
                      Icons.person_outline,
                      color: AppColors.primaryBlue,
                      size: 28,
                    ),
                  ),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: AppColors.secondaryText,
            size: 20,
          ),
          const SizedBox(width: AppTheme.paddingSmall),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Avatare durchsuchen...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppTheme.paddingSmall),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: const Icon(
              Icons.tune,
              color: AppColors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return AnimatedBuilder(
      animation: _cardsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _cardsAnimation.value),
          child: Opacity(
            opacity: _cardsAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _buildStatCard(
              title: 'Gesamt Avatare',
              value: '1,234',
              icon: Icons.account_circle,
              gradient: AppColors.createCustomGradient(
                startColor: AppColors.primaryBlue,
                endColor: AppColors.primaryMint,
              ),
              onTap: () => _showStatsDetail('avatars'),
            ),
            _buildStatCard(
              title: 'Favoriten',
              value: '56',
              icon: Icons.favorite,
              gradient: AppColors.createCustomGradient(
                startColor: AppColors.primaryPink,
                endColor: AppColors.primaryPeach,
              ),
              onTap: () => _showStatsDetail('favorites'),
            ),
            _buildStatCard(
              title: 'Neu diese Woche',
              value: '+23',
              icon: Icons.trending_up,
              gradient: AppColors.createCustomGradient(
                startColor: AppColors.primaryPurple,
                endColor: AppColors.primaryLavender,
              ),
              onTap: () => _showStatsDetail('new'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: AppTheme.paddingMedium),
      child: GradientCard(
        gradient: gradient,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              decoration: BoxDecoration(
                color: AppColors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Icon(
                icon,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategorien',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              CustomButton(
                text: 'Alle anzeigen',
                type: ButtonType.ghost,
                size: ButtonSize.small,
                onPressed: () => _showAllCategories(),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          _buildCategoryGrid(),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {
        'title': 'Gaming',
        'subtitle': '234 Avatare',
        'icon': Icons.sports_esports,
        'color': AppColors.primaryBlue,
      },
      {
        'title': 'Anime',
        'subtitle': '189 Avatare',
        'icon': Icons.face,
        'color': AppColors.primaryPink,
      },
      {
        'title': 'Tiere',
        'subtitle': '156 Avatare',
        'icon': Icons.pets,
        'color': AppColors.primaryMint,
      },
      {
        'title': 'Fantasy',
        'subtitle': '98 Avatare',
        'icon': Icons.auto_awesome,
        'color': AppColors.primaryPurple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.3,
        crossAxisSpacing: AppTheme.paddingMedium,
        mainAxisSpacing: AppTheme.paddingMedium,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return FeatureCard(
          title: category['title'] as String,
          subtitle: category['subtitle'] as String,
          icon: Icon(
            category['icon'] as IconData,
            color: AppColors.white,
            size: 24,
          ),
          accentColor: category['color'] as Color,
          onTap: () => _navigateToCategory(category['title'] as String),
        );
      },
    );
  }

  Widget _buildRecentSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kürzlich hinzugefügt',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          _buildRecentAvatars(),
        ],
      ),
    );
  }

  Widget _buildRecentAvatars() {
    return Container(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: AppTheme.paddingMedium),
            child: AnimatedCard(
              onTap: () => _viewAvatar(index),
              gradient: AppColors.getGradient(['sky', 'sunset', 'dream', 'cloud'][index % 4]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.account_circle,
                        size: 40,
                        color: AppColors.white,
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
                  Text(
                    'Neu',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedScale(
      scale: _showFloatingButton ? 1.0 : 0.0,
      duration: AppTheme.animationMedium,
      curve: AppTheme.elasticOutCurve,
      child: FloatingActionButton(
        onPressed: () => _createNewAvatar(),
        child: const Icon(Icons.add),
        tooltip: 'Neuen Avatar erstellen',
      ),
    );
  }

  // Navigation Methods
  void _navigateToProfile() {
    Navigator.pushNamed(context, '/profile');
  }

  void _showStatsDetail(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$type Details werden geladen...'),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        ),
      ),
    );
  }

  void _showAllCategories() {
    Navigator.pushNamed(context, '/categories');
  }

  void _navigateToCategory(String category) {
    Navigator.pushNamed(context, '/category', arguments: category);
  }

  void _viewAvatar(int index) {
    Navigator.pushNamed(context, '/avatar', arguments: index);
  }

  void _createNewAvatar() {
    Navigator.pushNamed(context, '/create-avatar');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        gradient: AppColors.skyGradient,
        enableFloatingElements: true,
        enableParallax: true,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeader(),
            ),
            SliverToBoxAdapter(
              child: const SizedBox(height: AppTheme.paddingMedium),
            ),
            SliverToBoxAdapter(
              child: _buildStatsCards(),
            ),
            SliverToBoxAdapter(
              child: const SizedBox(height: AppTheme.paddingLarge),
            ),
            SliverToBoxAdapter(
              child: _buildCategoriesSection(),
            ),
            SliverToBoxAdapter(
              child: _buildRecentSection(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppTheme.paddingXLarge),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
}