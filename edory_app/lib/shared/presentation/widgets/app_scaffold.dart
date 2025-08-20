// lib/shared/presentation/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import '../../../core/theme/modern_design_system.dart';

/// Modern App Scaffold - Clean Professional Design
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.title,
    this.subtitle,
    this.actions,
    this.floatingActionButton,
    this.backgroundColor,
    this.showBackButton = true,
  });

  final Widget body;
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? ModernDesignSystem.backgroundPrimary,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      appBar: title != null ? _buildModernAppBar(context) : null,
      body: SafeArea(
        bottom: true,
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }

  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: subtitle != null ? 110 : 70,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: ModernDesignSystem.h2,
            ),
          if (subtitle != null) ...[
            const SizedBox(height: ModernDesignSystem.spacing4),
            Text(
              subtitle!,
              style: ModernDesignSystem.bodyMedium,
            ),
          ],
        ],
      ),
      actions: actions,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ModernDesignSystem.backgroundPrimary.withOpacity(0.95),
              ModernDesignSystem.backgroundPrimary.withOpacity(0.8),
              Colors.transparent,
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
        ),
      ),
    );
  }
}
