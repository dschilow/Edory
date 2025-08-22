// lib/features/stories/presentation/widgets/story_generation_result.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Story Reader mit horizontaler 5-Kapitel Navigation
/// Cover → 5 Kapitel mit Bildern und scrollbarem Text
class StoryGenerationResult extends ConsumerStatefulWidget {
  final StoryGenerationResultData story;
  
  const StoryGenerationResult({
    super.key,
    required this.story,
  });

  @override
  ConsumerState<StoryGenerationResult> createState() => _StoryGenerationResultState();
}

class _StoryGenerationResultState extends ConsumerState<StoryGenerationResult>
    with TickerProviderStateMixin {
  
  late PageController _pageController;
  late AnimationController _coverController;
  late AnimationController _readingController;
  
  int _currentPage = 0; // 0 = Cover, 1-5 = Chapters
  bool _isReading = false;
  bool _isGeneratingImages = false;
  List<String?> _chapterImages = [null, null, null, null, null];

  @override
  void initState() {
    super.initState();
    
    _pageController = PageController();
    _coverController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _readingController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _coverController.forward();
    _generateChapterImages();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _coverController.dispose();
    _readingController.dispose();
    super.dispose();
  }

  Future<void> _generateChapterImages() async {
    setState(() => _isGeneratingImages = true);
    
    try {
      // Simuliere Runware API Calls für jedes Kapitel
      for (int i = 0; i < widget.story.chapters.length; i++) {
        final chapter = widget.story.chapters[i];
        
        // Mock delay für Bildgenerierung
        await Future.delayed(Duration(milliseconds: 800 + (i * 200)));
        
        if (mounted) {
          setState(() {
            _chapterImages[i] = 'generated_image_${i + 1}.jpg'; // Mock URL
          });
        }
      }
    } catch (e) {
      debugPrint('Error generating images: $e');
    } finally {
      if (mounted) {
        setState(() => _isGeneratingImages = false);
      }
    }
  }

  void _startReading() {
    setState(() => _isReading = true);
    _readingController.forward();
    
    _pageController.nextPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1324), // dark bg
      body: Stack(
        children: [
          // Main Content
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: 1 + widget.story.chapters.length, // Cover + Chapters
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildCoverPage();
              } else {
                return _buildChapterPage(index - 1);
              }
            },
          ),
          
          // Top App Bar
          if (_isReading) _buildAppBar(),
          
          // Bottom Navigation
          if (_isReading) _buildBottomNavigation(),
          
          // Loading Overlay
          if (_isGeneratingImages) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildCoverPage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0E1324), // dark bg
            const Color(0xFF171C30), // dark surface
            const Color(0xFF0E1324),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Close Button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFFF8FAFC), // textPrimary dark
                      size: 20,
                    ),
                  ),
                ),
              ),
              
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cover Image
                    Container(
                      width: 200,
                      height: 280,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF8D95FF), // primary dark
                            const Color(0xFF9EF0DE), // tertiary dark
                            const Color(0xFFFF9BC4), // accent dark
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF8D95FF).withOpacity(0.22), // cardGlow dark
                            blurRadius: 32,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📖', style: TextStyle(fontSize: 60)),
                            const SizedBox(height: 16),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                widget.story.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(controller: _coverController)
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack)
                      .then()
                      .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
                    
                    const SizedBox(height: 40),
                    
                    // Title
                    Text(
                      widget.story.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFF8FAFC),
                      ),
                      textAlign: TextAlign.center,
                    ).animate(controller: _coverController)
                      .fadeIn(delay: 400.ms, duration: 600.ms)
                      .slideY(begin: 0.3, curve: Curves.easeOutCubic),
                    
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    Text(
                      'Ein magisches Abenteuer mit ${widget.story.characterName}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFCBD5E1), // textSecondary dark
                      ),
                      textAlign: TextAlign.center,
                    ).animate(controller: _coverController)
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideY(begin: 0.3, curve: Curves.easeOutCubic),
                    
                    const SizedBox(height: 48),
                    
                    // Read Button
                    GestureDetector(
                      onTap: _startReading,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8D95FF), Color(0xFF6E77FF)],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8D95FF).withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_stories_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Lesen',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).animate(controller: _coverController)
                      .fadeIn(delay: 800.ms, duration: 600.ms)
                      .scale(begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
                    
                    const SizedBox(height: 24),
                    
                    // Story Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildInfoChip('📖', '${widget.story.chapters.length} Kapitel'),
                        const SizedBox(width: 16),
                        _buildInfoChip('⏱️', '~${widget.story.estimatedReadingTime} Min'),
                      ],
                    ).animate(controller: _coverController)
                      .fadeIn(delay: 1000.ms, duration: 600.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOutCubic),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String emoji, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFFCBD5E1),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterPage(int chapterIndex) {
    final chapter = widget.story.chapters[chapterIndex];
    final chapterImage = _chapterImages[chapterIndex];
    
    return Container(
      color: const Color(0xFF0E1324),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80), // Space for app bar
            
            // Chapter Image (16:9 aspect ratio)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0xFF171C30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: chapterImage != null
                  ? Stack(
                      children: [
                        // Mock generated image with gradient
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF8D95FF).withOpacity(0.3),
                                const Color(0xFF9EF0DE).withOpacity(0.3),
                                const Color(0xFFFF9BC4).withOpacity(0.2),
                              ],
                            ),
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                chapter.imageEmoji ?? '🎨',
                                style: const TextStyle(fontSize: 60),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'KI-generiertes Bild',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ).animate()
                      .fadeIn(duration: 600.ms)
                      .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack)
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: const Color(0xFF8D95FF).withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Bild wird generiert...',
                            style: TextStyle(
                              color: Color(0xFFCBD5E1),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Chapter Content (scrollable text)
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF171C30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF8D95FF).withOpacity(0.1),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Chapter Title
                      Text(
                        chapter.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF8FAFC),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Chapter Text
                      Text(
                        chapter.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6, // leading from JSON
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    ).animate(controller: _readingController)
      .fadeIn(duration: 400.ms)
      .slideX(begin: 0.1, curve: Curves.easeOutCubic);
  }

  Widget _buildAppBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF171C30).withOpacity(0.95),
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFF8D95FF).withOpacity(0.1),
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                // Back Button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Color(0xFFF8FAFC),
                      size: 20,
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Title & Avatar
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.story.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF8FAFC),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'mit ${widget.story.characterName}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Settings
                GestureDetector(
                  onTap: () {
                    // Show reading settings
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.settings_rounded,
                      color: Color(0xFFF8FAFC),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(controller: _readingController)
      .fadeIn(duration: 300.ms)
      .slideY(begin: -1, curve: Curves.easeOutCubic);
  }

  Widget _buildBottomNavigation() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF171C30).withOpacity(0.95),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF8D95FF).withOpacity(0.1),
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Progress Segments (5 segments)
                _buildProgressSegments(),
                
                const SizedBox(height: 16),
                
                // Controls
                Row(
                  children: [
                    // Voice/Speed Controls
                    Row(
                      children: [
                        _buildControlButton(Icons.play_arrow_rounded, () {}),
                        const SizedBox(width: 8),
                        _buildControlButton(Icons.speed_rounded, () {}),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Share/Bookmark
                    Row(
                      children: [
                        _buildControlButton(Icons.bookmark_outline_rounded, () {}),
                        const SizedBox(width: 8),
                        _buildControlButton(Icons.share_rounded, () {}),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(controller: _readingController)
      .fadeIn(duration: 300.ms)
      .slideY(begin: 1, curve: Curves.easeOutCubic);
  }

  Widget _buildProgressSegments() {
    return Row(
      children: List.generate(widget.story.chapters.length, (index) {
        final isActive = index + 1 == _currentPage;
        final isCompleted = index + 1 < _currentPage;
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index + 1,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              );
            },
            child: Container(
              height: 6,
              margin: EdgeInsets.only(right: index < widget.story.chapters.length - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive || isCompleted
                  ? const Color(0xFF8D95FF)
                  : const Color(0xFFCBD5E1).withOpacity(0.3),
                borderRadius: BorderRadius.circular(3),
                boxShadow: isActive ? [
                  BoxShadow(
                    color: const Color(0xFF8D95FF).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ] : null,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFF8FAFC),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: const Color(0xFF171C30),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF8D95FF).withOpacity(0.2),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: const Color(0xFF8D95FF),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Bilder werden generiert...',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF8FAFC),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Deine Geschichte wird mit KI-Bildern illustriert',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFCBD5E1),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms);
  }
}

// Data Classes
class StoryGenerationResultData {
  final String title;
  final String characterName;
  final List<StoryChapter> chapters;
  final int estimatedReadingTime;

  StoryGenerationResultData({
    required this.title,
    required this.characterName,
    required this.chapters,
    required this.estimatedReadingTime,
  });
}

class StoryChapter {
  final String title;
  final String content;
  final String? imagePrompt;
  final String? imageEmoji;

  StoryChapter({
    required this.title,
    required this.content,
    this.imagePrompt,
    this.imageEmoji,
  });
}