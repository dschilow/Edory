// lib/features/characters/presentation/widgets/avatar_photo_uploader.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/gradient_card.dart';

/// Avatar Photo Uploader Widget für Avatales
/// Ermöglicht das Hochladen von Fotos und deren Stilisierung zu Avataren
class AvatarPhotoUploader extends StatefulWidget {
  const AvatarPhotoUploader({
    super.key,
    required this.uploadedPhoto,
    required this.onPhotoSelected,
    required this.onGeneratePressed,
    required this.isGenerating,
    this.generatedImageUrl,
  });

  final File? uploadedPhoto;
  final ValueChanged<File?> onPhotoSelected;
  final VoidCallback onGeneratePressed;
  final bool isGenerating;
  final String? generatedImageUrl;

  @override
  State<AvatarPhotoUploader> createState() => _AvatarPhotoUploaderState();
}

class _AvatarPhotoUploaderState extends State<AvatarPhotoUploader>
    with TickerProviderStateMixin {
  
  final ImagePicker _picker = ImagePicker();
  late AnimationController _uploadController;
  late AnimationController _processController;

  @override
  void initState() {
    super.initState();
    _uploadController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _processController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    if (widget.isGenerating) {
      _processController.repeat();
    }
  }

  @override
  void didUpdateWidget(AvatarPhotoUploader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGenerating && !oldWidget.isGenerating) {
      _processController.repeat();
    } else if (!widget.isGenerating && oldWidget.isGenerating) {
      _processController.stop();
      _processController.reset();
    }
  }

  @override
  void dispose() {
    _uploadController.dispose();
    _processController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Photo Preview/Upload Area
        _buildPhotoPreview(),
        const SizedBox(height: 24),
        
        // Upload Options
        if (widget.uploadedPhoto == null) _buildUploadOptions(),
        
        // Style Selection
        if (widget.uploadedPhoto != null && !widget.isGenerating) ...[
          _buildStyleSelection(),
          const SizedBox(height: 24),
        ],
        
        // Generate Button
        if (widget.uploadedPhoto != null) _buildGenerateButton(),
        
        // Processing Info
        if (widget.isGenerating) _buildProcessingInfo(),
      ],
    );
  }

  Widget _buildPhotoPreview() {
    return GradientCard(
      child: Column(
        children: [
          Text(
            widget.uploadedPhoto != null 
                ? 'Dein Foto' 
                : 'Foto hochladen',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),
          
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2,
                style: BorderStyle.solid,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: _buildPhotoContent(),
            ),
          ),
          
          if (widget.uploadedPhoto != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _showImageSourceDialog(),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Foto ändern',
                  style: IconButton.styleFrom(
                    backgroundColor: ModernDesignSystem.primaryColor.withOpacity(0.1),
                    foregroundColor: ModernDesignSystem.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () => widget.onPhotoSelected(null),
                  icon: const Icon(Icons.delete),
                  tooltip: 'Foto entfernen',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPhotoContent() {
    if (widget.isGenerating) {
      return _buildProcessingAnimation();
    }
    
    if (widget.generatedImageUrl != null) {
      return _buildGeneratedResult();
    }
    
    if (widget.uploadedPhoto != null) {
      return Image.file(
        widget.uploadedPhoto!,
        fit: BoxFit.cover,
      )
          .animate()
          .scale(duration: 600.ms, curve: Curves.elasticOut)
          .fadeIn();
    }
    
    return _buildUploadPlaceholder();
  }

  Widget _buildUploadPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade100,
            Colors.grey.shade50,
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background pattern
          Positioned.fill(
            child: CustomPaint(
              painter: _DottedPatternPainter(),
            ),
          ),
          
          // Upload icon and text
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ModernDesignSystem.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_a_photo,
                  size: 40,
                  color: ModernDesignSystem.primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Foto hinzufügen',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: ModernDesignSystem.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tippe hier zum Hochladen',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ModernDesignSystem.secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingAnimation() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ModernDesignSystem.primaryColor.withOpacity(0.1),
            ModernDesignSystem.primaryColor.withOpacity(0.05),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Original photo (faded)
          if (widget.uploadedPhoto != null)
            Opacity(
              opacity: 0.3,
              child: Image.file(
                widget.uploadedPhoto!,
                fit: BoxFit.cover,
              ),
            ),
          
          // Processing overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          
          // Animation
          AnimatedBuilder(
            animation: _processController,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Transform.rotate(
                      angle: _processController.value * 2 * 3.14159,
                      child: Icon(
                        Icons.auto_awesome,
                        size: 30,
                        color: ModernDesignSystem.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Wird stilisiert...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGeneratedResult() {
    return Stack(
      children: [
        Image.network(
          widget.generatedImageUrl!,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey.shade200,
            child: const Icon(
              Icons.error,
              size: 40,
              color: Colors.red,
            ),
          ),
        ),
        
        // Success indicator
        Positioned(
          top: 10,
          right: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          ),
        )
            .animate()
            .scale(delay: 600.ms, duration: 400.ms, curve: Curves.elasticOut),
      ],
    )
        .animate()
        .scale(duration: 800.ms, curve: Curves.elasticOut)
        .fadeIn();
  }

  Widget _buildUploadOptions() {
    return GradientCard(
      child: Column(
        children: [
          Text(
            'Foto auswählen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildUploadButton(
                  icon: Icons.photo_library,
                  label: 'Galerie',
                  onPressed: () => _pickImage(ImageSource.gallery),
                  gradient: ModernDesignSystem.primaryGradient,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildUploadButton(
                  icon: Icons.camera_alt,
                  label: 'Kamera',
                  onPressed: () => _pickImage(ImageSource.camera),
                  gradient: ModernDesignSystem.greenGradient,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Info Text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dein Foto wird sicher verarbeitet und automatisch in einen Disney/Anime-Avatar verwandelt.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required LinearGradient gradient,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: gradient.colors.first,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
    );
  }

  Widget _buildStyleSelection() {
    return GradientCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Avatar-Stil wählen',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
            children: [
              _buildStyleOption('Disney', Icons.castle, true),
              _buildStyleOption('Anime', Icons.face_retouching_natural, false),
              _buildStyleOption('Cartoon', Icons.sentiment_very_satisfied, false),
              _buildStyleOption('Realistisch', Icons.person, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStyleOption(String name, IconData icon, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        gradient: isSelected ? ModernDesignSystem.primaryGradient : null,
        color: isSelected ? null : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? Colors.transparent 
              : Colors.grey.shade300,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            // TODO: Handle style selection
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.white : ModernDesignSystem.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    final canGenerate = !widget.isGenerating;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: canGenerate ? widget.onGeneratePressed : null,
        icon: widget.isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(
          widget.isGenerating 
              ? 'Wird verarbeitet...' 
              : widget.generatedImageUrl != null
                  ? 'Erneut stilisieren'
                  : 'Avatar erstellen',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.isGenerating 
              ? Colors.grey.shade400 
              : ModernDesignSystem.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: widget.isGenerating ? 0 : 8,
          shadowColor: ModernDesignSystem.primaryColor.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildProcessingInfo() {
    return GradientCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: ModernDesignSystem.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Verarbeitung läuft',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Text(
            'Dein Foto wird in einen wunderschönen Avatar verwandelt. Das kann einige Sekunden dauern.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ModernDesignSystem.secondaryTextColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          LinearProgressIndicator(
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(ModernDesignSystem.primaryColor),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (image != null) {
        widget.onPhotoSelected(File(image.path));
        _uploadController.forward();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fehler beim Auswählen des Fotos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Foto auswählen',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: _buildUploadButton(
                    icon: Icons.photo_library,
                    label: 'Galerie',
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    gradient: ModernDesignSystem.primaryGradient,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildUploadButton(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onPressed: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    gradient: ModernDesignSystem.greenGradient,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// Custom Painter für Dotted Pattern
class _DottedPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;

    const dotSize = 2.0;
    const spacing = 20.0;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), dotSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}