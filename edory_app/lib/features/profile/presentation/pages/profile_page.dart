// lib/features/profile/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with TickerProviderStateMixin {
  
  late AnimationController _headerController;
  late AnimationController _sectionsController;
  
  // Settings State
  String _selectedTheme = 'System';
  String _selectedLanguage = 'Deutsch';
  String _defaultStoryLength = 'Mittel';
  String _defaultAvatar = 'Kein Standard';
  bool _notificationsEnabled = true;
  bool _emailReportsEnabled = false;
  int _defaultDifficulty = 3;
  
  final List<String> _forbiddenTopics = ['Spinnen', 'Dunkelheit'];
  final List<String> _forbiddenWords = ['Angst', 'Monster'];

  @override
  void initState() {
    super.initState();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _sectionsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _headerController.forward();
    _sectionsController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _sectionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Profil',
      subtitle: 'Einstellungen und Preferences',
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF6F8FF),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Profile Header
            SliverToBoxAdapter(
              child: _buildProfileHeader()
                .animate(controller: _headerController)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.3, curve: Curves.easeOutBack),
            ),
            
            // Account Section
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Konto',
                icon: '👤',
                items: [
                  _buildAccountItem('Name', 'Mila Schmidt', Icons.person_rounded),
                  _buildAccountItem('E-Mail', 'mila@example.com', Icons.email_rounded),
                  _buildAccountItem('Passwort', '••••••••', Icons.lock_rounded),
                  _buildAccountItem('Kindersicherung', 'Aktiviert', Icons.child_care_rounded),
                ],
              ).animate(controller: _sectionsController)
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideX(begin: -0.2, curve: Curves.easeOutCubic),
            ),
            
            // Story Settings Section
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Geschichten',
                icon: '📚',
                items: [
                  _buildDropdownItem(
                    'Standard-Länge',
                    _defaultStoryLength,
                    ['Kurz', 'Mittel', 'Lang'],
                    (value) => setState(() => _defaultStoryLength = value!),
                  ),
                  _buildDropdownItem(
                    'Standard-Avatar',
                    _defaultAvatar,
                    ['Kein Standard', 'Luna', 'Kiko', 'Max'],
                    (value) => setState(() => _defaultAvatar = value!),
                  ),
                  _buildListItem('Verbotene Themen', _forbiddenTopics.join(', ')),
                  _buildListItem('Verbotene Wörter', _forbiddenWords.join(', ')),
                ],
              ).animate(controller: _sectionsController)
                .fadeIn(delay: 400.ms, duration: 500.ms)
                .slideX(begin: 0.2, curve: Curves.easeOutCubic),
            ),
            
            // Learning Mode Section
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Lernmodus',
                icon: '🎓',
                items: [
                  _buildListItem('Ziel-Presets', 'Mut, Wortschatz, Empathie'),
                  _buildSliderItem(
                    'Schwierigkeit',
                    _defaultDifficulty,
                    1,
                    5,
                    (value) => setState(() => _defaultDifficulty = value.round()),
                  ),
                  _buildSwitchItem(
                    'Berichte an E-Mail',
                    _emailReportsEnabled,
                    (value) => setState(() => _emailReportsEnabled = value),
                  ),
                ],
              ).animate(controller: _sectionsController)
                .fadeIn(delay: 600.ms, duration: 500.ms)
                .slideX(begin: -0.2, curve: Curves.easeOutCubic),
            ),
            
            // General Settings Section
            SliverToBoxAdapter(
              child: _buildSection(
                title: 'Allgemein',
                icon: '⚙️',
                items: [
                  _buildSwitchItem(
                    'Benachrichtigungen',
                    _notificationsEnabled,
                    (value) => setState(() => _notificationsEnabled = value),
                  ),
                  _buildDropdownItem(
                    'Sprache',
                    _selectedLanguage,
                    ['Deutsch', 'English', 'Français', 'Español'],
                    (value) => setState(() => _selectedLanguage = value!),
                  ),
                  _buildDropdownItem(
                    'Design',
                    _selectedTheme,
                    ['Hell', 'Dunkel', 'System'],
                    (value) => setState(() => _selectedTheme = value!),
                  ),
                ],
              ).animate(controller: _sectionsController)
                .fadeIn(delay: 800.ms, duration: 500.ms)
                .slideX(begin: 0.2, curve: Curves.easeOutCubic),
            ),
            
            // Action Buttons
            SliverToBoxAdapter(
              child: _buildActionButtons()
                .animate(controller: _sectionsController)
                .fadeIn(delay: 1000.ms, duration: 500.ms)
                .slideY(begin: 0.3, curve: Curves.easeOutBack),
            ),
            
            // Bottom Padding
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6E77FF).withOpacity(0.1),
            const Color(0xFF8EE2D2).withOpacity(0.1),
            const Color(0xFFFF89B3).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF6E77FF).withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6E77FF).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              gradient: const LinearGradient(
                colors: [Color(0xFF6E77FF), Color(0xFF8EE2D2)],
              ),
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6E77FF).withOpacity(0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'M',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          
          // Profile Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mila Schmidt',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seit März 2024',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF475569).withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Stats Row
                Row(
                  children: [
                    _buildStatBadge('12', 'Geschichten', const Color(0xFF6E77FF)),
                    const SizedBox(width: 12),
                    _buildStatBadge('3', 'Avatare', const Color(0xFF8EE2D2)),
                  ],
                ),
              ],
            ),
          ),
          
          // Edit Button
          GestureDetector(
            onTap: () {
              // Navigate to edit profile
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF6E77FF).withOpacity(0.2),
                ),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Color(0xFF6E77FF),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String icon,
    required List<Widget> items,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: item,
          )),
        ],
      ),
    );
  }

  Widget _buildAccountItem(String title, String value, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Handle account item tap
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF6E77FF).withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6E77FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF6E77FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF475569).withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF475569),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownItem(
    String title,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F8FF),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF6E77FF).withOpacity(0.2),
            ),
          ),
          child: DropdownButton<String>(
            value: value,
            underline: const SizedBox(),
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6E77FF),
              fontWeight: FontWeight.w400,
            ),
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchItem(
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF6E77FF),
        ),
      ],
    );
  }

  Widget _buildSliderItem(
    String title,
    int value,
    int min,
    int max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6E77FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Level $value',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6E77FF),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: const Color(0xFF6E77FF),
            inactiveTrackColor: const Color(0xFF6E77FF).withOpacity(0.2),
            thumbColor: const Color(0xFF6E77FF),
            overlayColor: const Color(0xFF6E77FF).withOpacity(0.1),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildListItem(String title, String value) {
    return GestureDetector(
      onTap: () {
        // Handle list item edit
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Keine Einträge',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF475569).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Color(0xFF475569),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Export Data Button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF8EE2D2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF8EE2D2).withOpacity(0.3),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download_rounded, color: Color(0xFF8EE2D2), size: 20),
                SizedBox(width: 8),
                Text(
                  'Daten exportieren',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8EE2D2),
                  ),
                ),
              ],
            ),
          ),
          
          // Sign Out Button
          GestureDetector(
            onTap: _showSignOutDialog,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFFF89B3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFF89B3).withOpacity(0.3),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, color: Color(0xFFFF89B3), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Abmelden',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF89B3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Abmelden'),
        content: const Text('Möchten Sie sich wirklich abmelden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen', style: TextStyle(color: Color(0xFF6E77FF))),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Handle sign out
            },
            child: const Text('Abmelden', style: TextStyle(color: Color(0xFFFF89B3))),
          ),
        ],
      ),
    );
  }
}