// lib/features/stories/presentation/pages/create_story_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/modern_design_system.dart';
export '../../../../core/theme/modern_design_system.dart';
import '../../../../core/services/openai_service.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
// unused legacy imports removed
import '../../../characters/presentation/providers/characters_provider.dart';
import '../../../characters/domain/entities/character.dart';
import '../../../characters/domain/entities/character_traits.dart';
import '../widgets/story_generation_result.dart';

/// Professional Story Creation Page - Apple-Quality UI
/// Vollständige Story-Konfiguration mit allen Einstellungen
class CreateStoryPage extends ConsumerStatefulWidget {
  const CreateStoryPage({super.key});

  @override
  ConsumerState<CreateStoryPage> createState() => _CreateStoryPageState();
}

class _CreateStoryPageState extends ConsumerState<CreateStoryPage>
    with TickerProviderStateMixin {
  // Controllers
  final _promptController = TextEditingController();
  final _settingController = TextEditingController();
  final _moodController = TextEditingController();
  
  // Services
  final _openAIService = OpenAIService();
  
  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  
  // Form State
  final _formKey = GlobalKey<FormState>();
  
  // Story Configuration
  String? _selectedCharacterId;
  String _selectedGenre = 'Abenteuer';
  StoryLength _selectedLength = StoryLength.medium;
  StoryComplexity _selectedComplexity = StoryComplexity.medium;
  int _targetAge = 8;
  String? _selectedMood;
  String? _customSetting;
  
  // Learning Objectives
  final List<String> _selectedLearningGoals = [];
  bool _includeEducationalElements = true;
  bool _includeMoralLesson = true;
  
  // Generation State
  bool _isGenerating = false;
  StoryGenerationResult? _generatedStory;
  String? _errorMessage;
  
  // Data
  final List<String> _genres = [
    'Abenteuer', 'Fantasy', 'Märchen', 'Freundschaft', 'Familie', 
    'Tiere', 'Weltraum', 'Unterwasser', 'Magie', 'Detektiv',
    'Piraten', 'Prinzessinnen', 'Dinosaurier', 'Roboter', 'Zeitreise'
  ];
  
  final List<String> _moods = [
    'Aufregend', 'Friedlich', 'Geheimnisvoll', 'Lustig', 'Romantisch',
    'Spannend', 'Magisch', 'Entspannend', 'Energiegeladen', 'Nachdenklich'
  ];
  
  final List<String> _learningGoals = [
    '🦁 Mut entwickeln',
    '📖 Vokabular erweitern',
    '❤️ Empathie fördern',
    '🎨 Kreativität stärken',
    '🧩 Problemlösung lernen',
    '👥 Soziale Kompetenzen',
    '🌱 Umweltbewusstsein',
    '🏃‍♀️ Gesunde Gewohnheiten',
    '🎵 Musikalität',
    '🔢 Mathematik verstehen',
    '🔬 Wissenschaft entdecken',
    '🌍 Kulturen kennenlernen',
  ];

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: ModernDesignSystem.durationMedium,
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: ModernDesignSystem.durationLong,
      vsync: this,
    );
    
    _slideController.forward();
    _fadeController.forward();
    
    // Load characters when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(charactersProvider.notifier).loadCharacters();
      final characters = ref.read(charactersProvider).valueOrNull ?? [];
      if (characters.isNotEmpty && _selectedCharacterId == null) {
        setState(() {
          _selectedCharacterId = characters.first.id;
        });
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _settingController.dispose();
    _moodController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final charactersState = ref.watch(charactersProvider);
    
    return AppScaffold(
      title: 'Geschichte erstellen',
      subtitle: 'KI-gestützte Storytelling',
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 150), // Header space
                  
                  // Character Selection Card
                  _buildCharacterSelectionCard(charactersState),
                  
                  // Story Prompt Card
                  _buildStoryPromptCard(),
                  
                  // Basic Settings Card
                  _buildBasicSettingsCard(),
                  
                  // Advanced Settings Card
                  _buildAdvancedSettingsCard(),
                  
                  // Learning Objectives Card
                  _buildLearningObjectivesCard(),
                  
                  // Generate Button
                  _buildGenerateButton(),
                  const SizedBox(height: 100),
                  
                  // Story Result
                  if (_generatedStory != null)
                    StoryGenerationResultWidget(
                      result: _generatedStory!,
                    ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Character Selection Card
  Widget _buildCharacterSelectionCard(AsyncValue<List<Character>> charactersState) {
    return iOSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ModernDesignSystem.accentBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person,
                  color: ModernDesignSystem.accentBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: ModernDesignSystem.spacing12),
              Text(
                'Charakter auswählen',
                style: ModernDesignSystem.title3.copyWith(
                  color: ModernDesignSystem.labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernDesignSystem.spacing16),
          
          charactersState.when(
            data: (List<Character> characters) {
              if (characters.isEmpty) {
                return Container(
                  padding: const EdgeInsets.all(ModernDesignSystem.spacing20),
                  decoration: BoxDecoration(
                    color: ModernDesignSystem.systemGray6,
                    borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.group_add,
                        size: 48,
                        color: ModernDesignSystem.systemGray,
                      ),
                      const SizedBox(height: ModernDesignSystem.spacing8),
                      Text(
                        'Noch keine Charaktere',
                        style: ModernDesignSystem.headline.copyWith(
                          color: ModernDesignSystem.secondaryLabel,
                        ),
                      ),
                      const SizedBox(height: ModernDesignSystem.spacing4),
                      Text(
                        'Erstelle zuerst einen Charakter',
                        style: ModernDesignSystem.footnote.copyWith(
                          color: ModernDesignSystem.tertiaryLabel,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return DropdownButtonFormField<String>(
                value: _selectedCharacterId,
                decoration: InputDecoration(
                  labelText: 'Hauptcharakter',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ModernDesignSystem.radiusMedium),
                  ),
                ),
                items: characters.map<DropdownMenuItem<String>>((character) {
                  return DropdownMenuItem<String>(
                    value: character.id,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: ModernDesignSystem.accentBlue.withOpacity(0.1),
                          child: Text(
                            character.name.isNotEmpty ? character.name[0].toUpperCase() : '?',
                            style: ModernDesignSystem.footnote.copyWith(
                              color: ModernDesignSystem.accentBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: ModernDesignSystem.spacing8),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                character.name,
                                style: ModernDesignSystem.body.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (character.description.isNotEmpty)
                                Text(
                                  character.description.length > 30
                                      ? '${character.description.substring(0, 30)}...'
                                      : character.description,
                                  style: ModernDesignSystem.caption1.copyWith(
                                    color: ModernDesignSystem.secondaryLabel,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedCharacterId = value),
                validator: (value) => value == null ? 'Bitte wähle einen Charakter' : null,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fehler beim Laden der Charaktere', style: ModernDesignSystem.headline),
                const SizedBox(height: 8),
                Text('$error', style: ModernDesignSystem.footnote.copyWith(color: Colors.redAccent)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Story Prompt Card
  Widget _buildStoryPromptCard() {
    return iOSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ModernDesignSystem.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_stories,
                  color: ModernDesignSystem.accentGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: ModernDesignSystem.spacing12),
              Text(
                'Story-Idee',
                style: ModernDesignSystem.title3.copyWith(
                  color: ModernDesignSystem.labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernDesignSystem.spacing16),
          
          TextFormField(
            controller: _promptController,
            decoration: const InputDecoration(
              labelText: 'Deine Geschichte beginnt mit...',
              hintText: 'z.B. "Ein mysteriöser Brief führt zu einem versteckten Schatz"',
              prefixIcon: Icon(Icons.lightbulb_outline),
            ),
            maxLines: 3,
            // Validator optional gemacht: Wenn leer, nutzen wir Standard-Prompt
            validator: (value) {
              return null;
            },
          ),
          
          const SizedBox(height: ModernDesignSystem.spacing12),
          
          // Quick Prompt Suggestions
          Text(
            'Schnelle Ideen:',
            style: ModernDesignSystem.footnote.copyWith(
              color: ModernDesignSystem.secondaryLabel,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ModernDesignSystem.spacing8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Zeitreise ins Mittelalter',
              'Sprechende Tiere im Wald',
              'Unterwasserabenteuer',
              'Magische Superkräfte',
              'Raumschiff-Mission',
            ].map((suggestion) => GestureDetector(
              onTap: () => _promptController.text = suggestion,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: ModernDesignSystem.systemGray6,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: ModernDesignSystem.systemGray4,
                    width: 0.5,
                  ),
                ),
                child: Text(
                  suggestion,
                  style: ModernDesignSystem.caption1.copyWith(
                    color: ModernDesignSystem.accentBlue,
                  ),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  /// Basic Settings Card
  Widget _buildBasicSettingsCard() {
    return iOSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ModernDesignSystem.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.tune,
                  color: ModernDesignSystem.accentOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: ModernDesignSystem.spacing12),
              Text(
                'Grundeinstellungen',
                style: ModernDesignSystem.title3.copyWith(
                  color: ModernDesignSystem.labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernDesignSystem.spacing20),
          
          // Genre Selection
          Text(
            'Genre',
            style: ModernDesignSystem.headline.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ModernDesignSystem.spacing8),
          
          DropdownButtonFormField<String>(
            value: _selectedGenre,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.category_outlined),
            ),
            items: _genres.map((genre) {
              return DropdownMenuItem<String>(
                value: genre,
                child: Text(genre),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedGenre = value!),
          ),
          
          const SizedBox(height: ModernDesignSystem.spacing16),
          
          // Story Length
          Text(
            'Geschichtenlänge',
            style: ModernDesignSystem.headline.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ModernDesignSystem.spacing8),
          
          SegmentedButton<StoryLength>(
            segments: StoryLength.values.map((length) {
              return ButtonSegment(
                value: length,
                label: Text(length.displayName),
              );
            }).toList(),
            selected: {_selectedLength},
            onSelectionChanged: (selection) {
              setState(() => _selectedLength = selection.first);
            },
          ),
          
          const SizedBox(height: ModernDesignSystem.spacing16),
          
          // Target Age
          Text(
            'Zielgruppe: ${_targetAge} Jahre',
            style: ModernDesignSystem.headline.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ModernDesignSystem.spacing8),
          
          Slider(
            value: _targetAge.toDouble(),
            min: 3,
            max: 16,
            divisions: 13,
            label: '$_targetAge Jahre',
            onChanged: (value) => setState(() => _targetAge = value.round()),
          ),
        ],
      ),
    );
  }

  /// Advanced Settings Card
  Widget _buildAdvancedSettingsCard() {
    return iOSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ModernDesignSystem.accentOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.settings,
                  color: ModernDesignSystem.accentOrange,
                  size: 24,
                ),
              ),
              const SizedBox(width: ModernDesignSystem.spacing12),
              Text(
                'Erweiterte Einstellungen',
                style: ModernDesignSystem.title3.copyWith(
                  color: ModernDesignSystem.labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernDesignSystem.spacing20),
          
          // Story Complexity
          Text(
            'Komplexität',
            style: ModernDesignSystem.headline.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ModernDesignSystem.spacing8),
          
          SegmentedButton<StoryComplexity>(
            segments: StoryComplexity.values.map((complexity) {
              return ButtonSegment(
                value: complexity,
                label: Text(complexity.displayName),
              );
            }).toList(),
            selected: {_selectedComplexity},
            onSelectionChanged: (selection) {
              setState(() => _selectedComplexity = selection.first);
            },
          ),
          
          const SizedBox(height: ModernDesignSystem.spacing16),
          
          // Mood Selection
          Text(
            'Stimmung (Optional)',
            style: ModernDesignSystem.headline.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ModernDesignSystem.spacing8),
          
          DropdownButtonFormField<String?>(
            value: _selectedMood,
            decoration: const InputDecoration(
              hintText: 'Wähle eine Stimmung',
              prefixIcon: Icon(Icons.mood),
            ),
            items: <DropdownMenuItem<String?>>[
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Keine spezielle Stimmung'),
              ),
              ..._moods
                  .map<DropdownMenuItem<String?>>((mood) => DropdownMenuItem<String?>(
                        value: mood,
                        child: Text(mood),
                      ))
                  .toList(),
            ],
            onChanged: (value) => setState(() => _selectedMood = value),
          ),
          
          const SizedBox(height: ModernDesignSystem.spacing16),
          
          // Custom Setting
          TextFormField(
            controller: _settingController,
            decoration: const InputDecoration(
              labelText: 'Schauplatz (Optional)',
              hintText: 'z.B. "In einem verzauberten Wald"',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
        ],
      ),
    );
  }

  /// Learning Objectives Card
  Widget _buildLearningObjectivesCard() {
    return iOSCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ModernDesignSystem.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.school,
                  color: ModernDesignSystem.accentPurple,
                  size: 24,
                ),
              ),
              const SizedBox(width: ModernDesignSystem.spacing12),
              Text(
                'Lernziele',
                style: ModernDesignSystem.title3.copyWith(
                  color: ModernDesignSystem.labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: ModernDesignSystem.spacing16),
          
          // Educational Elements Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pädagogische Elemente',
                style: ModernDesignSystem.body,
              ),
              Switch(
                value: _includeEducationalElements,
                onChanged: (value) => setState(() => _includeEducationalElements = value),
              ),
            ],
          ),
          
          const SizedBox(height: ModernDesignSystem.spacing8),
          
          // Moral Lesson Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Moralische Lektion',
                style: ModernDesignSystem.body,
              ),
              Switch(
                value: _includeMoralLesson,
                onChanged: (value) => setState(() => _includeMoralLesson = value),
              ),
            ],
          ),
          
          const SizedBox(height: ModernDesignSystem.spacing16),
          
          // Learning Goals Selection
          Text(
            'Spezifische Lernziele (Optional):',
            style: ModernDesignSystem.subheadline.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: ModernDesignSystem.spacing8),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _learningGoals.map((goal) {
              final isSelected = _selectedLearningGoals.contains(goal);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedLearningGoals.remove(goal);
                    } else {
                      _selectedLearningGoals.add(goal);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: ModernDesignSystem.durationShort,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? ModernDesignSystem.accentBlue.withOpacity(0.1) 
                        : ModernDesignSystem.systemGray6,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected 
                          ? ModernDesignSystem.accentBlue 
                          : ModernDesignSystem.systemGray4,
                      width: isSelected ? 1.5 : 0.5,
                    ),
                  ),
                  child: Text(
                    goal,
                    style: ModernDesignSystem.caption1.copyWith(
                      color: isSelected 
                          ? ModernDesignSystem.accentBlue 
                          : ModernDesignSystem.labelColor,
                      fontWeight: isSelected 
                          ? FontWeight.w600 
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Generate Button
  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: ModernDesignSystem.spacing16),
      child: iOSButton(
        text: _isGenerating ? 'Geschichte wird erstellt...' : 'Geschichte generieren',
        onPressed: _isGenerating ? null : _generateStory,
        isPrimary: true,
        isLoading: _isGenerating,
        icon: _isGenerating ? null : const Icon(Icons.auto_awesome, color: Colors.white),
      ),
    );
  }

  /// Generate Story with all settings
  Future<void> _generateStory() async {
    // Validierung optional
    _formKey.currentState?.validate();
    
    final charactersState = ref.read(charactersProvider);
    final characters = charactersState.valueOrNull ?? [];
    // Fallback: Ersten Charakter wählen, falls keiner gesetzt ist
    final character = characters.isNotEmpty
        ? characters.firstWhere(
            (c) => c.id == _selectedCharacterId,
            orElse: () => characters.first,
          )
        : Character(
            id: 'fallback',
            name: 'Luna die Entdeckerin',
            description: 'Eine neugierige Abenteurerin',
            appearance: '',
            personality: 'Mutig und hilfsbereit',
            traits: CharacterTraits.neutral(),
            isPublic: true,
            createdAt: DateTime.now(),
            adoptionCount: 0,
            readCount: 0,
            lastInteractionAt: DateTime.now(),
            level: 1,
            experienceCount: 0,
          );
    
    setState(() {
      _isGenerating = true;
      _errorMessage = null;
      _generatedStory = null;
    });

    try {
      final result = await _openAIService.generateStory(
        characterName: character.name,
        characterDescription: character.description,
        characterPersonality: character.personality,
        prompt: _promptController.text.trim().isEmpty
            ? 'Ein geheimnisvoller Funke führt zu einem unerwarteten Abenteuer.'
            : _promptController.text.trim(),
        targetAge: _targetAge,
        genre: _selectedGenre,
        length: _selectedLength,
        complexity: _selectedComplexity,
        learningObjectives: _selectedLearningGoals,
        characterMemories: [], // TODO: Load from character
        mood: _selectedMood,
        setting: _settingController.text.isNotEmpty ? _settingController.text : null,
        includeEducationalElements: _includeEducationalElements,
        includeMoralLesson: _includeMoralLesson,
      );

      setState(() {
        _generatedStory = result;
      });

    } catch (e) {
      setState(() {
        _errorMessage = 'Fehler bei der Generierung: $e';
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }
}