// lib/shared/presentation/widgets/app_scaffold.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/modern_design_system.dart';

/// Wiederverwendbares App Scaffold für Avatales
/// Provides consistent layout, navigation and styling across all pages
class AppScaffold extends StatefulWidget {
  const AppScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.showBackButton = true,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.extendBodyBehindAppBar = false,
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final bool extendBodyBehindAppBar;
  final bool safeAreaTop;
  final bool safeAreaBottom;

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold>
    with TickerProviderStateMixin {
  
  late AnimationController _headerController;
  late AnimationController _backgroundController;
  final ScrollController _scrollController = ScrollController();
  
  double _scrollOffset = 0.0;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _scrollController.addListener(_onScroll);
    
    // Start animations
    _headerController.forward();
    _backgroundController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _backgroundController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    setState(() {
      _scrollOffset = offset;
      _isScrolled = offset > 50;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? ModernDesignSystem.textLight,
      extendBodyBehindAppBar: widget.extendBodyBehindAppBar,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      body: Stack(
        children: [
          // Background
          _buildBackground(),
          
          // Main Content
          SafeArea(
            top: widget.safeAreaTop,
            bottom: widget.safeAreaBottom,
            child: Column(
              children: [
                // Custom App Bar
                _buildAppBar(),
                
                // Body Content
                Expanded(
                  child: _buildBody(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.backgroundColor ?? ModernDesignSystem.textLight,
                (widget.backgroundColor ?? ModernDesignSystem.textLight)
                    .withOpacity(0.8),
              ],
            ),
          ),
          child: CustomPaint(
            painter: _BackgroundPatternPainter(
              animationValue: _backgroundController.value,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildAppBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 10,
        20,
        20,
      ),
      decoration: BoxDecoration(
        gradient: _isScrolled
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.95),
                  Colors.white.withOpacity(0.8),
                ],
              )
            : null,
        boxShadow: _isScrolled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          // Back Button
          if (widget.showBackButton)
            _buildBackButton()
                .animate(controller: _headerController)
                .slideX(begin: -0.5, duration: 600.ms)
                .fadeIn(),
          
          if (widget.showBackButton) const SizedBox(width: 16),
          
          // Title Section
          Expanded(
            child: _buildTitleSection()
                .animate(controller: _headerController)
                .slideY(begin: -0.3, duration: 600.ms, delay: 200.ms)
                .fadeIn(),
          ),
          
          // Actions
          if (widget.actions != null) ...[
            const SizedBox(width: 16),
            ...widget.actions!
                .asMap()
                .entries
                .map((entry) => entry.value
                    .animate(controller: _headerController)
                    .slideX(
                      begin: 0.5,
                      duration: 600.ms,
                      delay: (300 + entry.key * 100).ms,
                    )
                    .fadeIn()),
          ],
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: widget.onBackPressed ?? _defaultBackAction,
          child: Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: ModernDesignSystem.primaryTextColor,
          ),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: ModernDesignSystem.primaryTextColor,
            height: 1.2,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            widget.subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ModernDesignSystem.secondaryTextColor,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildBody() {
    if (widget.body is CustomScrollView) {
      // If body is already a CustomScrollView, use it directly
      return widget.body;
    }
    
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: widget.body,
        ),
      ],
    );
  }

  void _defaultBackAction() {
    if (context.canPop()) {
      context.pop();
    } else {
      // Fallback navigation
      context.go('/home');
    }
  }
}

/// Background Pattern Painter für subtile Textur
class _BackgroundPatternPainter extends CustomPainter {
  final double animationValue;

  const _BackgroundPatternPainter({
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02 * animationValue)
      ..style = PaintingStyle.fill;

    // Create subtle dot pattern
    const spacing = 40.0;
    const dotSize = 1.5;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(
          Offset(x + (spacing * 0.5), y + (spacing * 0.5)),
          dotSize * animationValue,
          paint,
        );
      }
    }

    // Add some flowing lines
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05 * animationValue)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (int i = 0; i < 3; i++) {
      final yOffset = (size.height / 4) * (i + 1);
      path.moveTo(0, yOffset);
      
      for (double x = 0; x <= size.width; x += 20) {
        final y = yOffset + 
                  (20 * animationValue * 
                   (i.isEven ? 1 : -1) * 
                   (x / size.width));
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundPatternPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// AppScaffold Extensions für einfachere Verwendung
extension AppScaffoldExtensions on Widget {
  /// Wraps widget in AppScaffold with title
  Widget withAppScaffold({
    required String title,
    String? subtitle,
    bool showBackButton = true,
    VoidCallback? onBackPressed,
    List<Widget>? actions,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
  }) {
    return AppScaffold(
      title: title,
      subtitle: subtitle,
      body: this,
      showBackButton: showBackButton,
      onBackPressed: onBackPressed,
      actions: actions,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
    );
  }
}

/// AppScaffold Variants für spezielle Use Cases
class AppScaffoldVariants {
  /// Fullscreen scaffold without back button
  static Widget fullscreen({
    required String title,
    String? subtitle,
    required Widget body,
    List<Widget>? actions,
  }) {
    return AppScaffold(
      title: title,
      subtitle: subtitle,
      body: body,
      showBackButton: false,
      actions: actions,
      extendBodyBehindAppBar: true,
    );
  }

  /// Minimal scaffold for simple pages
  static Widget minimal({
    required String title,
    required Widget body,
  }) {
    return AppScaffold(
      title: title,
      body: body,
      showBackButton: true,
    );
  }

  /// Dialog-style scaffold
  static Widget dialog({
    required String title,
    required Widget body,
    Widget? floatingActionButton,
  }) {
    return AppScaffold(
      title: title,
      body: body,
      showBackButton: true,
      backgroundColor: Colors.white,
      floatingActionButton: floatingActionButton,
    );
  }
}

/// Custom App Bar Action Button
class AppBarAction extends StatelessWidget {
  const AppBarAction({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.badge,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    Widget button = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.black.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Icon(
            icon,
            size: 20,
            color: ModernDesignSystem.primaryTextColor,
          ),
        ),
      ),
    );

    if (badge != null) {
      button = Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          Positioned(
            top: -4,
            right: -4,
            child: badge!,
          ),
        ],
      );
    }

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}

/// Notification Badge für App Bar Actions
class NotificationBadge extends StatelessWidget {
  const NotificationBadge({
    super.key,
    required this.count,
    this.maxCount = 99,
  });

  final int count;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: ModernDesignSystem.redGradient,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: ModernDesignSystem.pastelRed.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: Text(
        count > maxCount ? '$maxCount+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}