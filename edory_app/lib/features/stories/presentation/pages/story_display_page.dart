// lib/features/stories/presentation/pages/story_display_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/gradient_card.dart';
import '../../domain/entities/story.dart';

/// Professionelle Story Display Page für Avatales
/// Zeigt generierte Geschichten mit Navigation, TTS und Kapiteln
class StoryDisplayPage extends ConsumerStatefulWidget {
  const StoryDisplayPage({
    super.key,
    required this.story,
    this.showBackButton = true,
  });

  final Story story;
  final bool showBackButton;

  @override
  ConsumerState<StoryDisplayPage> createState() => _StoryDisplayPageState();
}

class _StoryDisplayPageState extends ConsumerState<StoryDisplayPage>
    with TickerProviderStateMixin {
  
  // Controllers
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  
  // Text-to-Speech
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool _isPaused = false;
  
  // Story State
  List<String> _storyChapters = [];
  int _currentChapter = 0;
  double _readingProgress = 0.0;
  
  // UI State
  bool _showControls = true;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _initializeTTS();
    _parseStoryChapters();
    _startAnimations();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  void _initializeTTS() async {
    await _flutterTts.setLanguage('de-DE');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlaying = false;
        _isPaused = false;
      });
    });
  }

  void _parseStoryChapters() {
    // Split story into chapters/paragraphs for better reading experience
    final content = widget.story.content;
    _storyChapters = content
        .split('\n\n')
        .where((paragraph) => paragraph.trim().isNotEmpty)
        .map((paragraph) => paragraph.trim())
        .toList();
    
    if (_storyChapters.isEmpty) {
      _storyChapters = [content];
    }
  }

  void _startAnimations() {
    _fadeController.forward();
    _scaleController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: widget.story.title,
      subtitle: 'Mit ${widget.story.characterName}',
      showBackButton: widget.showBackButton,
      backgroundColor: _isFullscreen ? Colors.black : null,
      body: _buildStoryContent(),
      floatingActionButton: _buildFloatingControls(),
    );
  }

  Widget _buildStoryContent() {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Story Header
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 150), // AppBar spacing
              _buildStoryHeader()
                  .animate(controller: _fadeController)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3),
            ],
          ),
        ),
        
        // Story Content
        SliverToBoxAdapter(
          child: _buildStoryBody()
              .animate(controller: _scaleController)
              .scale(begin: Offset(0.9, 0.9), duration: 800.ms, curve: Curves.elasticOut)
              .fadeIn(delay: 300.ms),
        ),
        
        // Bottom spacing for FAB
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildStoryHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GradientCard(
        child: Column(
          children: [
            // Story Info
            Row(
              children: [
                // Story Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: ModernDesignSystem.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.auto_stories,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Story Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.story.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Mit ${widget.story.characterName}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ModernDesignSystem.secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildStoryMetadata(),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Reading Progress
            _buildReadingProgress(),
            
            const SizedBox(height: 16),
            
            // Story Stats
            _buildStoryStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryMetadata() {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        _buildMetadataBadge(
          widget.story.genre,
          ModernDesignSystem.primaryColor,
        ),
        _buildMetadataBadge(
          '${widget.story.targetAge}+ Jahre',
          ModernDesignSystem.pastelGreen,
        ),
        _buildMetadataBadge(
          '${widget.story.estimatedReadingTime} Min.',
          ModernDesignSystem.primaryOrange,
        ),
        if (widget.story.isAiGenerated)
          _buildMetadataBadge(
            'KI-Generiert',
            ModernDesignSystem.pastelPurple,
          ),
      ],
    );
  }

  Widget _buildMetadataBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildReadingProgress() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Lesefortschritt',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(_readingProgress * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: ModernDesignSystem.secondaryTextColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: _readingProgress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(ModernDesignSystem.primaryColor),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
      ],
    );
  }

  Widget _buildStoryStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatItem(
            icon: Icons.bookmark_outline,
            label: 'Kapitel',
            value: '${_currentChapter + 1}/${_storyChapters.length}',
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.schedule,
            label: 'Geschrieben',
            value: _formatDate(widget.story.createdAt),
          ),
        ),
        Expanded(
          child: _buildStatItem(
            icon: Icons.favorite_outline,
            label: 'Ziele',
            value: '${widget.story.learningObjectives.length}',
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: ModernDesignSystem.secondaryTextColor,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: ModernDesignSystem.secondaryTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStoryBody() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: GradientCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chapter Navigation
            if (_storyChapters.length > 1) ...[
              _buildChapterNavigation(),
              const SizedBox(height: 20),
            ],
            
            // Story Content
            _buildStoryText(),
            
            const SizedBox(height: 24),
            
            // Learning Objectives
            if (widget.story.learningObjectives.isNotEmpty) ...[
              _buildLearningObjectives(),
              const SizedBox(height: 20),
            ],
            
            // Story Actions
            _buildStoryActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildChapterNavigation() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: _currentChapter > 0 ? _previousChapter : null,
            icon: const Icon(Icons.chevron_left),
            style: IconButton.styleFrom(
              backgroundColor: _currentChapter > 0 
                  ? ModernDesignSystem.primaryColor.withOpacity(0.1)
                  : Colors.grey.shade200,
              foregroundColor: _currentChapter > 0 
                  ? ModernDesignSystem.primaryColor
                  : Colors.grey.shade400,
            ),
          ),
          
          Expanded(
            child: Text(
              'Kapitel ${_currentChapter + 1} von ${_storyChapters.length}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          IconButton(
            onPressed: _currentChapter < _storyChapters.length - 1 ? _nextChapter : null,
            icon: const Icon(Icons.chevron_right),
            style: IconButton.styleFrom(
              backgroundColor: _currentChapter < _storyChapters.length - 1
                  ? ModernDesignSystem.primaryColor.withOpacity(0.1)
                  : Colors.grey.shade200,
              foregroundColor: _currentChapter < _storyChapters.length - 1
                  ? ModernDesignSystem.primaryColor
                  : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryText() {
    final currentText = _storyChapters.isNotEmpty 
        ? _storyChapters[_currentChapter]
        : widget.story.content;
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: Container(
        key: ValueKey(_currentChapter),
        child: SelectableText(
          currentText,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.6,
            fontSize: 16,
            color: ModernDesignSystem.primaryTextColor,
          ),
          textAlign: TextAlign.left,
        ),
      ),
    );
  }

  Widget _buildLearningObjectives() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              size: 20,
              color: ModernDesignSystem.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              'Lernziele',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        ...widget.story.learningObjectives.map((objective) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(top: 8, right: 12),
                decoration: BoxDecoration(
                  color: ModernDesignSystem.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
              Expanded(
                child: Text(
                  objective,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ModernDesignSystem.secondaryTextColor,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildStoryActions() {
    return Row(
      children: [
        // Share Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _shareStory,
            icon: const Icon(Icons.share),
            label: const Text('Teilen'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Save Button
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _saveStory,
            icon: const Icon(Icons.bookmark),
            label: const Text('Speichern'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernDesignSystem.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TTS Control
          IconButton(
            onPressed: _toggleTTS,
            icon: Icon(
              _isPlaying 
                  ? Icons.pause_circle_filled
                  : _isPaused
                      ? Icons.play_circle_filled
                      : Icons.play_circle_outline,
            ),
            style: IconButton.styleFrom(
              backgroundColor: ModernDesignSystem.primaryColor.withOpacity(0.1),
              foregroundColor: ModernDesignSystem.primaryColor,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Font Size
          IconButton(
            onPressed: _adjustFontSize,
            icon: const Icon(Icons.format_size),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Colors.grey.shade700,
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Fullscreen
          IconButton(
            onPressed: _toggleFullscreen,
            icon: Icon(
              _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  // Action Methods
  void _handleBackPress() {
    if (widget.showBackButton) {
      // Graceful navigation back
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/stories');
      }
    }
  }

  void _previousChapter() {
    if (_currentChapter > 0) {
      setState(() => _currentChapter--);
      _updateReadingProgress();
    }
  }

  void _nextChapter() {
    if (_currentChapter < _storyChapters.length - 1) {
      setState(() => _currentChapter++);
      _updateReadingProgress();
    }
  }

  void _updateReadingProgress() {
    setState(() {
      _readingProgress = (_currentChapter + 1) / _storyChapters.length;
    });
  }

  Future<void> _toggleTTS() async {
    if (_isPlaying) {
      await _flutterTts.pause();
      setState(() {
        _isPlaying = false;
        _isPaused = true;
      });
    } else if (_isPaused) {
      await _flutterTts.speak(_storyChapters[_currentChapter]);
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    } else {
      await _flutterTts.speak(_storyChapters[_currentChapter]);
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });
    }
  }

  void _adjustFontSize() {
    // TODO: Implement font size adjustment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Schriftgröße-Anpassung wird implementiert...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
  }

  void _shareStory() {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Geschichte wird geteilt...'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _saveStory() {
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Geschichte gespeichert!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}.${date.month}.${date.year}';
  }
}