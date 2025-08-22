// lib/features/stories/presentation/pages/create_story_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../core/services/story_generation_service.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/gradient_card.dart';
import '../../../characters/presentation/providers/characters_provider.dart';
import '../../../characters/domain/entities/character.dart';
import '../../../../core/services/story_generation_service.dart';
import '../widgets/story_generation_result.dart';
import '../../domain/entities/story.dart';

/// Professionelle Story Creation Page für Avatales
/// Vollständige Story-Konfiguration mit funktionierender Generation
class CreateStoryPage extends ConsumerStatefulWidget {
  const CreateStoryPage({super.key});

  @override
  ConsumerState<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends ConsumerState<CreateStoryPage>
    with TickerProviderStateMixin {
  
  // Controllers & Services
  final _promptController = TextEditingController();
  final _settingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _storyService = StoryGenerationService();
  
  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _bounceController;
  
  // Story Configuration State
  String? _selectedCharacterId;
  String _selectedGenre = 'Abenteuer';
  StoryLength _selectedLength = StoryLength.medium;
  int _targetAge = 8;
  String _selectedMood = 'Abenteuerlich';
  final List<String> _selectedLearningGoals = [];
  
  // Generation State
  bool _isGenerating = false;
  Story? _generatedStory;
  String? _errorMessage;
  double _generationProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Animation starten
    _slideController.forward();
    
    // Characters laden
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(charactersProvider.notifier).loadCharacters();
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _settingController.dispose();
    _slideController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final charactersState = ref.watch(charactersProvider);

    return AppScaffold(
      title: 'Geschichte erstellen',
      subtitle: 'Erstelle dein magisches Abenteuer',
      floatingActionButton: _buildGenerateButton(),
      body: _buildConfigurationView(charactersState),
    );
  }

  Widget _buildConfigurationView(AsyncValue<List<Character>> charactersState) {
    return Form(
      key: _formKey,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: 150), // App Bar Abstand
                
                // Character Selection
                _buildCharacterSelection(charactersState)
                    .animate(controller: _slideController)
                    .slideY(begin: 0.3, duration: 600.ms)
                    .fadeIn(),
                
                // Story Configuration
                _buildStoryConfiguration()
                    .animate(controller: _slideController)
                    .slideY(begin: 0.3, duration: 600.ms, delay: 200.ms)
                    .fadeIn(),
                
                // Learning Objectives
                _buildLearningObjectives()
                    .animate(controller: _slideController)
                    .slideY(begin: 0.3, duration: 600.ms, delay: 400.ms)
                    .fadeIn(),
                
                // Generation Progress (wenn generiert wird)
                // if (_isGenerating) _buildGenerationProgress(),
                
                const SizedBox(height: 100), // FAB Abstand
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterSelection(AsyncValue<List<Character>> charactersState) {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎭', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                'Charakter wählen',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          charactersState.when(
            data: (characters) {
              if (characters.isEmpty) {
                return _buildCreateCharacterPrompt();
              }
              
              return _buildCharacterGrid(characters);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Column(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 8),
                  Text(
                    'Fehler beim Laden der Charaktere',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => ref.read(charactersProvider.notifier).loadCharacters(),
                    child: const Text('Erneut versuchen'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateCharacterPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ModernDesignSystem.pastelBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ModernDesignSystem.pastelBlue.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.person_add_rounded,
            size: 48,
            color: ModernDesignSystem.pastelBlue,
          ),
          const SizedBox(height: 12),
          Text(
            'Erstelle zuerst einen Charakter',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Du benötigst mindestens einen Charakter, um Geschichten zu erstellen.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ModernDesignSystem.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => context.go('/characters/create'),
            icon: const Icon(Icons.add),
            label: const Text('Charakter erstellen'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernDesignSystem.pastelBlue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterGrid(List<Character> characters) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: characters.length,
      itemBuilder: (context, index) {
        final character = characters[index];
        final isSelected = _selectedCharacterId == character.id;
        
        return GestureDetector(
          onTap: () => setState(() {
            _selectedCharacterId = character.id;
          }),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? ModernDesignSystem.primaryGradient
                  : LinearGradient(
                      colors: [
                        Colors.grey.shade50,
                        Colors.grey.shade100,
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? ModernDesignSystem.primaryColor
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isSelected 
                          ? Colors.white 
                          : ModernDesignSystem.primaryColor,
                      child: Text(
                        character.displayName[0].toUpperCase(),
                        style: TextStyle(
                          color: isSelected 
                              ? ModernDesignSystem.primaryColor 
                              : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  character.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Level ${character.level}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isSelected 
                        ? Colors.white.withOpacity(0.8)
                        : ModernDesignSystem.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStoryConfiguration() {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📖', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                'Story-Einstellungen',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Story Prompt
          TextFormField(
            controller: _promptController,
            decoration: const InputDecoration(
              labelText: 'Story-Idee',
              hintText: 'z.B. Ein Abenteuer im verzauberten Wald...',
              prefixIcon: Icon(Icons.lightbulb_outline),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Bitte gib eine Story-Idee ein';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          
          // Genre Selection
          _buildDropdownField(
            label: 'Genre',
            value: _selectedGenre,
            items: ['Abenteuer', 'Freundschaft', 'Lernen', 'Fantasy', 'Tiere'],
            onChanged: (value) => setState(() => _selectedGenre = value!),
            icon: Icons.category,
          ),
          const SizedBox(height: 16),
          
          // Length and Age Row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Länge',
                  value: _selectedLength.displayName,
                  items: StoryLength.values.map((e) => e.displayName).toList(),
                  onChanged: (value) => setState(() {
                    _selectedLength = StoryLength.values.firstWhere(
                      (e) => e.displayName == value,
                    );
                  }),
                  icon: Icons.access_time,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildNumberField(
                  label: 'Alter',
                  value: _targetAge,
                  min: 3,
                  max: 12,
                  onChanged: (value) => setState(() => _targetAge = value),
                  icon: Icons.child_care,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Mood and Setting
          _buildDropdownField(
            label: 'Stimmung',
            value: _selectedMood,
            items: ['Abenteuerlich', 'Lustig', 'Spannend', 'Beruhigend', 'Magisch'],
            onChanged: (value) => setState(() => _selectedMood = value!),
            icon: Icons.mood,
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _settingController,
            decoration: const InputDecoration(
              labelText: 'Schauplatz (optional)',
              hintText: 'z.B. Verzauberter Wald, Unterwasser-Stadt...',
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningObjectives() {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                'Lernziele',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            'Wähle, was dein Kind durch die Geschichte lernen soll:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ModernDesignSystem.secondaryTextColor,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildLearningGoalsSelection(),
        ],
      ),
    );
  }

  Widget _buildLearningGoalsSelection() {
    final goals = [
      'Mut entwickeln',
      'Freundschaften schließen',
      'Probleme lösen',
      'Empathie zeigen',
      'Kreativität fördern',
      'Durchhaltevermögen stärken',
      'Teamwork lernen',
      'Selbstvertrauen aufbauen',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: goals.map((goal) {
        final isSelected = _selectedLearningGoals.contains(goal);
        return FilterChip(
          label: Text(goal),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedLearningGoals.add(goal);
              } else {
                _selectedLearningGoals.remove(goal);
              }
            });
          },
          selectedColor: ModernDesignSystem.primaryColor.withOpacity(0.2),
          checkmarkColor: ModernDesignSystem.primaryColor,
        );
      }).toList(),
    );
  }

  Widget _buildGenerationProgress() {
    return GradientCard(
      child: Column(
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Text(
                'Geschichte wird erstellt...',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          LinearProgressIndicator(
            value: _generationProgress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(ModernDesignSystem.primaryColor),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          
          Text(
            '${(_generationProgress * 100).round()}% abgeschlossen',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ModernDesignSystem.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 150),
              
              // Success Animation
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: StoryGenerationResult(
                  story: _generatedStory!,
                ),
              )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.elasticOut)
                  .fadeIn(),
              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    if (_generatedStory != null) {
      return FloatingActionButton.extended(
        onPressed: _startNewStory,
        backgroundColor: ModernDesignSystem.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Neue Geschichte',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    }

    final canGenerate = _selectedCharacterId != null && 
                        _promptController.text.trim().isNotEmpty &&
                        !_isGenerating;

    return FloatingActionButton.extended(
      onPressed: canGenerate ? _generateStory : null,
      backgroundColor: canGenerate 
          ? ModernDesignSystem.primaryColor 
          : Colors.grey.shade400,
      icon: _isGenerating
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            )
          : const Icon(Icons.auto_stories, color: Colors.white),
      label: Text(
        _isGenerating ? 'Erstellt...' : 'Generieren',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Helper Widgets
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: List.generate(max - min + 1, (index) => min + index)
          .map((age) => DropdownMenuItem(
            value: age,
            child: Text('$age Jahre'),
          )).toList(),
      onChanged: (newValue) => onChanged(newValue!),
    );
  }

  // Story Generation Logic
  Future<void> _generateStory() async {
    if (!_formKey.currentState!.validate() || _selectedCharacterId == null) {
      return;
    }

    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generationProgress = 0.0;
    });

    try {
      // Progress Animation
      _animateProgress();
      final charactersAsync = ref.read(charactersProvider);
      final characters = charactersAsync.value;
      if (characters == null) {
        throw Exception('Charaktere konnten nicht geladen werden');
      }
      final character = characters.firstWhere((c) => c.id == _selectedCharacterId);
      
      final request = StoryGenerationRequest(
        prompt: _promptController.text.trim(),
        genre: _selectedGenre,
        length: _selectedLength,
        targetAge: _targetAge,
        mood: _selectedMood,
        setting: _settingController.text.trim().isNotEmpty 
            ? _settingController.text.trim() 
            : null,
        learningObjectives: _selectedLearningGoals,
      );

      final story = await _storyService.generateStory(
        character: character,
        request: request,
      );

      setState(() {
        _generatedStory = story;
        _isGenerating = false;
        _generationProgress = 1.0;
      });

      // Success Animation
      _bounceController.forward();

    } catch (e) {
      setState(() {
        _isGenerating = false;
        _errorMessage = 'Fehler bei der Generierung: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Erneut versuchen',
              textColor: Colors.white,
              onPressed: _generateStory,
            ),
          ),
        );
      }
    }
  }

  void _animateProgress() {
    // Simuliere Progress Animation während der Generation
    const steps = 20;
    const stepDuration = Duration(milliseconds: 100);
    
    for (int i = 0; i <= steps; i++) {
      Future.delayed(stepDuration * i, () {
        if (mounted && _isGenerating) {
          setState(() {
            _generationProgress = (i / steps) * 0.9; // 90% für Generation
          });
        }
      });
    }
  }

  void _regenerateStory() {
    setState(() {
      _generatedStory = null;
    });
    _generateStory();
  }

  void _saveStory() {
    // TODO: Implement story saving
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Geschichte gespeichert!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _startNewStory() {
    setState(() {
      _generatedStory = null;
      _promptController.clear();
      _settingController.clear();
      _selectedLearningGoals.clear();
      _selectedCharacterId = null;
      _generationProgress = 0.0;
    });
  }
}