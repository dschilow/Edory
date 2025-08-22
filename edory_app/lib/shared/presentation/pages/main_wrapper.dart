// lib/shared/presentation/pages/main_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/modern_design_system.dart';
import '../../../features/home/presentation/pages/home_page.dart';
import '../../../features/characters/presentation/pages/characters_page.dart';
import '../../../features/stories/presentation/pages/create_story_page.dart';
import '../../../features/stories/presentation/pages/stories_page.dart';
import '../../../features/community/presentation/pages/community_page.dart';

class MainWrapper extends ConsumerStatefulWidget {
  final Widget child;
  final String currentPath;

  const MainWrapper({
    super.key,
    required this.child,
    required this.currentPath,
  });

  @override
  ConsumerState<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends ConsumerState<MainWrapper>
    with TickerProviderStateMixin {
  
  late AnimationController _navController;
  late AnimationController _activeController;
  late List<AnimationController> _itemControllers;
  
  int _currentIndex = 0;
  int _previousIndex = 0;

  // Navigation Items aus JSON
  final List<NavigationItem> _navItems = [
    NavigationItem(
      id: 'home',
      icon: Icons.home_rounded,
      label: 'Home',
      path: '/home',
      isPrimary: false,
    ),
    NavigationItem(
      id: 'avatars',
      icon: Icons.people_rounded,
      label: 'Avatare',
      path: '/characters',
      isPrimary: false,
    ),
    NavigationItem(
      id: 'generate',
      icon: Icons.auto_awesome_rounded,
      label: 'Generieren',
      path: '/stories/create',
      isPrimary: true, // Primary action
    ),
    NavigationItem(
      id: 'stories',
      icon: Icons.menu_book_rounded,
      label: 'Stories',
      path: '/stories',
      isPrimary: false,
    ),
    NavigationItem(
      id: 'community',
      icon: Icons.public_rounded,
      label: 'Community',
      path: '/community',
      isPrimary: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _navController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _activeController = AnimationController(
      duration: const Duration(milliseconds: 320), // spring duration
      vsync: this,
    );
    
    // Individual controllers für jeden Tab
    _itemControllers = List.generate(
      _navItems.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 180),
        vsync: this,
      ),
    );
    
    _updateCurrentIndex();
    _navController.forward();
    _activeController.forward();
  }

  @override
  void didUpdateWidget(MainWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPath != widget.currentPath) {
      _updateCurrentIndex();
    }
  }

  void _updateCurrentIndex() {
    final newIndex = _navItems.indexWhere(
      (item) => widget.currentPath.startsWith(item.path),
    );
    
    if (newIndex != -1 && newIndex != _currentIndex) {
      setState(() {
        _previousIndex = _currentIndex;
        _currentIndex = newIndex;
      });
      
      // Animiere den neuen aktiven Tab
      _activeController.reset();
      _activeController.forward();
      
      // Trigger tap animation für den neuen Tab
      _itemControllers[_currentIndex].forward().then((_) {
        _itemControllers[_currentIndex].reverse();
      });
    }
  }

  @override
  void dispose() {
    _navController.dispose();
    _activeController.dispose();
    for (final controller in _itemControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;

    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Animate tap
    _itemControllers[index].forward().then((_) {
      _itemControllers[index].reverse();
    });
    
    // Navigate
    context.go(_navItems[index].path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      extendBody: true,
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 100,
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28), // lg radius
        border: Border.all(
          color: const Color(0xFF6E77FF).withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E77FF).withOpacity(0.18), // cardGlow
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _navItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isActive = index == _currentIndex;
              
              return _buildNavItem(item, index, isActive);
            }).toList(),
          ),
        ),
      ),
    ).animate(controller: _navController)
      .fadeIn(duration: 400.ms)
      .slideY(begin: 1, curve: Curves.easeOutCubic);
  }

  Widget _buildNavItem(NavigationItem item, int index, bool isActive) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabTapped(index),
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _activeController,
            _itemControllers[index],
          ]),
          builder: (context, child) {
            // Active Tab Animations (Pop-Effekt)
            final activeScale = isActive 
              ? 1.0 + (_activeController.value * 0.08) // scale 1.08
              : 1.0;
            
            final activeElevation = isActive 
              ? _activeController.value * 6 // elevate 6
              : 0.0;
            
            // Tap Animation
            final tapScale = 1.0 - (_itemControllers[index].value * 0.1);
            
            // Glow Animation
            final glowOpacity = isActive 
              ? 0.3 + (_activeController.value * 0.2)
              : 0.0;

            return Transform.scale(
              scale: activeScale * tapScale,
              child: Container(
                height: 64,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: isActive 
                    ? const Color(0xFF6E77FF)
                    : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    if (isActive) ...[
                      // Raise Shadow (elevation)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8 + activeElevation,
                        offset: Offset(0, 2 + activeElevation / 2),
                      ),
                      // Glow Shadow
                      BoxShadow(
                        color: const Color(0xFF6E77FF).withOpacity(glowOpacity),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(item.isPrimary ? 8 : 6),
                      decoration: item.isPrimary && !isActive 
                        ? BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6E77FF), Color(0xFF4B55E6)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6E77FF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          )
                        : null,
                      child: Icon(
                        item.icon,
                        size: item.isPrimary ? 28 : 24,
                        color: _getIconColor(item, isActive),
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Label
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isActive 
                          ? FontWeight.bold 
                          : FontWeight.w400,
                        color: _getLabelColor(item, isActive),
                      ),
                      child: Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Active Indicator Dot
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isActive ? 6 : 0,
                      height: isActive ? 6 : 0,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: isActive 
                          ? Colors.white
                          : Colors.transparent,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getIconColor(NavigationItem item, bool isActive) {
    if (isActive) {
      return Colors.white;
    } else if (item.isPrimary) {
      return Colors.white; // Primary button always has white icon
    } else {
      return const Color(0xFF6E77FF);
    }
  }

  Color _getLabelColor(NavigationItem item, bool isActive) {
    if (isActive) {
      return Colors.white;
    } else if (item.isPrimary) {
      return const Color(0xFF6E77FF);
    } else {
      return const Color(0xFF475569);
    }
  }
}

// Navigation Item Model
class NavigationItem {
  final String id;
  final IconData icon;
  final String label;
  final String path;
  final bool isPrimary;

  NavigationItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.path,
    required this.isPrimary,
  });
}

// Haptic Feedback Helper
class HapticFeedback {
  static void lightImpact() {
    // Implementierung für Haptic Feedback
    // Auf iOS: SystemSound.play(SystemSoundID.click)
    // Auf Android: Vibration
  }
}