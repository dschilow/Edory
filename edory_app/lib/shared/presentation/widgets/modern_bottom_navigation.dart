// lib/shared/presentation/widgets/modern_bottom_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../../core/theme/modern_design_system.dart';

/// Moderne Bottom Navigation für Avatales
/// Löst Overflow-Probleme und bietet glassmorphism Design
class ModernBottomNavigation extends StatefulWidget {
  const ModernBottomNavigation({
    super.key,
    required this.currentPath,
  });

  final String currentPath;

  @override
  State<ModernBottomNavigation> createState() => _ModernBottomNavigationState();
}

class _ModernBottomNavigationState extends State<ModernBottomNavigation>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late AnimationController _rippleController;
  
  int _previousIndex = 0;

  final List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home_rounded,
      activeIcon: Icons.home,
      label: 'Home',
      path: '/home',
      gradient: ModernDesignSystem.primaryGradient,
    ),
    _NavItem(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people,
      label: 'Avatare',
      path: '/characters',
      gradient: ModernDesignSystem.orangeGradient,
    ),
    _NavItem(
      icon: Icons.auto_stories_outlined,
      activeIcon: Icons.auto_stories,
      label: 'Geschichten',
      path: '/stories/create',
      gradient: ModernDesignSystem.greenGradient,
      isSpecial: true, // Center button
    ),
    _NavItem(
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book,
      label: 'Stories',
      path: '/stories',
      gradient: ModernDesignSystem.redGradient,
    ),
    _NavItem(
      icon: Icons.group_outlined,
      activeIcon: Icons.group,
      label: 'Community',
      path: '/community',
      gradient: const LinearGradient(
        colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  int get _currentIndex {
    final currentIndex = _navItems.indexWhere(
      (item) => widget.currentPath.startsWith(item.path),
    );
    return currentIndex >= 0 ? currentIndex : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 32,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              minimum: const EdgeInsets.only(bottom: 0),
              child: _buildNavigationContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _navItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isActive = index == _currentIndex;
          
          return Expanded(
            child: _buildNavItem(
              item: item,
              isActive: isActive,
              onTap: () => _onItemTapped(index, item),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNavItem({
    required _NavItem item,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    if (item.isSpecial) {
      return _buildSpecialNavItem(item, isActive, onTap);
    }
    
    return _buildRegularNavItem(item, isActive, onTap);
  }

  Widget _buildRegularNavItem(
    _NavItem item,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Container
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: isActive ? item.gradient : null,
                color: isActive ? null : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: item.gradient.colors.first.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                color: isActive ? Colors.white : Colors.grey.shade600,
                size: 24,
              ),
            )
                .animate(target: isActive ? 1 : 0)
                .scale(duration: 300.ms, curve: Curves.elasticOut),
            
            const SizedBox(height: 4),
            
            // Label
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isActive ? 11 : 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive 
                    ? item.gradient.colors.first
                    : Colors.grey.shade600,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialNavItem(
    _NavItem item,
    bool isActive,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Special floating button
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: item.gradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: item.gradient.colors.first.withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.9),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                color: Colors.white,
                size: 28,
              ),
            )
                .animate(target: isActive ? 1 : 0)
                .scale(duration: 300.ms, curve: Curves.elasticOut)
                .shimmer(
                  duration: 2000.ms,
                  color: Colors.white.withOpacity(0.6),
                ),
            
            const SizedBox(height: 2),
            
            // Label
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isActive 
                    ? item.gradient.colors.first
                    : Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _onItemTapped(int index, _NavItem item) {
    if (index == _currentIndex) return;
    
    // Haptic feedback
    _triggerHaptic();
    
    // Animation
    _animateTransition(index);
    
    // Navigation
    _navigateToPath(item.path);
  }

  void _triggerHaptic() {
    // Light haptic feedback - platform specific implementation
    try {
      // HapticFeedback.lightImpact(); // Uncomment if needed
    } catch (e) {
      // Graceful fallback
    }
  }

  void _animateTransition(int newIndex) {
    _previousIndex = _currentIndex;
    
    _rippleController.reset();
    _rippleController.forward();
    
    if (_previousIndex != newIndex) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _navigateToPath(String path) {
    try {
      if (GoRouter.of(context).routeInformationProvider.value.uri.path != path) {
        context.go(path);
      }
    } catch (e) {
      // Fallback navigation
      debugPrint('Navigation error: $e');
    }
  }
}

// Helper Classes
class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
    required this.gradient,
    this.isSpecial = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
  final LinearGradient gradient;
  final bool isSpecial;
}



// Safe Bottom Navigation Wrapper
class SafeBottomNavigation extends StatelessWidget {
  const SafeBottomNavigation({
    super.key,
    required this.child,
    required this.currentPath,
  });

  final Widget child;
  final String currentPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: ModernBottomNavigation(
        currentPath: currentPath,
      ),
      extendBody: true, // Allows content to extend behind nav bar
    );
  }
}

// Navigation Extension for easier usage
extension NavigationExtension on Widget {
  Widget withBottomNavigation(String currentPath) {
    return SafeBottomNavigation(
      currentPath: currentPath,
      child: this,
    );
  }
}