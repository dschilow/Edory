// lib/shared/presentation/pages/main_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

// Neues Theme System
import 'package:edory_app/core/theme/avatales_theme_index.dart';

/// Main Wrapper - Umhüllt alle Hauptseiten mit Navigation
/// Namespace: Avatales.Shared.Presentation.Pages.MainWrapper
class MainWrapper extends StatelessWidget {
  const MainWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      extendBody: true,
      body: child,
      bottomNavigationBar: const CustomBottomNavigation(),
    );
  }
}

/// Custom Bottom Navigation - iOS-inspired Design
/// Namespace: Avatales.Shared.Presentation.Pages.CustomBottomNavigation
class CustomBottomNavigation extends StatelessWidget {
  const CustomBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.path;
    
    return Container(
      margin: AppSpacing.paddingMD.copyWith(top: 0),
      decoration: AppDecorations.bottomNavigationDecoration,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXLarge),
          topRight: Radius.circular(AppSpacing.radiusXLarge),
        ),
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
                padding: AppSpacing.paddingXS.copyWith(
                  top: AppSpacing.xs,
                  bottom: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  gradient: isActive 
                      ? LinearGradient(
                          colors: [
                            AppColors.primaryBlue.withOpacity(0.15),
                            AppColors.primaryTeal.withOpacity(0.1),
                          ],
                        )
                      : null,
                  borderRadius: AppSpacing.borderRadiusMedium,
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  size: 22,
                  color: isActive 
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                ),
              ),
              AppSpacing.verticalSpaceXS,
              Text(
                label,
                style: AppTypography.tabBarLabel.copyWith(
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive 
                      ? AppColors.primaryBlue
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}