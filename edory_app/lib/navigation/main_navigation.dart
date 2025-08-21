// Avatales.Navigation.MainNavigation
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/theme/app_colors.dart';
import 'package:edory_app/screens/home_screen.dart';
import 'package:edory_app/screens/profile_screen.dart';
import 'package:edory_app/screens/search_screen.dart';
import 'package:edory_app/screens/favorites_screen.dart';
import 'package:edory_app/screens/create_avatar_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late List<AnimationController> _iconControllers;
  late List<Animation<double>> _iconAnimations;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Home',
      color: AppColors.primaryBlue,
    ),
    NavigationItem(
      icon: Icons.search_outlined,
      activeIcon: Icons.search,
      label: 'Suchen',
      color: AppColors.primaryMint,
    ),
    NavigationItem(
      icon: Icons.add_circle_outline,
      activeIcon: Icons.add_circle,
      label: 'Erstellen',
      color: AppColors.primaryPink,
      isCenter: true,
    ),
    NavigationItem(
      icon: Icons.favorite_outline,
      activeIcon: Icons.favorite,
      label: 'Favoriten',
      color: AppColors.primaryPurple,
    ),
    NavigationItem(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profil',
      color: AppColors.primaryPeach,
    ),
  ];

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const CreateAvatarScreen(),
    const FavoritesScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _iconControllers = List.generate(
      _navigationItems.length,
      (index) => AnimationController(
        duration: AppTheme.animationMedium,
        vsync: this,
      ),
    );

    _iconAnimations = _iconControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: AppTheme.elasticOutCurve),
      );
    }).toList();

    // Aktiviere die erste Animation
    _iconControllers[0].forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _iconControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Animation für den aktuellen Index rückgängig machen
    _iconControllers[_currentIndex].reverse();

    setState(() {
      _currentIndex = index;
    });

    // Neue Animation starten
    _iconControllers[index].forward();

    // Seite wechseln
    _pageController.animateToPage(
      index,
      duration: AppTheme.animationMedium,
      curve: AppTheme.animationCurve,
    );
  }

  Widget _buildNavigationItem(NavigationItem item, int index) {
    final isActive = _currentIndex == index;
    final animation = _iconAnimations[index];

    if (item.isCenter) {
      return _buildCenterNavigationItem(item, index, animation);
    }

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _onItemTapped(index),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppTheme.paddingSmall,
              horizontal: AppTheme.paddingMedium,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: AppTheme.animationMedium,
                  curve: AppTheme.animationCurve,
                  padding: EdgeInsets.all(
                    AppTheme.paddingSmall + (animation.value * 4),
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? item.color.withOpacity(0.15)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(
                      AppTheme.borderRadiusSmall + (animation.value * 4),
                    ),
                  ),
                  child: Transform.scale(
                    scale: 1.0 + (animation.value * 0.2),
                    child: Icon(
                      isActive ? item.activeIcon : item.icon,
                      color: isActive ? item.color : AppColors.secondaryText,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: AppTheme.animationMedium,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? item.color : AppColors.secondaryText,
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCenterNavigationItem(
    NavigationItem item,
    int index,
    Animation<double> animation,
  ) {
    final isActive = _currentIndex == index;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return GestureDetector(
          onTap: () => _onItemTapped(index),
          child: Container(
            width: 56 + (animation.value * 8),
            height: 56 + (animation.value * 8),
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              gradient: isActive
                  ? AppColors.createCustomGradient(
                      startColor: item.color,
                      endColor: AppColors.primaryPurple,
                    )
                  : null,
              color: isActive ? null : AppColors.lightGray,
              shape: BoxShape.circle,
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: item.color.withOpacity(0.4),
                        blurRadius: 16 + (animation.value * 8),
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : AppTheme.softShadow,
            ),
            child: Transform.scale(
              scale: 1.0 + (animation.value * 0.1),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive ? AppColors.white : AppColors.secondaryText,
                size: 28,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowMedium,
            blurRadius: 20,
            offset: const Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.borderRadiusLarge),
        ),
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
            vertical: AppTheme.paddingSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navigationItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildNavigationItem(item, index);
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      extendBody: true,
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;
  final bool isCenter;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.color,
    this.isCenter = false,
  });
}