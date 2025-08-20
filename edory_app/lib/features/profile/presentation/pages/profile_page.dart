// lib/features/profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/gradient_card.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Demo User Data
  final String userName = "Max Mustermann";
  final String userEmail = "max@beispiel.de";
  final int storiesCreated = 42;
  final int charactersUnlocked = 18;
  final int totalReadingHours = 156;
  final DateTime memberSince = DateTime(2024, 1, 15);
  
  // Settings
  bool notificationsEnabled = true;
  bool autoSaveEnabled = true;
  bool parentalControlsEnabled = false;
  String selectedLanguage = "Deutsch";
  String selectedTheme = "Hell";

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profil',
      subtitle: 'Dein Edory-Konto',
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 150), // Account for app bar
                
                // Profile Header
                _buildProfileHeader(),
                
                const SizedBox(height: 24),
                
                // Statistics Cards
                _buildStatisticsSection(),
                
                const SizedBox(height: 24),
                
                // Account Settings
                _buildAccountSettings(),
                
                const SizedBox(height: 24),
                
                // App Settings
                _buildAppSettings(),
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return GradientCard(
      animationDelay: 0.ms,
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: ModernDesignSystem.primaryGradient,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: ModernDesignSystem.primaryGradient.colors.first.withOpacity(0.3),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '👨‍💼',
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // User Name
          Text(
            userName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: ModernDesignSystem.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          
          const SizedBox(height: 4),
          
          // User Email
          Text(
            userEmail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ModernDesignSystem.secondaryTextColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Member Since
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ModernDesignSystem.systemGray6.withOpacity(0.5),
              borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSmall),
            ),
            child: Text(
              'Mitglied seit ${_formatDate(memberSince)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ModernDesignSystem.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Deine Erfolge',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              color: ModernDesignSystem.primaryTextColor,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Statistics Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(child: _buildStatCard('📚', storiesCreated.toString(), 'Geschichten')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('👥', charactersUnlocked.toString(), 'Charaktere')),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('⏰', '${totalReadingHours}h', 'Lesezeit')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.secondarySystemGroupedBackground,
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
        border: Border.all(
          color: ModernDesignSystem.separator.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: ModernDesignSystem.primaryTextColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ModernDesignSystem.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return GradientCard(
      animationDelay: 200.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Konto-Einstellungen',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: ModernDesignSystem.primaryTextColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingsItem('👤', 'Profil bearbeiten', 'Name, E-Mail, Avatar ändern'),
          _buildSettingsItem('🔒', 'Passwort ändern', 'Sicherheit deines Kontos'),
          _buildSettingsItem('👨‍👩‍👧‍👦', 'Familienmitglieder', 'Kinder und Zugriffsrechte verwalten'),
          _buildSettingsItem('📱', 'Geräte-Synchronisation', 'Daten auf allen Geräten'),
        ],
      ),
    );
  }

  Widget _buildAppSettings() {
    return GradientCard(
      animationDelay: 400.ms,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'App-Einstellungen',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: ModernDesignSystem.primaryTextColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildSwitchItem('🔔', 'Benachrichtigungen', 'Push-Nachrichten erhalten', notificationsEnabled, (value) {
            setState(() => notificationsEnabled = value);
          }),
          
          _buildSwitchItem('💾', 'Auto-Speichern', 'Geschichten automatisch sichern', autoSaveEnabled, (value) {
            setState(() => autoSaveEnabled = value);
          }),
          
          _buildSwitchItem('🛡️', 'Kindersicherung', 'Inhalte und Zeit begrenzen', parentalControlsEnabled, (value) {
            setState(() => parentalControlsEnabled = value);
          }),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String emoji, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          // TODO: Navigate to specific settings page
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ModernDesignSystem.systemGray6.withOpacity(0.3),
            borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSmall),
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: ModernDesignSystem.primaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ModernDesignSystem.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                color: ModernDesignSystem.systemGray,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem(String emoji, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ModernDesignSystem.systemGray6.withOpacity(0.3),
        borderRadius: BorderRadius.circular(ModernDesignSystem.radiusSmall),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: ModernDesignSystem.primaryTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ModernDesignSystem.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: ModernDesignSystem.systemGreen,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Januar', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
