// lib/features/characters/presentation/pages/create_character_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/character_traits.dart';
import '../providers/characters_provider.dart';

class CreateCharacterPage extends ConsumerStatefulWidget {
  const CreateCharacterPage({super.key});

  @override
  ConsumerState<CreateCharacterPage> createState() => _CreateCharacterPageState();
}

class _CreateCharacterPageState extends ConsumerState<CreateCharacterPage>
    with TickerProviderStateMixin {
  
  late AnimationController _formController;
  late AnimationController _traitsController;
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  CharacterTraits _traits = CharacterTraits.neutral();
  bool _isPublic = false;
  String _selectedGenerationMethod = 'manual'; // 'manual', 'ai', 'photo'
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _traitsController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _formController.forward();
    _traitsController.forward();
  }

  @override
  void dispose() {
    _formController.dispose();
    _traitsController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createCharacter() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isCreating = true);
    
    try {
      final character = Character(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        description: _descriptionController.text,
        appearance: 'Avatar',
        personality: 'Charakter',
        traits: _traits,
        isPublic: _isPublic,
        createdAt: DateTime.now(),
        adoptionCount: 0,
        readCount: 0,
        lastInteractionAt: DateTime.now(),
        level: 1,
        experienceCount: 0,
      );

      await ref.read(charactersProvider.notifier).addCharacter(character);
      
      if (mounted) {
        context.go('/characters/${character.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Erstellen: $e'),
            backgroundColor: const Color(0xFFFF89B3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Avatar erstellen',
      subtitle: 'Erschaffe deinen digitalen Helden',
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF6F8FF), // bg from JSON
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: Form(
          key: _formKey,
          child: CustomScrollView(
            slivers: [
              // Avatar Preview
              SliverToBoxAdapter(
                child: _buildAvatarPreview()
                  .animate(controller: _formController)
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
              ),
              
              // Generation Method Selection
              SliverToBoxAdapter(
                child: _buildGenerationMethodSelector()
                  .animate(controller: _formController)
                  .fadeIn(delay: 200.ms, duration: 500.ms)
                  .slideX(begin: -0.2, curve: Curves.easeOutCubic),
              ),
              
              // Basic Information
              SliverToBoxAdapter(
                child: _buildBasicInformation()
                  .animate(controller: _formController)
                  .fadeIn(delay: 400.ms, duration: 500.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
              ),
              
              // Character Traits
              SliverToBoxAdapter(
                child: _buildCharacterTraits()
                  .animate(controller: _traitsController)
                  .fadeIn(delay: 600.ms, duration: 500.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOutBack),
              ),
              
              // Settings
              SliverToBoxAdapter(
                child: _buildSettings()
                  .animate(controller: _formController)
                  .fadeIn(delay: 800.ms, duration: 500.ms)
                  .slideY(begin: 0.2, curve: Curves.easeOutCubic),
              ),
              
              // Create Button
              SliverToBoxAdapter(
                child: _buildCreateButton()
                  .animate(controller: _formController)
                  .fadeIn(delay: 1000.ms, duration: 500.ms)
                  .slideY(begin: 0.3, curve: Curves.easeOutBack),
              ),
              
              // Bottom padding
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPreview() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar Circle
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF6E77FF).withOpacity(0.3),
                  const Color(0xFF8EE2D2).withOpacity(0.3),
                  const Color(0xFFFF89B3).withOpacity(0.2),
                ],
              ),
              border: Border.all(
                color: const Color(0xFF6E77FF).withOpacity(0.3),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6E77FF).withOpacity(0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Center(
              child: _nameController.text.isNotEmpty
                ? Text(
                    _nameController.text.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E77FF),
                    ),
                  )
                : const Icon(
                    Icons.person_rounded,
                    size: 48,
                    color: Color(0xFF6E77FF),
                  ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Preview Text
          Text(
            _nameController.text.isNotEmpty ? _nameController.text : 'Dein Avatar',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Level ${_traits.courage}', // Mock level based on courage
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerationMethodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
          const Row(
            children: [
              Text('🎨', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Avatar-Erstellung',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Column(
            children: [
              _buildGenerationOption(
                method: 'manual',
                title: 'Manuell erstellen',
                subtitle: 'Eigenschaften selbst festlegen',
                icon: '✋',
              ),
              const SizedBox(height: 12),
              _buildGenerationOption(
                method: 'ai',
                title: 'KI-generiert',
                subtitle: 'Von künstlicher Intelligenz erstellt',
                icon: '🤖',
              ),
              const SizedBox(height: 12),
              _buildGenerationOption(
                method: 'photo',
                title: 'Foto hochladen',
                subtitle: 'Aus eigenem Foto im Anime-Stil',
                icon: '📸',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenerationOption({
    required String method,
    required String title,
    required String subtitle,
    required String icon,
  }) {
    final isSelected = _selectedGenerationMethod == method;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedGenerationMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? const Color(0xFF6E77FF).withOpacity(0.1)
            : const Color(0xFFF6F8FF),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? const Color(0xFF6E77FF)
              : const Color(0xFF6E77FF).withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected 
                  ? const Color(0xFF6E77FF)
                  : const Color(0xFF6E77FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isSelected 
                        ? const Color(0xFF6E77FF)
                        : const Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF475569).withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF6E77FF),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInformation() {
    return Container(
      margin: const EdgeInsets.all(24),
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
          const Row(
            children: [
              Text('📝', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Grundinformationen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Name Input
          TextFormField(
            controller: _nameController,
            onChanged: (_) => setState(() {}), // Trigger avatar preview update
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              labelText: 'Avatar-Name',
              hintText: 'z.B. Luna, Kiko, Max...',
              prefixIcon: const Icon(Icons.person_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF6E77FF).withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF6E77FF),
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Bitte gib einen Namen ein';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          // Description Input
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
            decoration: InputDecoration(
              labelText: 'Beschreibung',
              hintText: 'Erzähle uns von deinem Avatar...',
              prefixIcon: const Icon(Icons.description_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: const Color(0xFF6E77FF).withOpacity(0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF6E77FF),
                  width: 2,
                ),
              ),
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return 'Bitte gib eine Beschreibung ein';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterTraits() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
          const Row(
            children: [
              Text('⭐', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Charaktereigenschaften',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Bestimme die Persönlichkeit deines Avatars',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 20),
          
          // Trait Sliders
          _buildTraitSlider(
            label: 'Mut',
            emoji: '🦁',
            value: _traits.courage,
            color: const Color(0xFF6E77FF),
            onChanged: (value) => setState(() => _traits = _traits.copyWith(courage: value.round())),
          ),
          const SizedBox(height: 16),
          
          _buildTraitSlider(
            label: 'Stärke',
            emoji: '💪',
            value: _traits.courage,
            color: const Color(0xFF8EE2D2),
            onChanged: (value) => setState(() => _traits = _traits.copyWith(courage: value.round())),
          ),
          const SizedBox(height: 16),
          
          _buildTraitSlider(
            label: 'Kreativität',
            emoji: '🎨',
            value: _traits.creativity,
            color: const Color(0xFFFF89B3),
            onChanged: (value) => setState(() => _traits = _traits.copyWith(creativity: value.round())),
          ),
          const SizedBox(height: 16),
          
          _buildTraitSlider(
            label: 'Weisheit',
            emoji: '🧠',
            value: _traits.wisdom,
            color: const Color(0xFFFFC66E),
            onChanged: (value) => setState(() => _traits = _traits.copyWith(wisdom: value.round())),
          ),
          const SizedBox(height: 16),
          
          _buildTraitSlider(
            label: 'Angst (weniger ist besser)',
            emoji: '😰',
            value: _traits.curiosity,
            color: const Color(0xFF9E8CFF),
            onChanged: (value) => setState(() => _traits = _traits.copyWith(curiosity: value.round())),
          ),
        ], 
      ),
    );
  }

  Widget _buildTraitSlider({
    required String label,
    required String emoji,
    required int value,
    required Color color,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                value.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.1),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 100,
            divisions: 10,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
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
          const Row(
            children: [
              Text('⚙️', style: TextStyle(fontSize: 20)),
              SizedBox(width: 8),
              Text(
                'Einstellungen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Public Toggle
          Row(
            children: [
              const Icon(Icons.public_rounded, color: Color(0xFF6E77FF)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Avatar teilen',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      'Anderen Nutzern in der Community zeigen',
                      style: TextStyle(
                        fontSize: 13,
                        color: const Color(0xFF475569).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isPublic,
                onChanged: (value) => setState(() => _isPublic = value),
                activeColor: const Color(0xFF6E77FF),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreateButton() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: GestureDetector(
        onTap: _isCreating ? null : _createCharacter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 56,
          decoration: BoxDecoration(
            gradient: _isCreating 
              ? LinearGradient(
                  colors: [
                    const Color(0xFF475569).withOpacity(0.3),
                    const Color(0xFF475569).withOpacity(0.3),
                  ],
                )
              : const LinearGradient(
                  colors: [Color(0xFF6E77FF), Color(0xFF4B55E6)],
                ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: _isCreating ? null : [
              BoxShadow(
                color: const Color(0xFF6E77FF).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: _isCreating 
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Avatar wird erstellt...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Avatar erstellen',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
          ),
        ),
      ),
    );
  }
}