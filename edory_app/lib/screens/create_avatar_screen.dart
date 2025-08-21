// Avatales.Screens.CreateAvatarScreen
import 'package:flutter/material.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/theme/app_colors.dart';
import 'package:edory_app/shared/presentation/widgets/gradient_background.dart';
import 'package:edory_app/shared/presentation/widgets/animated_card.dart';
import 'package:edory_app/shared/presentation/widgets/custom_button.dart';

class CreateAvatarScreen extends StatefulWidget {
  const CreateAvatarScreen({Key? key}) : super(key: key);

  @override
  State<CreateAvatarScreen> createState() => _CreateAvatarScreenState();
}

class _CreateAvatarScreenState extends State<CreateAvatarScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _optionsController;
  late AnimationController _previewController;
  
  late Animation<double> _headerAnimation;
  late Animation<double> _optionsAnimation;
  late Animation<double> _previewAnimation;

  int _selectedCategoryIndex = 0;
  int _selectedStyleIndex = 0;
  Map<String, dynamic> _avatarConfiguration = {
    'style': 'Anime',
    'category': 'Gaming',
    'colors': AppColors.primaryBlue,
    'accessories': <String>[],
    'background': 'Gradient',
  };

  final List<AvatarCategory> _categories = [
    AvatarCategory(
      name: 'Gaming',
      icon: Icons.sports_esports,
      color: AppColors.primaryBlue,
      styles: ['Pixelart', 'Realistisch', 'Cartoon', 'Cyberpunk'],
    ),
    AvatarCategory(
      name: 'Anime',
      icon: Icons.face,
      color: AppColors.primaryPink,
      styles: ['Kawaii', 'Manga', 'Chibi', 'Realistic'],
    ),
    AvatarCategory(
      name: 'Fantasy',
      icon: Icons.auto_awesome,
      color: AppColors.primaryPurple,
      styles: ['Mystisch', 'Dungeons & Dragons', 'Märchen', 'Steampunk'],
    ),
    AvatarCategory(
      name: 'Tiere',
      icon: Icons.pets,
      color: AppColors.primaryMint,
      styles: ['Realistisch', 'Cartoon', 'Furry', 'Niedlich'],
    ),
    AvatarCategory(
      name: 'Abstrakt',
      icon: Icons.palette,
      color: AppColors.primaryPeach,
      styles: ['Geometrisch', 'Minimalist', 'Künstlerisch', 'Psychedelisch'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _optionsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _previewController = AnimationController(
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

    _optionsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _optionsController,
      curve: Curves.easeOutBack,
    ));

    _previewAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _previewController,
      curve: AppTheme.elasticOutCurve,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _headerController.forward();
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      _optionsController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _previewController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _optionsController.dispose();
    _previewController.dispose();
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
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                  color: AppColors.primaryText,
                ),
                Expanded(
                  child: Text(
                    'Avatar Erstellen',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.help_outline),
                  onPressed: () => _showHelp(),
                  color: AppColors.primaryBlue,
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              'Gestalte deinen einzigartigen Avatar',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPreview() {
    return AnimatedBuilder(
      animation: _previewAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.7 + (0.3 * _previewAnimation.value),
          child: Transform.rotate(
            angle: (1 - _previewAnimation.value) * 0.2,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(AppTheme.paddingLarge),
        child: AspectRatio(
          aspectRatio: 1,
          child: AnimatedCard(
            gradient: AppColors.createCustomGradient(
              startColor: _categories[_selectedCategoryIndex].color,
              endColor: _categories[_selectedCategoryIndex].color.withOpacity(0.6),
            ),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusXLarge),
            child: Stack(
              children: [
                // Avatar Preview
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.white.withOpacity(0.5),
                        width: 3,
                      ),
                    ),
                    child: Icon(
                      _categories[_selectedCategoryIndex].icon,
                      size: 60,
                      color: AppColors.white,
                    ),
                  ),
                ),
                // Preview Controls
                Positioned(
                  top: AppTheme.paddingMedium,
                  right: AppTheme.paddingMedium,
                  child: Column(
                    children: [
                      _buildPreviewControl(Icons.refresh, () => _regenerateAvatar()),
                      const SizedBox(height: AppTheme.paddingSmall),
                      _buildPreviewControl(Icons.save_alt, () => _savePreset()),
                    ],
                  ),
                ),
                // Configuration Info
                Positioned(
                  bottom: AppTheme.paddingMedium,
                  left: AppTheme.paddingMedium,
                  right: AppTheme.paddingMedium,
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.paddingSmall),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                    ),
                    child: Text(
                      '${_avatarConfiguration['category']} • ${_avatarConfiguration['style']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreviewControl(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.white.withOpacity(0.3),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.white.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: AppColors.white,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildCategorySelection() {
    return AnimatedBuilder(
      animation: _optionsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _optionsAnimation.value)),
          child: Opacity(
            opacity: _optionsAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategorie wählen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Container(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return _buildCategoryItem(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(int index) {
    final category = _categories[index];
    final isSelected = _selectedCategoryIndex == index;

    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: AppTheme.paddingMedium),
      child: GestureDetector(
        onTap: () => _selectCategory(index),
        child: AnimatedContainer(
          duration: AppTheme.animationMedium,
          decoration: BoxDecoration(
            gradient: isSelected
                ? AppColors.createCustomGradient(
                    startColor: category.color,
                    endColor: category.color.withOpacity(0.7),
                  )
                : null,
            color: isSelected ? null : AppColors.lightGray,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.icon,
                color: isSelected ? AppColors.white : AppColors.secondaryText,
                size: 24,
              ),
              const SizedBox(height: AppTheme.paddingSmall / 2),
              Text(
                category.name,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected ? AppColors.white : AppColors.secondaryText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyleSelection() {
    final selectedCategory = _categories[_selectedCategoryIndex];

    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stil wählen',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: AppTheme.paddingMedium,
              mainAxisSpacing: AppTheme.paddingSmall,
            ),
            itemCount: selectedCategory.styles.length,
            itemBuilder: (context, index) {
              return _buildStyleItem(selectedCategory.styles[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStyleItem(String style, int index) {
    final isSelected = _selectedStyleIndex == index;

    return GestureDetector(
      onTap: () => _selectStyle(index, style),
      child: AnimatedCard(
        backgroundColor: isSelected ? _categories[_selectedCategoryIndex].color : AppColors.lightGray,
        child: Center(
          child: Text(
            style,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: isSelected ? AppColors.white : AppColors.primaryText,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorSelection() {
    final colors = [
      AppColors.primaryBlue,
      AppColors.primaryPink,
      AppColors.primaryMint,
      AppColors.primaryPurple,
      AppColors.primaryPeach,
      AppColors.primaryLavender,
    ];

    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farben anpassen',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.paddingMedium),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: colors.asMap().entries.map((entry) {
              final color = entry.value;
              final isSelected = _avatarConfiguration['colors'] == color;

              return GestureDetector(
                onTap: () => _selectColor(color),
                child: AnimatedContainer(
                  duration: AppTheme.animationMedium,
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primaryText : Colors.transparent,
                      width: 3,
                    ),
                    boxShadow: isSelected ? AppTheme.mediumShadow : AppTheme.softShadow,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.paddingLarge),
      child: Row(
        children: [
          Expanded(
            child: CustomButton(
              text: 'Zurücksetzen',
              type: ButtonType.outline,
              backgroundColor: AppColors.secondaryText,
              onPressed: () => _resetConfiguration(),
            ),
          ),
          const SizedBox(width: AppTheme.paddingMedium),
          Expanded(
            flex: 2,
            child: GradientButton(
              text: 'Avatar Erstellen',
              gradient: AppColors.createCustomGradient(
                startColor: _categories[_selectedCategoryIndex].color,
                endColor: AppColors.primaryPurple,
              ),
              onPressed: () => _createAvatar(),
            ),
          ),
        ],
      ),
    );
  }

  // Event Handlers
  void _selectCategory(int index) {
    setState(() {
      _selectedCategoryIndex = index;
      _selectedStyleIndex = 0;
      _avatarConfiguration['category'] = _categories[index].name;
      _avatarConfiguration['style'] = _categories[index].styles[0];
      _avatarConfiguration['colors'] = _categories[index].color;
    });

    _previewController.reset();
    _previewController.forward();
  }

  void _selectStyle(int index, String style) {
    setState(() {
      _selectedStyleIndex = index;
      _avatarConfiguration['style'] = style;
    });
  }

  void _selectColor(Color color) {
    setState(() {
      _avatarConfiguration['colors'] = color;
    });
  }

  void _regenerateAvatar() {
    _previewController.reset();
    _previewController.forward();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avatar neu generiert!'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _savePreset() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preset gespeichert!'),
        backgroundColor: AppColors.primaryBlue,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _resetConfiguration() {
    setState(() {
      _selectedCategoryIndex = 0;
      _selectedStyleIndex = 0;
      _avatarConfiguration = {
        'style': _categories[0].styles[0],
        'category': _categories[0].name,
        'colors': _categories[0].color,
        'accessories': <String>[],
        'background': 'Gradient',
      };
    });

    _previewController.reset();
    _previewController.forward();
  }

  void _createAvatar() {
    // Hier würde die eigentliche Avatar-Erstellung stattfinden
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avatar Erstellt!'),
        content: Text(
          'Dein ${_avatarConfiguration['category']} Avatar im ${_avatarConfiguration['style']} Stil wurde erfolgreich erstellt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Weiter bearbeiten'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hilfe'),
        content: const Text(
          'Wähle eine Kategorie, einen Stil und passe die Farben an, um deinen perfekten Avatar zu erstellen. Nutze die Vorschau, um dein Design zu überprüfen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Verstanden'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DreamBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildAvatarPreview(),
                      _buildCategorySelection(),
                      const SizedBox(height: AppTheme.paddingLarge),
                      _buildStyleSelection(),
                      _buildColorSelection(),
                      const SizedBox(height: AppTheme.paddingLarge),
                    ],
                  ),
                ),
              ),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

class AvatarCategory {
  final String name;
  final IconData icon;
  final Color color;
  final List<String> styles;

  const AvatarCategory({
    required this.name,
    required this.icon,
    required this.color,
    required this.styles,
  });
}