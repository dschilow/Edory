// lib/features/stories/presentation/pages/story_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';

class StoryDetailPage extends ConsumerStatefulWidget {
  const StoryDetailPage({
    super.key,
    required this.storyId,
  });

  final String storyId;

  @override
  ConsumerState<StoryDetailPage> createState() => _StoryDetailPageState();
}

class _StoryDetailPageState extends ConsumerState<StoryDetailPage>
    with TickerProviderStateMixin {
  
  late PageController _pageController;
  late AnimationController _navController;
  late AnimationController _progressController;
  
  int _currentPage = 0;
  bool _isAutoPlay = false;
  double _readingSpeed = 1.0;
  bool _isBookmarked = false;
  
  // Mock story data - würde normalerweise von Provider kommen
  late Map<String, dynamic> _story;

  @override
  void initState() {
    super.initState();
    
    _pageController = PageController();
    _navController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _story = _getMockStory();
    
    _navController.forward();
    _progressController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _navController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _getMockStory() {
    return {
      'id': widget.storyId,
      'title': 'Die Wolkenbahn',
      'avatar': 'Luna',
      'chapters': [
        {
          'title': 'Der geheimnisvolle Bahnhof',
          'content': '''Luna stand vor dem alten Bahnhof und konnte ihren Augen kaum trauen. Weiße, flauschige Wolken schwebten anstelle von Zügen auf den Gleisen. Ein freundlicher Schaffner mit einem Hut aus Regenbogenfarben winkte ihr zu.

"Willkommen zur Wolkenbahn, kleine Luna! Bereit für das Abenteuer deines Lebens?"

Luna nickte aufgeregt. Sie hatte schon so lange von diesem magischen Ort geträumt. Endlich war es soweit - ihre erste Reise durch das Wolkenland konnte beginnen.

Der Schaffner führte sie zu einer besonders weichen, silbernen Wolke. "Das wird dein Waggon sein. Halt dich gut fest, denn gleich geht es hoch hinaus!"''',
          'imageUrl': 'chapter1.jpg',
          'emoji': '🚂',
        },
        {
          'title': 'Durch die Wolken',
          'content': '''Die Wolke begann sich zu bewegen und hob langsam vom Boden ab. Luna spürte, wie ihr Magen kribbelte vor Aufregung. Um sie herum zogen andere Wolkenzüge vorbei, in denen Kinder aus der ganzen Welt saßen und winkten.

"Siehst du das große Schloss dort drüben?", rief der Schaffner und zeigte auf eine goldene Burg, die auf einer riesigen Wolke thronte. "Das ist das Traumschloss der Königin der Lüfte!"

Luna staunte über die wunderschöne Aussicht. Unter ihr konnte sie ihre Heimatstadt sehen, die so klein aussah wie ein Spielzeugdorf. Die Wolkenbahn fuhr zwischen Regenbogen hindurch und über glitzernde Seen aus Sternenstaub.''',
          'imageUrl': 'chapter2.jpg',
          'emoji': '☁️',
        },
        {
          'title': 'Das Wolkenland',
          'content': '''Der Zug hielt an einer Station, die komplett aus Zuckerwatte zu bestehen schien. Luna sprang von ihrer Wolke und landete weich auf dem flauschigen Boden. Überall um sie herum spielten andere Kinder mit fliegenden Drachen und tanzenden Lichtern.

Ein kleiner Junge mit Flügeln kam auf sie zu. "Hallo! Ich bin Nimbus. Möchtest du mit mir die Regenfabrik besuchen? Dort wird der Regen für die ganze Welt gemacht!"

Luna war begeistert. Hand in Hand liefen sie durch Gärten aus Wolkenblumen, vorbei an Brunnen, die Sternenschnuppen sprudelten. Das Wolkenland war noch viel schöner, als sie es sich je vorgestellt hatte.''',
          'imageUrl': 'chapter3.jpg',
          'emoji': '🌈',
        },
        {
          'title': 'Die Regenfabrik',
          'content': '''In der Regenfabrik war ein geschäftiges Treiben. Kleine Wolkenwesen sammelten Wassertropfen in glitzernden Eimern und füllten sie in große, silberne Maschinen. Ein alter Wolkenmeister mit einem langen, weißen Bart erklärte Luna den Vorgang.

"Jeder Tropfen wird mit guten Wünschen gefüllt", sagte er lächelnd. "Der Regen, der auf die Erde fällt, bringt den Pflanzen und Tieren Freude und lässt alles wachsen und gedeihen."

Luna durfte sogar dabei helfen, die Tropfen zu verzaubern. Sie konzentrierte sich ganz fest und wünschte sich, dass der Regen ihrem Garten zu Hause helfen würde zu blühen. Der Wolkenmeister nickte anerkennend. "Du hast ein gutes Herz, kleine Luna."''',
          'imageUrl': 'chapter4.jpg',
          'emoji': '💧',
        },
        {
          'title': 'Die Rückkehr',
          'content': '''Als die Sonne langsam unterging und das Wolkenland in goldenes Licht tauchte, war es Zeit für Luna zurückzukehren. Der Schaffner wartete bereits mit ihrer silbernen Wolke am Bahnhof.

"Du warst eine wunderbare Reisende", sagte er und gab ihr einen kleinen Anhänger in Form einer Wolke. "Damit kannst du jederzeit zurückkehren, wenn du möchtest."

Luna umarmte Nimbus zum Abschied und stieg in ihre Wolke. Während sie langsam zur Erde hinabschwebte, winkte sie allen Bewohnern des Wolkenlandes zu. In ihrem Herzen wusste sie, dass dies nicht ihre letzte Reise mit der Wolkenbahn gewesen war.

Zu Hause angekommen, schaute sie zum Himmel hinauf und lächelte. Jedes Mal, wenn sie nun Wolken sah, würde sie an ihr wunderbares Abenteuer denken.''',
          'imageUrl': 'chapter5.jpg',
          'emoji': '🏠',
        },
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E1324), // dark bg
      body: Stack(
        children: [
          // Main Content - PageView für 5 Kapitel
          PageView.builder(
            controller: _pageController,
            onPageChanged: (page) => setState(() => _currentPage = page),
            itemCount: _story['chapters'].length,
            itemBuilder: (context, index) => _buildChapterPage(index),
          ),
          
          // Top App Bar
          _buildTopAppBar(),
          
          // Bottom Navigation
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildChapterPage(int chapterIndex) {
    final chapter = _story['chapters'][chapterIndex];
    
    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 80), // Space for app bar
          
          // Chapter Image (16:9 aspect wie im JSON)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), // lg corner
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
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getChapterGradient(chapterIndex),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        chapter['emoji'],
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Kapitel ${chapterIndex + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ).animate()
            .fadeIn(duration: 600.ms)
            .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
          
          const SizedBox(height: 24),
          
          // Chapter Content (maxWidth 720 wie im JSON)
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 720),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF171C30), // dark surface
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF8D95FF).withOpacity(0.1),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: SingleChildScrollView( // vertical scroll wie im JSON
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chapter Title
                    Text(
                      chapter['title'],
                      style: const TextStyle(
                        fontSize: 24, // title size
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF8FAFC), // textPrimary dark
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Chapter Text
                    Text(
                      chapter['content'],
                      style: const TextStyle(
                        fontSize: 16, // body size
                        height: 1.6, // leading 1.4 -> 1.6 für bessere Lesbarkeit
                        color: Color(0xFFCBD5E1), // textSecondary dark
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Navigation Hints
                    if (chapterIndex < _story['chapters'].length - 1)
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8D95FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF8D95FF).withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Wische für nächstes Kapitel',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF8D95FF),
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_rounded,
                                size: 16,
                                color: Color(0xFF8D95FF),
                              ),
                            ],
                          ),
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
    ).animate()
      .fadeIn(duration: 400.ms)
      .slideX(begin: 0.1, curve: Curves.easeOutCubic);
  }

  List<Color> _getChapterGradient(int index) {
    final gradients = [
      [const Color(0xFF8D95FF).withOpacity(0.4), const Color(0xFF9EF0DE).withOpacity(0.4)],
      [const Color(0xFF9EF0DE).withOpacity(0.4), const Color(0xFFFF9BC4).withOpacity(0.4)],
      [const Color(0xFFFF9BC4).withOpacity(0.4), const Color(0xFFFFD489).withOpacity(0.4)],
      [const Color(0xFFFFD489).withOpacity(0.4), const Color(0xFF9E8CFF).withOpacity(0.4)],
      [const Color(0xFF9E8CFF).withOpacity(0.4), const Color(0xFF8D95FF).withOpacity(0.4)],
    ];
    return gradients[index % gradients.length];
  }

  Widget _buildTopAppBar() {
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
                
                // Title & Avatar Info (wie im JSON)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _story['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF8FAFC),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'mit ${_story['avatar']}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Bookmark
                GestureDetector(
                  onTap: () => setState(() => _isBookmarked = !_isBookmarked),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _isBookmarked 
                        ? Icons.bookmark_rounded 
                        : Icons.bookmark_outline_rounded,
                      color: _isBookmarked 
                        ? const Color(0xFFFFD489) 
                        : const Color(0xFFF8FAFC),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(controller: _navController)
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
                // Progress Segments (5 segments wie im JSON)
                _buildProgressSegments(),
                
                const SizedBox(height: 16),
                
                // Controls
                Row(
                  children: [
                    // Left Controls (vorlesen, geschwindigkeit)
                    Row(
                      children: [
                        _buildControlButton(
                          icon: _isAutoPlay 
                            ? Icons.pause_rounded 
                            : Icons.play_arrow_rounded,
                          onTap: () => setState(() => _isAutoPlay = !_isAutoPlay),
                        ),
                        const SizedBox(width: 8),
                        _buildControlButton(
                          icon: Icons.speed_rounded,
                          onTap: _showSpeedSelector,
                        ),
                      ],
                    ),
                    
                    const Spacer(),
                    
                    // Right Controls (teilen, merken)
                    Row(
                      children: [
                        _buildControlButton(
                          icon: Icons.share_rounded,
                          onTap: _shareStory,
                        ),
                        const SizedBox(width: 8),
                        _buildControlButton(
                          icon: _isBookmarked 
                            ? Icons.bookmark_rounded 
                            : Icons.bookmark_outline_rounded,
                          onTap: () => setState(() => _isBookmarked = !_isBookmarked),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(controller: _navController)
      .fadeIn(duration: 300.ms)
      .slideY(begin: 1, curve: Curves.easeOutCubic);
  }

  Widget _buildProgressSegments() {
    return Row(
      children: List.generate(_story['chapters'].length, (index) {
        final isActive = index == _currentPage;
        final isCompleted = index < _currentPage;
        
        return Expanded(
          child: GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
              );
            },
            child: Container(
              height: 6,
              margin: EdgeInsets.only(
                right: index < _story['chapters'].length - 1 ? 8 : 0,
              ),
              decoration: BoxDecoration(
                color: isActive || isCompleted
                  ? const Color(0xFF8D95FF) // primary color
                  : const Color(0xFFCBD5E1).withOpacity(0.3), // inactive
                borderRadius: BorderRadius.circular(3), // rounded shape
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
    ).animate(controller: _progressController)
      .fadeIn(duration: 600.ms)
      .scaleX(begin: 0.8, curve: Curves.easeOutBack);
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
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

  void _showSpeedSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF171C30),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Lesegeschwindigkeit',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFF8FAFC),
              ),
            ),
            const SizedBox(height: 20),
            
            Slider(
              value: _readingSpeed,
              min: 0.5,
              max: 2.0,
              divisions: 3,
              label: '${_readingSpeed}x',
              activeColor: const Color(0xFF8D95FF),
              onChanged: (value) => setState(() => _readingSpeed = value),
            ),
            
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0.5x', style: TextStyle(color: Color(0xFFCBD5E1))),
                Text('2.0x', style: TextStyle(color: Color(0xFFCBD5E1))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareStory() {
    // Share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Geschichte wird geteilt...'),
        backgroundColor: Color(0xFF8EE2D2),
      ),
    );
  }
}