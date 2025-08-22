// lib/features/stories/presentation/pages/create_story_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../core/services/openai_service.dart' as openai;
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../characters/presentation/providers/characters_provider.dart';
import '../../../characters/domain/entities/character.dart';
import '../../../characters/domain/entities/character_traits.dart';
import '../widgets/story_generation_result.dart';

/// Professional Story Creation Page - Apple-Quality UI für Avatales
/// 5-Schritt Story-Generierung mit modernem kinderfreundlichem Design
class CreateStoryPage extends ConsumerStatefulWidget {
  const CreateStoryPage({super.key});

  @override
  ConsumerState<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends ConsumerState<CreateStoryPage>
    with TickerProviderStateMixin {
  
  // Page Controller für horizontalen Swipe zwischen Schritten
  late PageController _pageController;
  late AnimationController _springController;
  late AnimationController _glowController;
  
  // Form Controllers
  final _titleController = TextEditingController();
  final _promptController = TextEditingController();
  final _forbiddenTopicsController = TextEditingController();
  final _forbiddenWordsController = TextEditingController();
  
  // Services
  
  // State
  int _currentStep = 0;
  String? _selectedCharacterId;
  String _storyLength = 'Mittel';
  bool _learningModeEnabled = false;
  List<String> _selectedGoals = [];
  List<String> _forbiddenTopics = [];
  List<String> _forbiddenWords = [];
  double _difficultyLevel = 3.0;
  bool _isGenerating = false;
  openai.StoryGenerationResult? _generatedStory;
  String? _errorMessage;

  // Design Constants basierend auf dem JSON
  static const _stepTitles = [
    'Avatar wählen',
    'Geschichte',
    'Lernmodus',
    'Zusammenfassung'
  ];
  
  static const _storyLengths = ['Kurz', 'Mittel', 'Lang'];
  static const _learningGoals = [
    'Mut', 'Wortschatz', 'Wissen', 'Empathie', 'Kreativität',
    'Problemlösung', 'Soziale Kompetenzen', 'Umweltbewusstsein'
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _springController = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _springController.forward();
    _glowController.repeat(reverse: true);
    
    // Load characters
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(charactersProvider.notifier).loadCharacters();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _springController.dispose();
    _glowController.dispose();
    _titleController.dispose();
    _promptController.dispose();
    _forbiddenTopicsController.dispose();
    _forbiddenWordsController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      _generateStory();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _generateStory() async {
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
    });

    try {
      // Story generation logic hier
      await Future.delayed(const Duration(seconds: 2)); // Mock delay
        setState(() {
          _generatedStory = openai.StoryGenerationResult(
            content: 'Eine wunderbare Geschichte wurde generiert...',
            isAiGenerated: true,
            tokensUsed: 150,
            model: 'gpt-5-nano',
            generatedAt: DateTime.now(),
              settings: openai.StorySettings(
                characterName: 'Luna',
                genre: 'Fantasy',
                length: openai.StoryLength.medium,
                complexity: openai.StoryComplexity.medium,
                targetAge: 8,
                learningObjectives: ['Kreativität', 'Fantasie'],
              ),
            );
            _isGenerating = false;
        });
      } catch (e) {
        setState(() {
          _errorMessage = 'Fehler bei der Generierung: ${e.toString()}';
          _isGenerating = false;
        });
      }
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0: return _selectedCharacterId != null;
      case 1: return _titleController.text.isNotEmpty && _promptController.text.isNotEmpty;
      case 2: return true; // Lernmodus ist optional
      case 3: return true; // Zusammenfassung zeigt nur an
      default: return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Geschichte generieren',
      subtitle: 'Erstelle dein magisches Abenteuer',
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF6F8FF), // bg from JSON
              const Color(0xFFFFFFFF).withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            // Progress Indicator - 5 Segmente wie im JSON
            _buildProgressIndicator(),
            
            // Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildAvatarSelection(),
                  _buildStorySetup(),
                  _buildLearningMode(),
                  _buildSummary(),
                ],
              ),
            ),
            
            // Navigation Buttons
            _buildNavigationButtons(),
          ],
        ),
      ).animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeOut)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Row(
        children: List.generate(4, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Container(
              height: 8,
              margin: EdgeInsets.only(
                right: index < 3 ? 8 : 0,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), // radius.xs from JSON
                color: isActive 
                  ? const Color(0xFF6E77FF) // primary from JSON
                  : const Color(0xFF475569).withOpacity(0.2), // textSecondary
                boxShadow: isActive ? [
                  BoxShadow(
                    color: const Color(0xFF6E77FF).withOpacity(0.18), // cardGlow
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
              child: isCompleted 
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  ).animate(target: 1)
                    .scale(duration: 200.ms, curve: Curves.elasticOut)
                : null,
            ),
          );
        }),
      ),
    ).animate()
      .slideX(begin: -0.2, duration: 400.ms, curve: Curves.easeOutBack);
  }

  Widget _buildAvatarSelection() {
    final charactersState = ref.watch(charactersProvider);
    
    return charactersState.when(
      data: (characters) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Wähle deinen Helden',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A), // textPrimary
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mit welchem Avatar möchtest du dein Abenteuer erleben?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF475569), // textSecondary
              ),
            ),
            const SizedBox(height: 32),
            
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final character = characters[index];
                  final isSelected = _selectedCharacterId == character.id;
                  
                  return _buildAvatarCard(character, isSelected);
                },
              ),
            ),
          ],
        ),
      ).animate()
        .fadeIn(delay: 200.ms, duration: 400.ms)
        .slideY(begin: 0.2, curve: Curves.easeOutCubic),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Fehler beim Laden der Avatare')),
    );
  }

  Widget _buildAvatarCard(Character character, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedCharacterId = character.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // radius.md from JSON
          color: Colors.white,
          border: Border.all(
            color: isSelected 
              ? const Color(0xFF6E77FF) // primary
              : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                ? const Color(0xFF6E77FF).withOpacity(0.18) // cardGlow
                : Colors.black.withOpacity(0.08),
              blurRadius: isSelected ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar Bild (88px wie AvatarTile im JSON)
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(44),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6E77FF).withOpacity(0.2),
                      const Color(0xFF8EE2D2).withOpacity(0.2),
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    character.displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6E77FF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Name
              Text(
                character.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              
              // Level
              Text(
                'Level ${character.traits.courage}', // Mock level
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),
              
              // Badges für Eigenschaften
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatBadge('🦁', character.traits.courage, const Color(0xFF6E77FF)),
                  _buildStatBadge('💪', character.traits.courage, const Color(0xFF8EE2D2)),
                  _buildStatBadge('❤️', 100 - character.traits.courage, const Color(0xFFFF89B3)),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate(target: isSelected ? 1 : 0)
      .scale(end: Offset(1.05, 1.05), curve: Curves.easeOutBack);
  }

  Widget _buildStatBadge(String emoji, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(40), // radius.xl
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 2),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorySetup() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Deine Geschichte',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Erzähle uns, welches Abenteuer du erleben möchtest',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 32),
            
            // Title Input
            _buildInputCard(
              label: 'Titel',
              controller: _titleController,
              hint: 'Das Abenteuer im Zauberwald',
              icon: '📖',
            ),
            
            const SizedBox(height: 20),
            
            // Prompt Input
            _buildInputCard(
              label: 'Dein Prompt',
              controller: _promptController,
              hint: 'Ich möchte eine Geschichte über...',
              icon: '✨',
              maxLines: 4,
            ),
            
            const SizedBox(height: 20),
            
            // Story Length
            _buildLengthSelector(),
          ],
        ),
      ),
    ).animate()
      .fadeIn(delay: 200.ms, duration: 400.ms)
      .slideX(begin: 0.2, curve: Curves.easeOutCubic);
  }

  Widget _buildInputCard({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              maxLines: maxLines,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: const Color(0xFF475569).withOpacity(0.6),
                ),
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
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLengthSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('📏', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  'Länge',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: _storyLengths.map((length) {
                final isSelected = _storyLength == length;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _storyLength = length),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected 
                          ? const Color(0xFF6E77FF)
                          : const Color(0xFFF6F8FF),
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(
                          color: isSelected 
                            ? const Color(0xFF6E77FF)
                            : const Color(0xFF6E77FF).withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        length,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected 
                            ? Colors.white
                            : const Color(0xFF6E77FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningMode() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lernmodus',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Möchtest du beim Lesen auch etwas lernen?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 32),
            
            // Learning Mode Toggle
            _buildLearningToggle(),
            
            if (_learningModeEnabled) ...[
              const SizedBox(height: 24),
              _buildLearningGoals(),
              const SizedBox(height: 24),
              _buildForbiddenTopics(),
              const SizedBox(height: 24),
              _buildDifficultySlider(),
            ],
          ],
        ),
      ),
    ).animate()
      .fadeIn(delay: 200.ms, duration: 400.ms)
      .slideX(begin: -0.2, curve: Curves.easeOutCubic);
  }

  Widget _buildLearningToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Text('🎓', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lernmodus aktivieren',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Integriere Lernziele in deine Geschichte',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF475569).withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _learningModeEnabled,
              onChanged: (value) => setState(() => _learningModeEnabled = value),
              activeColor: const Color(0xFF6E77FF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningGoals() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('🎯', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  'Lernziele',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _learningGoals.map((goal) {
                final isSelected = _selectedGoals.contains(goal);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedGoals.remove(goal);
                      } else {
                        _selectedGoals.add(goal);
                      }
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? const Color(0xFF6E77FF)
                        : const Color(0xFFF6F8FF),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: isSelected 
                          ? const Color(0xFF6E77FF)
                          : const Color(0xFF6E77FF).withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      goal,
                      style: TextStyle(
                        color: isSelected 
                          ? Colors.white
                          : const Color(0xFF6E77FF),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForbiddenTopics() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('🚫', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  'Verbotene Themen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _forbiddenTopicsController,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                hintText: 'z.B. Spinnen, Gewalt, Dunkelheit...',
                hintStyle: TextStyle(
                  color: const Color(0xFF475569).withOpacity(0.6),
                ),
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
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultySlider() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text('📊', style: TextStyle(fontSize: 20)),
                SizedBox(width: 8),
                Text(
                  'Schwierigkeitsgrad',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
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
                value: _difficultyLevel,
                min: 1,
                max: 5,
                divisions: 4,
                label: 'Level ${_difficultyLevel.round()}',
                onChanged: (value) => setState(() => _difficultyLevel = value),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Einfach',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF475569).withOpacity(0.8),
                  ),
                ),
                Text(
                  'Schwer',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF475569).withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    final selectedCharacter = ref.watch(charactersProvider).valueOrNull
        ?.where((c) => c.id == _selectedCharacterId)
        .firstOrNull;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zusammenfassung',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Alles bereit für dein Abenteuer?',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 32),
            
            // Summary Cards
            _buildSummaryCard(
              icon: '👤',
              title: 'Avatar',
              content: selectedCharacter?.displayName ?? 'Nicht ausgewählt',
            ),
            const SizedBox(height: 16),
            
            _buildSummaryCard(
              icon: '📖',
              title: 'Geschichte',
              content: '${_titleController.text}\n${_promptController.text}',
            ),
            const SizedBox(height: 16),
            
            _buildSummaryCard(
              icon: '📏',
              title: 'Länge',
              content: _storyLength,
            ),
            
            if (_learningModeEnabled) ...[
              const SizedBox(height: 16),
              _buildSummaryCard(
                icon: '🎓',
                title: 'Lernmodus',
                content: 'Aktiv - ${_selectedGoals.length} Ziele ausgewählt',
              ),
            ],
          ],
        ),
      ),
    ).animate()
      .fadeIn(delay: 200.ms, duration: 400.ms)
      .slideY(begin: 0.2, curve: Curves.easeOutCubic);
  }

  Widget _buildSummaryCard({
    required String icon,
    required String title,
    required String content,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF475569).withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Back Button
            if (_currentStep > 0)
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: _previousStep,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FF),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFF6E77FF).withOpacity(0.2),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Zurück',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6E77FF),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            
            if (_currentStep > 0) const SizedBox(width: 16),
            
            // Next/Generate Button
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _canProceed 
                  ? (_isGenerating ? null : _nextStep)
                  : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: _canProceed 
                      ? const LinearGradient(
                          colors: [Color(0xFF6E77FF), Color(0xFF4B55E6)],
                        )
                      : LinearGradient(
                          colors: [
                            const Color(0xFF475569).withOpacity(0.3),
                            const Color(0xFF475569).withOpacity(0.3),
                          ],
                        ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _canProceed ? [
                      BoxShadow(
                        color: const Color(0xFF6E77FF).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ] : null,
                  ),
                  child: Center(
                    child: _isGenerating 
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
                              'Generiere...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          _currentStep == 3 ? 'Generieren' : 'Weiter',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _canProceed 
                              ? Colors.white 
                              : const Color(0xFF475569).withOpacity(0.6),
                          ),
                        ),
                  ),
                ),
              ).animate(target: _canProceed ? 1 : 0)
                .scaleXY(end: 1.02, curve: Curves.easeOutBack),
            ),
          ],
        ),
      ),
    );
  }
}