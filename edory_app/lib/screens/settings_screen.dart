// Avatales.Screens.SettingsScreen
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/theme/app_colors.dart';
import 'package:edory_app/shared/presentation/widgets/gradient_background.dart';
import 'package:edory_app/shared/presentation/widgets/animated_card.dart';
import 'package:edory_app/shared/presentation/widgets/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _sectionsController;
  late Animation<double> _headerAnimation;
  late Animation<double> _sectionsAnimation;

  // Settings State
  bool _notificationsEnabled = true;
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _darkModeEnabled = false;
  bool _autoSaveEnabled = true;
  bool _highQualityPreview = true;
  bool _analyticsEnabled = false;
  bool _betaFeaturesEnabled = false;
  
  String _selectedLanguage = 'Deutsch';
  String _selectedTheme = 'System';
  double _animationSpeed = 1.0;
  int _cacheSize = 50;

  final List<String> _languages = ['Deutsch', 'English', 'Français', 'Español'];
  final List<String> _themes = ['Hell', 'Dunkel', 'System'];

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

    _sectionsController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: AppTheme.elasticOutCurve,
    ));

    _sectionsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sectionsController,
      curve: Curves.easeOutBack,
    ));
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _headerController.forward();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      _sectionsController.forward();
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _sectionsController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - _headerAnimation.value)),
          child: Opacity(
            opacity: _headerAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
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
                    'Einstellungen',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingSmall),
                  decoration: BoxDecoration(
                    gradient: AppColors.createCustomGradient(
                      startColor: AppColors.primaryBlue,
                      endColor: AppColors.primaryMint,
                    ),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: const Icon(
                    Icons.settings,
                    color: AppColors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.paddingMedium),
            Text(
              'Personalisiere deine Avatales-Erfahrung',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return AnimatedBuilder(
      animation: _sectionsAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _sectionsAnimation.value)),
          child: Opacity(
            opacity: _sectionsAnimation.value,
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.paddingLarge,
          vertical: AppTheme.paddingMedium,
        ),
        child: AnimatedCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    IconData? icon,
    Color? iconColor,
  }) {
    return ListTile(
      leading: icon != null
          ? Container(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primaryBlue).withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primaryBlue,
                size: 20,
              ),
            )
          : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
              ),
            )
          : null,
      trailing: Transform.scale(
        scale: 0.8,
        child: CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildSelectTile({
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onTap,
    IconData? icon,
    Color? iconColor,
  }) {
    return ListTile(
      leading: icon != null
          ? Container(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primaryBlue).withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Icon(
                icon,
                color: iconColor ?? AppColors.primaryBlue,
                size: 20,
              ),
            )
          : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.secondaryText,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppTheme.paddingSmall / 2),
          const Icon(
            Icons.chevron_right,
            color: AppColors.secondaryText,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSliderTile({
    required String title,
    required String subtitle,
    required double value,
    required ValueChanged<double> onChanged,
    required double min,
    required double max,
    int? divisions,
    IconData? icon,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppTheme.paddingSmall),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primaryBlue).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.paddingMedium),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.paddingSmall),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryBlue,
              inactiveTrackColor: AppColors.lightGray,
              thumbColor: AppColors.primaryBlue,
              overlayColor: AppColors.primaryBlue.withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
              min: min,
              max: max,
              divisions: divisions,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    IconData? icon,
    Color? iconColor,
    Color? textColor,
    bool destructive = false,
  }) {
    final color = destructive ? AppColors.error : (textColor ?? AppColors.primaryText);
    
    return ListTile(
      leading: icon != null
          ? Container(
              padding: const EdgeInsets.all(AppTheme.paddingSmall),
              decoration: BoxDecoration(
                color: (iconColor ?? color).withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
              ),
              child: Icon(
                icon,
                color: iconColor ?? color,
                size: 20,
              ),
            )
          : null,
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.secondaryText,
              ),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.secondaryText,
      ),
      onTap: onTap,
    );
  }

  void _showLanguageSelector() {
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
            Text(
              'Sprache wählen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            ..._languages.map((language) {
              return ListTile(
                title: Text(language),
                trailing: _selectedLanguage == language
                    ? const Icon(Icons.check, color: AppColors.primaryBlue)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedLanguage = language;
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showThemeSelector() {
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
            Text(
              'Design wählen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            ..._themes.map((theme) {
              return ListTile(
                title: Text(theme),
                trailing: _selectedTheme == theme
                    ? const Icon(Icons.check, color: AppColors.primaryBlue)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedTheme = theme;
                  });
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _clearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cache löschen'),
        content: const Text(
          'Möchtest du wirklich den gesamten Cache löschen? Dies kann die Ladezeiten vorübergehend verlangsamen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache wurde geleert'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Daten werden exportiert...'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _resetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Einstellungen zurücksetzen'),
        content: const Text(
          'Möchtest du alle Einstellungen auf die Standardwerte zurücksetzen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _notificationsEnabled = true;
                _pushNotifications = true;
                _emailNotifications = false;
                _darkModeEnabled = false;
                _autoSaveEnabled = true;
                _highQualityPreview = true;
                _analyticsEnabled = false;
                _betaFeaturesEnabled = false;
                _selectedLanguage = 'Deutsch';
                _selectedTheme = 'System';
                _animationSpeed = 1.0;
                _cacheSize = 50;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Einstellungen wurden zurückgesetzt'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Zurücksetzen'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CloudBackground(
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Benachrichtigungen
                      _buildSettingsSection(
                        'Benachrichtigungen',
                        [
                          _buildSwitchTile(
                            title: 'Benachrichtigungen',
                            subtitle: 'Alle Benachrichtigungen aktivieren',
                            value: _notificationsEnabled,
                            onChanged: (value) => setState(() => _notificationsEnabled = value),
                            icon: Icons.notifications,
                            iconColor: AppColors.primaryBlue,
                          ),
                          _buildSwitchTile(
                            title: 'Push-Benachrichtigungen',
                            subtitle: 'Sofortige Benachrichtigungen auf diesem Gerät',
                            value: _pushNotifications,
                            onChanged: (value) => setState(() => _pushNotifications = value),
                            icon: Icons.phone_android,
                            iconColor: AppColors.primaryMint,
                          ),
                          _buildSwitchTile(
                            title: 'E-Mail-Benachrichtigungen',
                            subtitle: 'Benachrichtigungen per E-Mail erhalten',
                            value: _emailNotifications,
                            onChanged: (value) => setState(() => _emailNotifications = value),
                            icon: Icons.email,
                            iconColor: AppColors.primaryPink,
                          ),
                        ],
                      ),

                      // Aussehen
                      _buildSettingsSection(
                        'Aussehen',
                        [
                          _buildSelectTile(
                            title: 'Design',
                            subtitle: 'Helles oder dunkles Design',
                            value: _selectedTheme,
                            onTap: _showThemeSelector,
                            icon: Icons.palette,
                            iconColor: AppColors.primaryPurple,
                          ),
                          _buildSelectTile(
                            title: 'Sprache',
                            subtitle: 'App-Sprache ändern',
                            value: _selectedLanguage,
                            onTap: _showLanguageSelector,
                            icon: Icons.language,
                            iconColor: AppColors.primaryPeach,
                          ),
                          _buildSliderTile(
                            title: 'Animationsgeschwindigkeit',
                            subtitle: 'Geschwindigkeit der App-Animationen',
                            value: _animationSpeed,
                            onChanged: (value) => setState(() => _animationSpeed = value),
                            min: 0.5,
                            max: 2.0,
                            divisions: 3,
                            icon: Icons.speed,
                            iconColor: AppColors.primaryBlue,
                          ),
                        ],
                      ),

                      // Avatar-Einstellungen
                      _buildSettingsSection(
                        'Avatar-Einstellungen',
                        [
                          _buildSwitchTile(
                            title: 'Automatisches Speichern',
                            subtitle: 'Avatare automatisch speichern',
                            value: _autoSaveEnabled,
                            onChanged: (value) => setState(() => _autoSaveEnabled = value),
                            icon: Icons.save,
                            iconColor: AppColors.primaryMint,
                          ),
                          _buildSwitchTile(
                            title: 'Hochwertige Vorschau',
                            subtitle: 'Bessere Qualität, mehr Datenverbrauch',
                            value: _highQualityPreview,
                            onChanged: (value) => setState(() => _highQualityPreview = value),
                            icon: Icons.high_quality,
                            iconColor: AppColors.primaryPurple,
                          ),
                          _buildSliderTile(
                            title: 'Cache-Größe',
                            subtitle: 'Maximale Cache-Größe in MB',
                            value: _cacheSize.toDouble(),
                            onChanged: (value) => setState(() => _cacheSize = value.round()),
                            min: 10,
                            max: 200,
                            divisions: 19,
                            icon: Icons.storage,
                            iconColor: AppColors.primaryPeach,
                          ),
                        ],
                      ),

                      // Datenschutz
                      _buildSettingsSection(
                        'Datenschutz',
                        [
                          _buildSwitchTile(
                            title: 'Analysen',
                            subtitle: 'Hilf uns, die App zu verbessern',
                            value: _analyticsEnabled,
                            onChanged: (value) => setState(() => _analyticsEnabled = value),
                            icon: Icons.analytics,
                            iconColor: AppColors.primaryBlue,
                          ),
                          _buildActionTile(
                            title: 'Datenschutzerklärung',
                            subtitle: 'Unsere Datenschutzrichtlinien lesen',
                            onTap: () {},
                            icon: Icons.privacy_tip,
                            iconColor: AppColors.primaryMint,
                          ),
                          _buildActionTile(
                            title: 'Daten exportieren',
                            subtitle: 'Alle deine Daten herunterladen',
                            onTap: _exportData,
                            icon: Icons.download,
                            iconColor: AppColors.primaryPurple,
                          ),
                        ],
                      ),

                      // Erweitert
                      _buildSettingsSection(
                        'Erweitert',
                        [
                          _buildSwitchTile(
                            title: 'Beta-Features',
                            subtitle: 'Experimentelle Funktionen testen',
                            value: _betaFeaturesEnabled,
                            onChanged: (value) => setState(() => _betaFeaturesEnabled = value),
                            icon: Icons.science,
                            iconColor: AppColors.primaryPink,
                          ),
                          _buildActionTile(
                            title: 'Cache löschen',
                            subtitle: '${_cacheSize}MB Cache-Daten löschen',
                            onTap: _clearCache,
                            icon: Icons.clear_all,
                            iconColor: AppColors.warning,
                          ),
                          _buildActionTile(
                            title: 'Einstellungen zurücksetzen',
                            subtitle: 'Alle Einstellungen auf Standard zurücksetzen',
                            onTap: _resetSettings,
                            icon: Icons.restore,
                            iconColor: AppColors.error,
                            destructive: true,
                          ),
                        ],
                      ),

                      // Info
                      _buildSettingsSection(
                        'Information',
                        [
                          _buildActionTile(
                            title: 'Über Avatales',
                            subtitle: 'Version 1.0.0',
                            onTap: () {},
                            icon: Icons.info,
                            iconColor: AppColors.primaryBlue,
                          ),
                          _buildActionTile(
                            title: 'Hilfe & Support',
                            subtitle: 'Kontaktiere unser Support-Team',
                            onTap: () {},
                            icon: Icons.help,
                            iconColor: AppColors.primaryMint,
                          ),
                          _buildActionTile(
                            title: 'Bewerte die App',
                            subtitle: 'Hinterlasse eine Bewertung',
                            onTap: () {},
                            icon: Icons.star,
                            iconColor: AppColors.primaryPeach,
                          ),
                        ],
                      ),

                      const SizedBox(height: AppTheme.paddingXLarge * 2),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}