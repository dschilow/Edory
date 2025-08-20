// lib/shared/presentation/pages/main_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/modern_design_system.dart';
// Custom bottom navigation is integrated directly

class MainWrapper extends StatelessWidget {
  const MainWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ModernDesignSystem.backgroundPrimary,
      extendBody: true,
      body: child,
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }
}

class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernDesignSystem.cardBackground,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLarge),
        border: Border.all(color: ModernDesignSystem.borderColor, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: ModernDesignSystem.accentBlue.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusLarge),
        child: Container(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                route: '/home',
                isActive: currentLocation == '/home',
              ),
              _buildNavItem(
                context,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: 'Charaktere',
                route: '/characters',
                isActive: currentLocation.startsWith('/characters'),
              ),
              _buildNavItem(
                context,
                icon: Icons.auto_stories_outlined,
                activeIcon: Icons.auto_stories,
                label: 'Erstellen',
                route: '/stories/create',
                isActive: currentLocation.startsWith('/stories'),
              ),
              _buildNavItem(
                context,
                icon: Icons.people_outline,
                activeIcon: Icons.people,
                label: 'Community',
                route: '/community',
                isActive: currentLocation == '/community',
              ),
              _buildNavItem(
                context,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: 'Profil',
                route: '/profile',
                isActive: currentLocation == '/profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.go(route),
        behavior: HitTestBehavior.translucent,
        child: Container(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: isActive 
                      ? LinearGradient(
                          colors: [
                            ModernDesignSystem.accentBlue.withOpacity(0.15),
                            ModernDesignSystem.accentTeal.withOpacity(0.1),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  size: 22,
                  color: isActive 
                      ? ModernDesignSystem.accentBlue
                      : ModernDesignSystem.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive 
                      ? ModernDesignSystem.accentBlue
                      : ModernDesignSystem.textSecondary,
                  fontFamily: ModernDesignSystem.fontFamily,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
