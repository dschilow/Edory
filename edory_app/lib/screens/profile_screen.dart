// Avatales.Screens.ProfileScreen
import 'package:flutter/material.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/theme/app_colors.dart';
import 'package:edory_app/shared/presentation/widgets/gradient_background.dart';
import 'package:edory_app/shared/presentation/widgets/animated_card.dart';
import 'package:edory_app/shared/presentation/widgets/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _profileController;
  late AnimationController _tabController;
  late AnimationController _avatarController;
  
  late Animation<double> _profileAnimation;
  late Animation<double> _tabAnimation;
  late Animation<double> _avatarAnimation;

  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupScrollListener();
    _startAnimations();
  }

  void _initializeAnimations() {
    _profileController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _tabController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _profileAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _profileController,
      curve: Curves.easeOutBack,
    ));

    _tabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _tabController,
      curve: AppTheme.elasticOutCurve,
    ));

    _avatarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _avatarController,
      curve: Curves.elasticOut,
    ));
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isCollapsed = _scrollController.offset > 200;
      if (isCollapsed != _isHeaderCollapsed) {
        setState(() {
          _isHeaderCollapsed = isCollapsed;
        });
      }
    });
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _profileController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _tabController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _avatarController.forward();
    });
  }

  @override
  void dispose() {
    _profileController.dispose();
    _tabController.dispose();
    _avatarController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: GradientBackground(
          gradient: AppColors.createCustomGradient(
            startColor: AppColors.primaryBlue,
            endColor: AppColors.primaryMint,
          ),
          enableFloatingElements: false,
          child: const SizedBox.shrink(),
        ),
        collapseMode: CollapseMode.parallax,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.white),
          onPressed: () => _showOptionsMenu(),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return AnimatedBuilder(
      animation: _profileAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 50 * (1 - _profileAnimation.value)),
          child: Opacity(
            opacity: _profileAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        transform: Matrix4.translationValues(0, -80, 0),
        child: Column(
          children: [
            _buildAvatarSection(),
            const SizedBox(height: AppTheme.paddingMedium),
            _buildUserInfo(),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildStatsRow(),
            const SizedBox(height: AppTheme.paddingLarge),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return AnimatedBuilder(
      animation: _avatarAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.5 + (0.5 * _avatarAnimation.value),
          child: Transform.rotate(
            angle: (1 - _avatarAnimation.value) * 0.5,
            child: child,
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.createCustomGradient(
                startColor: AppColors.primaryPink,
                endColor: AppColors.primaryPeach,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 60,
              color: AppColors.white,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _editAvatar(),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.softShadow,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: AppColors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      children: [
        Text(
          'Max Mustermann',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primaryText,
          ),
        ),
        const SizedBox(height: AppTheme.paddingSmall / 2),
        Text(
          '@avatar_explorer',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppTheme.paddingMedium),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.paddingMedium,
          ),
          child: Text(
            'Avatar Designer & Digital Artist\n🎨 Erstelle einzigartige Avatare',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('156', 'Avatare'),
          _buildStatItem('2.3k', 'Follower'),
          _buildStatItem('489', 'Following'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return GestureDetector(
      onTap: () => _showStatDetail(label),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Folgen',
              type: ButtonType.gradient,
              gradient: AppColors.createCustomGradient(
                startColor: AppColors.primaryBlue,
                endColor: AppColors.primaryMint,
              ),
              onPressed: () => _followUser(),
            ),
          ),
          const SizedBox(width: AppTheme.paddingMedium),
          CustomButton(
            type: ButtonType.outline,
            backgroundColor: AppColors.primaryBlue,
            child: const Icon(Icons.message),
            onPressed: () => _sendMessage(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return AnimatedBuilder(
      animation: _tabAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _tabAnimation.value)),
          child: Opacity(
            opacity: _tabAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
        child: AnimatedCard(
          backgroundColor: AppColors.white,
          child: Column(
            children: [
              _buildTabBar(),
              _buildTabContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = ['Avatare', 'Favoriten', 'Kollektionen'];
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingSmall),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final title = entry.value;
          final isSelected = index == _selectedTabIndex;
          
          return Expanded(
            child: GestureDetector(
              onTap: () => _selectTab(index),
              child: AnimatedContainer(
                duration: AppTheme.animationMedium,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.paddingMedium,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                ),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected ? AppColors.white : AppColors.secondaryText,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildAvatarGrid();
      case 1:
        return _buildFavoritesGrid();
      case 2:
        return _buildCollectionsGrid();
      default:
        return _buildAvatarGrid();
    }
  }

  Widget _buildAvatarGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: AppTheme.paddingSmall,
        mainAxisSpacing: AppTheme.paddingSmall,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return _buildAvatarItem(index);
      },
    );
  }

  Widget _buildAvatarItem(int index) {
    final colors = [
      AppColors.primaryBlue,
      AppColors.primaryPink,
      AppColors.primaryMint,
      AppColors.primaryPurple,
      AppColors.primaryPeach,
      AppColors.primaryLavender,
    ];
    
    return GestureDetector(
      onTap: () => _viewAvatar(index),
      child: AnimatedCard(
        gradient: AppColors.createCustomGradient(
          startColor: colors[index % colors.length],
          endColor: colors[(index + 1) % colors.length],
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
        child: Stack(
          children: [
            const Center(
              child: Icon(
                Icons.account_circle,
                size: 40,
                color: AppColors.white,
              ),
            ),
            Positioned(
              top: AppTheme.paddingSmall / 2,
              right: AppTheme.paddingSmall / 2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesGrid() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        children: [
          const Icon(
            Icons.favorite_outline,
            size: 60,
            color: AppColors.secondaryText,
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Text(
            'Noch keine Favoriten',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          Text(
            'Markiere Avatare als Favoriten, um sie hier zu sehen',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsGrid() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingMedium),
      child: Column(
        children: [
          _buildCollectionItem('Gaming Avatare', 23, AppColors.primaryBlue),
          _buildCollectionItem('Anime Collection', 15, AppColors.primaryPink),
          _buildCollectionItem('Fantasy Heroes', 8, AppColors.primaryPurple),
        ],
      ),
    );
  }

  Widget _buildCollectionItem(String title, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.paddingMedium),
      child: AnimatedCard(
        onTap: () => _viewCollection(title),
        child: ListTile(
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
            ),
            child: Icon(
              Icons.folder,
              color: color,
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text('$count Avatare'),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }

  // Event Handlers
  void _selectTab(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  void _showOptionsMenu() {
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
              leading: const Icon(Icons.share),
              title: const Text('Profil teilen'),
              onTap: () => _shareProfile(),
            ),
            ListTile(
              leading: const Icon(Icons.report),
              title: const Text('Melden'),
              onTap: () => _reportProfile(),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Blockieren'),
              onTap: () => _blockUser(),
            ),
          ],
        ),
      ),
    );
  }

  void _editAvatar() {
    Navigator.pushNamed(context, '/edit-avatar');
  }

  void _followUser() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Benutzer gefolgt!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _sendMessage() {
    Navigator.pushNamed(context, '/chat');
  }

  void _showStatDetail(String stat) {
    Navigator.pushNamed(context, '/stat-detail', arguments: stat);
  }

  void _viewAvatar(int index) {
    Navigator.pushNamed(context, '/avatar-detail', arguments: index);
  }

  void _viewCollection(String title) {
    Navigator.pushNamed(context, '/collection', arguments: title);
  }

  void _shareProfile() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil Link kopiert!')),
    );
  }

  void _reportProfile() {
    Navigator.pop(context);
  }

  void _blockUser() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: _buildProfileHeader(),
          ),
          SliverToBoxAdapter(
            child: const SizedBox(height: AppTheme.paddingLarge),
          ),
          SliverToBoxAdapter(
            child: _buildTabSection(),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: AppTheme.paddingXLarge),
          ),
        ],
      ),
    );
  }
}