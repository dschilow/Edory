// lib/features/characters/presentation/pages/avatar_creation_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/gradient_card.dart';
import '../../domain/entities/character_traits.dart';
import '../widgets/character_traits_editor.dart';
import '../widgets/avatar_ai_generator.dart';
import '../widgets/avatar_photo_uploader.dart';

/// Professionelles Avatar Creation System für Avatales
/// Unterstützt KI-Generierung und Foto-Upload mit Disney/Anime-Stil
class AvatarCreationPage extends ConsumerStatefulWidget {
  const AvatarCreationPage({super.key});

  @override
  ConsumerState<AvatarCreationPage> createState() => _AvatarCreationPageState();
}

class _AvatarCreationPageState extends ConsumerState<AvatarCreationPage>
    with TickerProviderStateMixin {
  
  // Controllers
  final PageController _pageController = PageController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  
  // Avatar Creation State
  int _currentStep = 0;
  AvatarCreationMode _selectedMode = AvatarCreationMode.aiGenerated;
  
  // AI Generation Settings
  AvatarAppearance _appearance = AvatarAppearance.neutral();
  CharacterTraits _traits = CharacterTraits.neutral();
  
  // Photo Upload
  File? _uploadedPhoto;
  String? _generatedAvatarUrl;
  bool _isGeneratingAvatar = false;
  
  // Form State
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Avatar erstellen',
      subtitle: 'Erschaffe deinen digitalen Helden',
      body: Column(
        children: [
          const SizedBox(height: 150), // AppBar spacing
          
          // Progress Indicator
          _buildProgressIndicator(),
          
          // Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildModeSelection(),
                _buildAvatarConfiguration(),
                _buildTraitsConfiguration(),
                _buildFinalization(),
              ],
            ),
          ),
          
          // Navigation Buttons
          _buildNavigationButtons(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.08)),
      ),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? ModernDesignSystem.primaryGradient
                        : null,
                    color: isActive 
                        ? null 
                        : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted 
                        ? Icons.check 
                        : _getStepIcon(index),
                    color: isActive ? Colors.white : Colors.grey.shade600,
                    size: 18,
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        gradient: isCompleted
                            ? ModernDesignSystem.primaryGradient
                            : null,
                        color: isCompleted 
                            ? null 
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  IconData _getStepIcon(int step) {
    switch (step) {
      case 0: return Icons.apps;
      case 1: return Icons.face;
      case 2: return Icons.psychology;
      case 3: return Icons.done_all;
      default: return Icons.circle;
    }
  }

  Widget _buildModeSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Wie möchtest du deinen Avatar erstellen?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // KI-Generierung Option
          _buildModeCard(
            mode: AvatarCreationMode.aiGenerated,
            title: 'KI-Generiert',
            subtitle: 'Beschreibe dein Aussehen und die KI erstellt deinen Avatar',
            icon: Icons.auto_awesome,
            features: [
              'Individuelle Anpassung',
              'Disney/Anime-Stil',
              'Sofortige Generierung',
              'Unbegrenzte Variationen',
            ],
            gradient: ModernDesignSystem.primaryGradient,
          )
              .animate(delay: 200.ms)
              .slideX(begin: -0.3, duration: 600.ms)
              .fadeIn(),
          
          const SizedBox(height: 20),
          
          // Foto-Upload Option
          _buildModeCard(
            mode: AvatarCreationMode.photoUpload,
            title: 'Foto hochladen',
            subtitle: 'Lade dein Foto hoch und wir verwandeln es in einen Avatar',
            icon: Icons.photo_camera,
            features: [
              'Aus eigenem Foto',
              'Kamera oder Galerie',
              'Automatische Stilisierung',
              'Sichere Verarbeitung',
            ],
            gradient: ModernDesignSystem.greenGradient,
          )
              .animate(delay: 400.ms)
              .slideX(begin: 0.3, duration: 600.ms)
              .fadeIn(),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required AvatarCreationMode mode,
    required String title,
    required String subtitle,
    required IconData icon,
    required List<String> features,
    required LinearGradient gradient,
  }) {
    final isSelected = _selectedMode == mode;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? gradient.colors.first.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? Colors.white.withOpacity(0.2)
                        : gradient.colors.first.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: isSelected 
                        ? Colors.white 
                        : gradient.colors.first,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected 
                              ? Colors.white.withOpacity(0.9)
                              : ModernDesignSystem.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Features List
            ...features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: isSelected 
                        ? Colors.white.withOpacity(0.8)
                        : gradient.colors.first,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    feature,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isSelected 
                          ? Colors.white.withOpacity(0.9)
                          : ModernDesignSystem.secondaryTextColor,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarConfiguration() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: _selectedMode == AvatarCreationMode.aiGenerated
          ? _buildAIConfiguration()
          : _buildPhotoUpload(),
    );
  }

  Widget _buildAIConfiguration() {
    return Column(
      children: [
        Text(
          'Beschreibe dein Aussehen',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        AvatarAIGenerator(
          appearance: _appearance,
          onAppearanceChanged: (appearance) {
            setState(() => _appearance = appearance);
          },
          onGeneratePressed: _generateAIAvatar,
          isGenerating: _isGeneratingAvatar,
          generatedImageUrl: _generatedAvatarUrl,
        ),
      ],
    );
  }

  Widget _buildPhotoUpload() {
    return Column(
      children: [
        Text(
          'Foto für Avatar hochladen',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        
        AvatarPhotoUploader(
          uploadedPhoto: _uploadedPhoto,
          onPhotoSelected: (photo) {
            setState(() => _uploadedPhoto = photo);
          },
          onGeneratePressed: _generatePhotoAvatar,
          isGenerating: _isGeneratingAvatar,
          generatedImageUrl: _generatedAvatarUrl,
        ),
      ],
    );
  }

  Widget _buildTraitsConfiguration() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Persönliche Eigenschaften',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Diese Eigenschaften beeinflussen die Geschichten deines Avatars',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ModernDesignSystem.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          CharacterTraitsEditor(
            initialTraits: _traits,
            onChanged: (traits) => setState(() => _traits = traits),
            showPresets: true,
            animated: true,
          ),
        ],
      ),
    );
  }

  Widget _buildFinalization() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Avatar vervollständigen',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Avatar Preview
            _buildAvatarPreview(),
            
            const SizedBox(height: 24),
            
            // Name and Description
            GradientCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Avatar-Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Avatar-Name',
                      hintText: 'z.B. Luna die Entdeckerin',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bitte gib einen Namen ein';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Beschreibung',
                      hintText: 'Beschreibe deinen Avatar...',
                      prefixIcon: Icon(Icons.description),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Bitte gib eine Beschreibung ein';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarPreview() {
    return GradientCard(
      child: Column(
        children: [
          Text(
            'Dein Avatar',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: ModernDesignSystem.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: ModernDesignSystem.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: _generatedAvatarUrl != null
                ? ClipOval(
                    child: Image.network(
                      _generatedAvatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(),
                    ),
                  )
                : _uploadedPhoto != null
                    ? ClipOval(
                        child: Image.file(
                          _uploadedPhoto!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : _buildAvatarPlaceholder(),
          ),
          const SizedBox(height: 16),
          
          Text(
            _nameController.text.isNotEmpty 
                ? _nameController.text
                : 'Mein Avatar',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          
          // Traits Summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: ModernDesignSystem.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Stärkste Eigenschaft: ${_traits.dominantTrait}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ModernDesignSystem.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Icon(
      Icons.person,
      size: 60,
      color: Colors.white,
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _previousStep,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Zurück'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          
          if (_currentStep > 0) const SizedBox(width: 16),
          
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: ElevatedButton.icon(
              onPressed: _canProceed() ? _nextStep : null,
              icon: Icon(_currentStep == 3 ? Icons.save : Icons.arrow_forward),
              label: Text(_currentStep == 3 ? 'Avatar erstellen' : 'Weiter'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernDesignSystem.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Navigation Logic
  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return true; // Mode selected by default
      case 1:
        return _selectedMode == AvatarCreationMode.aiGenerated
            ? _generatedAvatarUrl != null
            : _generatedAvatarUrl != null || _uploadedPhoto != null;
      case 2:
        return true; // Traits can be default
      case 3:
        return _nameController.text.trim().isNotEmpty &&
               _descriptionController.text.trim().isNotEmpty;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _createAvatar();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  // Avatar Generation Logic
  Future<void> _generateAIAvatar() async {
    setState(() => _isGeneratingAvatar = true);
    
    try {
      // TODO: Integrate with AI image generation service
      await Future.delayed(const Duration(seconds: 3)); // Simulate API call
      
      // Mock generated avatar URL
      setState(() {
        _generatedAvatarUrl = 'https://api.dicebear.com/7.x/avataaars/png?seed=${_appearance.toString()}';
        _isGeneratingAvatar = false;
      });
      
    } catch (e) {
      setState(() => _isGeneratingAvatar = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler bei der Avatar-Generierung: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _generatePhotoAvatar() async {
    if (_uploadedPhoto == null) return;
    
    setState(() => _isGeneratingAvatar = true);
    
    try {
      // TODO: Integrate with photo-to-avatar AI service
      await Future.delayed(const Duration(seconds: 4)); // Simulate processing
      
      // Mock stylized avatar URL
      setState(() {
        _generatedAvatarUrl = 'https://api.dicebear.com/7.x/avataaars/png?seed=photo_${DateTime.now().millisecondsSinceEpoch}';
        _isGeneratingAvatar = false;
      });
      
    } catch (e) {
      setState(() => _isGeneratingAvatar = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler bei der Foto-Verarbeitung: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createAvatar() async {
    if (!_formKey.currentState!.validate()) return;
    
    // TODO: Save avatar to backend/database
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avatar erfolgreich erstellt!'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Navigate back to characters page
    context.go('/characters');
  }
}

// Enums and Data Classes
enum AvatarCreationMode {
  aiGenerated,
  photoUpload,
}

class AvatarAppearance {
  const AvatarAppearance({
    required this.age,
    required this.gender,
    required this.skinTone,
    required this.hairColor,
    required this.hairStyle,
    required this.eyeColor,
    required this.bodyType,
    required this.style,
  });

  factory AvatarAppearance.neutral() => const AvatarAppearance(
    age: AvatarAge.child,
    gender: AvatarGender.neutral,
    skinTone: SkinTone.medium,
    hairColor: HairColor.brown,
    hairStyle: HairStyle.medium,
    eyeColor: EyeColor.brown,
    bodyType: BodyType.average,
    style: AvatarStyle.disney,
  );

  final AvatarAge age;
  final AvatarGender gender;
  final SkinTone skinTone;
  final HairColor hairColor;
  final HairStyle hairStyle;
  final EyeColor eyeColor;
  final BodyType bodyType;
  final AvatarStyle style;

  AvatarAppearance copyWith({
    AvatarAge? age,
    AvatarGender? gender,
    SkinTone? skinTone,
    HairColor? hairColor,
    HairStyle? hairStyle,
    EyeColor? eyeColor,
    BodyType? bodyType,
    AvatarStyle? style,
  }) {
    return AvatarAppearance(
      age: age ?? this.age,
      gender: gender ?? this.gender,
      skinTone: skinTone ?? this.skinTone,
      hairColor: hairColor ?? this.hairColor,
      hairStyle: hairStyle ?? this.hairStyle,
      eyeColor: eyeColor ?? this.eyeColor,
      bodyType: bodyType ?? this.bodyType,
      style: style ?? this.style,
    );
  }
}

enum AvatarAge {
  child('Kind'),
  teen('Jugendlich'),
  adult('Erwachsen');

  const AvatarAge(this.displayName);
  final String displayName;
}

enum AvatarGender {
  neutral('Neutral'),
  feminine('Weiblich'),
  masculine('Männlich');

  const AvatarGender(this.displayName);
  final String displayName;
}

enum SkinTone {
  light('Hell'),
  medium('Mittel'),
  dark('Dunkel'),
  tan('Gebräunt');

  const SkinTone(this.displayName);
  final String displayName;
}

enum HairColor {
  blonde('Blond'),
  brown('Braun'),
  black('Schwarz'),
  red('Rot'),
  gray('Grau'),
  colorful('Bunt');

  const HairColor(this.displayName);
  final String displayName;
}

enum HairStyle {
  short('Kurz'),
  medium('Mittel'),
  long('Lang'),
  curly('Lockig'),
  straight('Glatt');

  const HairStyle(this.displayName);
  final String displayName;
}

enum EyeColor {
  brown('Braun'),
  blue('Blau'),
  green('Grün'),
  gray('Grau'),
  hazel('Haselnuss');

  const EyeColor(this.displayName);
  final String displayName;
}

enum BodyType {
  slim('Schlank'),
  average('Durchschnitt'),
  athletic('Sportlich');

  const BodyType(this.displayName);
  final String displayName;
}

enum AvatarStyle {
  disney('Disney'),
  anime('Anime'),
  realistic('Realistisch'),
  cartoon('Cartoon');

  const AvatarStyle(this.displayName);
  final String displayName;
}