// Avatales.Screens.AvatarDetailScreen
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/theme/app_colors.dart';
import 'package:edory_app/shared/presentation/widgets/gradient_background.dart';
import 'package:edory_app/shared/presentation/widgets/animated_card.dart';
import 'package:edory_app/shared/presentation/widgets/custom_button.dart';

class AvatarDetailScreen extends StatefulWidget {
  final String? avatarId;

  const AvatarDetailScreen({Key? key, this.avatarId}) : super(key: key);

  @override
  State<AvatarDetailScreen> createState() => _AvatarDetailScreenState();
}

class _AvatarDetailScreenState extends State<AvatarDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _heroController;
  late AnimationController _contentController;
  late AnimationController _actionController;
  
  late Animation<double> _heroAnimation;
  late Animation<double> _contentAnimation;
  late Animation<double> _actionAnimation;

  bool _isFavorited = false;
  bool _isDownloading = false;
  final ScrollController _scrollController = ScrollController();
  
  // Mock Avatar Data
  late AvatarDetail _avatarDetail;

  @override
  void initState() {
    super.initState();
    _loadAvatarData();
    _initializeAnimations();
    _startAnimations();
  }

  void _loadAvatarData() {
    // Mock-Daten für Avatar-Details
    _avatarDetail = AvatarDetail(
      id: widget.avatarId ?? '1',
      name: 'Cyber Ninja Warrior',
      description: 'Ein futuristischer Ninja-Avatar mit neon-leuchtenden Elementen und modernem Cyberpunk-Design. Perfekt für Gaming und virtuelle Welten.',
      author: AuthorInfo(
        name: 'PixelMaster3000',
        avatar: 'https://example.com/author.jpg',
        isVerified: true,
        followers: 15420,
      ),
      category: 'Gaming',
      tags: ['Cyberpunk', 'Ninja', 'Gaming', 'Futuristisch', 'Neon'],
      stats: AvatarStats(
        likes: 12450,
        downloads: 3240,
        views: 45680,
        comments: 892,
      ),
      colors: [
        AppColors.primaryBlue,
        AppColors.primaryPurple,
        AppColors.primaryMint,
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      rating: 4.8,
      isPremium: false,
      price: 0.0,
    );
  }

  void _initializeAnimations() {
    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _contentController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _actionController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _heroAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: AppTheme.elasticOutCurve,
    ));

    _contentAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutBack,
    ));

    _actionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _actionController,
      curve: AppTheme.elasticOutCurve,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _heroController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      _contentController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _actionController.forward();
    });
  }

  @override
  void dispose() {
    _heroController.dispose();
    _contentController.dispose();
    _actionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      elevation: 0,
      backgroundColor: _avatarDetail.colors.first,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: AppColors.white),
          onPressed: () => _shareAvatar(),
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.white),
          onPressed: () => _showMoreOptions(),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroSection(),
        collapseMode: CollapseMode.parallax,
      ),
    );
  }

  Widget _buildHeroSection() {
    return AnimatedBuilder(
      animation: _heroAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _heroAnimation.value),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.createCustomGradient(
                startColor: _avatarDetail.colors[0],
                endColor: _avatarDetail.colors[1],
              ),
            ),
            child: Stack(
              children: [
                // Floating Elements
                ...List.generate(5, (index) {
                  return Positioned(
                    left: (index * 80.0) + (_heroAnimation.value * 20),
                    top: 100 + (index * 40.0) + (_heroAnimation.value * 10),
                    child: Opacity(
                      opacity: 0.3 * _heroAnimation.value,
                      child: Container(
                        width: 30 + (index * 10.0),
                        height: 30 + (index * 10.0),
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  );
                }),
                
                // Main Avatar
                Center(
                  child: Transform.rotate(
                    angle: (1 - _heroAnimation.value) * 0.1,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        gradient: AppColors.createCustomGradient(
                          startColor: AppColors.white.withOpacity(0.3),
                          endColor: AppColors.white.withOpacity(0.1),
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.white.withOpacity(0.5),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowDark,
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.account_circle,
                        size: 120,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),

                // Rating Badge
                Positioned(
                  top: 100,
                  right: 30,
                  child: Opacity(
                    opacity: _heroAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.paddingMedium,
                        vertical: AppTheme.paddingSmall,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _avatarDetail.rating.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAvatarInfo() {
    return AnimatedBuilder(
      animation: _contentAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _contentAnimation.value)),
          child: Opacity(
            opacity: _contentAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _avatarDetail.name,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: AppTheme.animationMedium,
                  child: IconButton(
                    icon: Icon(
                      _isFavorited ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorited ? AppColors.primaryPink : AppColors.secondaryText,
                      size: 28,
                    ),
                    onPressed: () => _toggleFavorite(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            _buildAuthorInfo(),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildStatsRow(),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildDescription(),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildTags(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorInfo() {
    return GestureDetector(
      onTap: () => _viewAuthorProfile(),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppColors.createCustomGradient(
                startColor: AppColors.primaryBlue,
                endColor: AppColors.primaryMint,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppTheme.paddingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _avatarDetail.author.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_avatarDetail.author.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified,
                        color: AppColors.primaryBlue,
                        size: 16,
                      ),
                    ],
                  ],
                ),
                Text(
                  '${_formatNumber(_avatarDetail.author.followers)} Follower',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          CustomButton(
            text: 'Folgen',
            type: ButtonType.outline,
            size: ButtonSize.small,
            backgroundColor: AppColors.primaryBlue,
            onPressed: () => _followAuthor(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          icon: Icons.favorite,
          value: _formatNumber(_avatarDetail.stats.likes),
          label: 'Likes',
          color: AppColors.primaryPink,
        ),
        _buildStatItem(
          icon: Icons.download,
          value: _formatNumber(_avatarDetail.stats.downloads),
          label: 'Downloads',
          color: AppColors.primaryBlue,
        ),
        _buildStatItem(
          icon: Icons.visibility,
          value: _formatNumber(_avatarDetail.stats.views),
          label: 'Aufrufe',
          color: AppColors.primaryMint,
        ),
        _buildStatItem(
          icon: Icons.comment,
          value: _formatNumber(_avatarDetail.stats.comments),
          label: 'Kommentare',
          color: AppColors.primaryPurple,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.paddingSmall),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall / 2),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.secondaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Beschreibung',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        Text(
          _avatarDetail.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tags',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        Wrap(
          spacing: AppTheme.paddingSmall,
          runSpacing: AppTheme.paddingSmall,
          children: _avatarDetail.tags.map((tag) => _buildTag(tag)).toList(),
        ),
      ],
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.createCustomGradient(
          startColor: AppColors.primaryBlue.withOpacity(0.2),
          endColor: AppColors.primaryMint.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        tag,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return AnimatedBuilder(
      animation: _actionAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _actionAnimation.value)),
          child: Opacity(
            opacity: _actionAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.borderRadiusLarge),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 20,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: _isDownloading ? 'Lädt...' : 'Herunterladen',
                type: ButtonType.gradient,
                gradient: AppColors.createCustomGradient(
                  startColor: _avatarDetail.colors[0],
                  endColor: _avatarDetail.colors[1],
                ),
                isLoading: _isDownloading,
                leadingIcon: _isDownloading ? null : Icons.download,
                onPressed: () => _downloadAvatar(),
              ),
            ),
            const SizedBox(width: AppTheme.paddingMedium),
            CustomButton(
              type: ButtonType.outline,
              backgroundColor: AppColors.primaryBlue,
              child: const Icon(Icons.edit),
              onPressed: () => _customizeAvatar(),
            ),
          ],
        ),
      ),
    );
  }

  // Event Handlers
  void _toggleFavorite() {
    setState(() {
      _isFavorited = !_isFavorited;
    });

    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isFavorited 
              ? 'Zu Favoriten hinzugefügt' 
              : 'Aus Favoriten entfernt',
        ),
        backgroundColor: _isFavorited 
            ? AppColors.success 
            : AppColors.secondaryText,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _downloadAvatar() async {
    setState(() {
      _isDownloading = true;
    });

    HapticFeedback.mediumImpact();

    // Simuliere Download
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isDownloading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avatar erfolgreich heruntergeladen!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _customizeAvatar() {
    Navigator.pushNamed(context, '/create-avatar', arguments: _avatarDetail.id);
  }

  void _shareAvatar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avatar-Link wurde geteilt'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _showMoreOptions() {
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
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Melden'),
              onTap: () => _reportAvatar(),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Avatar-Info'),
              onTap: () => _showAvatarInfo(),
            ),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Link kopieren'),
              onTap: () => _copyLink(),
            ),
          ],
        ),
      ),
    );
  }

  void _viewAuthorProfile() {
    Navigator.pushNamed(context, '/profile', arguments: _avatarDetail.author.name);
  }

  void _followAuthor() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Du folgst jetzt ${_avatarDetail.author.name}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _reportAvatar() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avatar wurde gemeldet'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _showAvatarInfo() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avatar-Informationen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${_avatarDetail.id}'),
            Text('Kategorie: ${_avatarDetail.category}'),
            Text('Erstellt: ${_formatDate(_avatarDetail.createdAt)}'),
            Text('Aktualisiert: ${_formatDate(_avatarDetail.updatedAt)}'),
            Text('Premium: ${_avatarDetail.isPremium ? "Ja" : "Nein"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }

  void _copyLink() {
    Navigator.pop(context);
    Clipboard.setData(ClipboardData(text: 'https://avatales.com/avatar/${_avatarDetail.id}'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link in Zwischenablage kopiert'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}k';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildAvatarInfo(),
                const SizedBox(height: AppTheme.paddingXLarge),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }
}

// Data Models
class AvatarDetail {
  final String id;
  final String name;
  final String description;
  final AuthorInfo author;
  final String category;
  final List<String> tags;
  final AvatarStats stats;
  final List<Color> colors;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double rating;
  final bool isPremium;
  final double price;

  const AvatarDetail({
    required this.id,
    required this.name,
    required this.description,
    required this.author,
    required this.category,
    required this.tags,
    required this.stats,
    required this.colors,
    required this.createdAt,
    required this.updatedAt,
    required this.rating,
    required this.isPremium,
    required this.price,
  });
}

class AuthorInfo {
  final String name;
  final String avatar;
  final bool isVerified;
  final int followers;

  const AuthorInfo({
    required this.name,
    required this.avatar,
    required this.isVerified,
    required this.followers,
  });
}

class AvatarStats {
  final int likes;
  final int downloads;
  final int views;
  final int comments;

  const AvatarStats({
    required this.likes,
    required this.downloads,
    required this.views,
    required this.comments,
  });
}