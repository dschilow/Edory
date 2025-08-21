// Avatales.Services.NotificationService
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/theme/app_colors.dart';
import 'package:edory_app/shared/presentation/widgets/custom_button.dart';
import 'package:edory_app/core/utils/app_utils.dart';

/// Service für Benachrichtigungen, Dialoge und Overlays
class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();
  NotificationService._();

  BuildContext? _context;
  OverlayEntry? _currentOverlay;

  /// Setzt den aktuellen Build Context
  void setContext(BuildContext context) {
    _context = context;
  }

  // ===== SnackBar Notifications =====

  /// Zeigt eine Erfolgs-Benachrichtigung
  void showSuccess(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      type: NotificationType.success,
      duration: duration,
    );
  }

  /// Zeigt eine Fehler-Benachrichtigung
  void showError(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      type: NotificationType.error,
      duration: duration,
    );
  }

  /// Zeigt eine Warn-Benachrichtigung
  void showWarning(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      type: NotificationType.warning,
      duration: duration,
    );
  }

  /// Zeigt eine Info-Benachrichtigung
  void showInfo(String message, {Duration? duration}) {
    _showSnackBar(
      message: message,
      type: NotificationType.info,
      duration: duration,
    );
  }

  /// Zeigt eine Custom SnackBar
  void _showSnackBar({
    required String message,
    required NotificationType type,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    if (_context == null) return;

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            _getIconForType(type),
            color: AppColors.white,
            size: 20,
          ),
          const SizedBox(width: AppTheme.paddingMedium),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getColorForType(type),
      duration: duration ?? const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      margin: const EdgeInsets.all(AppTheme.paddingMedium),
      action: actionLabel != null && onAction != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: AppColors.white,
              onPressed: onAction,
            )
          : null,
    );

    ScaffoldMessenger.of(_context!).showSnackBar(snackBar);
    
    // Haptic Feedback
    switch (type) {
      case NotificationType.success:
        AppUtils.lightHaptic();
        break;
      case NotificationType.error:
        AppUtils.heavyHaptic();
        break;
      case NotificationType.warning:
        AppUtils.mediumHaptic();
        break;
      case NotificationType.info:
        AppUtils.lightHaptic();
        break;
    }
  }

  // ===== Toast Notifications =====

  /// Zeigt eine Toast-Benachrichtigung
  void showToast(
    String message, {
    NotificationType type = NotificationType.info,
    Duration duration = const Duration(seconds: 3),
    ToastPosition position = ToastPosition.bottom,
  }) {
    if (_context == null) return;

    _removeCurrentOverlay();

    _currentOverlay = OverlayEntry(
      builder: (context) => ToastWidget(
        message: message,
        type: type,
        duration: duration,
        position: position,
        onDismiss: _removeCurrentOverlay,
      ),
    );

    Overlay.of(_context!)!.insert(_currentOverlay!);
  }

  /// Entfernt das aktuelle Overlay
  void _removeCurrentOverlay() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  // ===== Dialog System =====

  /// Zeigt einen Bestätigungs-Dialog
  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Bestätigen',
    String cancelText = 'Abbrechen',
    bool isDangerous = false,
  }) async {
    if (_context == null) return false;

    final result = await showDialog<bool>(
      context: _context!,
      builder: (context) => CustomAlertDialog(
        title: title,
        content: message,
        actions: [
          CustomButton(
            text: cancelText,
            type: ButtonType.ghost,
            onPressed: () => Navigator.of(context).pop(false),
          ),
          CustomButton(
            text: confirmText,
            type: isDangerous ? ButtonType.primary : ButtonType.primary,
            backgroundColor: isDangerous ? AppColors.error : null,
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Zeigt einen Info-Dialog
  Future<void> showInfoDialog({
    required String title,
    required String message,
    String buttonText = 'OK',
    Widget? customContent,
  }) async {
    if (_context == null) return;

    await showDialog(
      context: _context!,
      builder: (context) => CustomAlertDialog(
        title: title,
        content: customContent != null ? null : message,
        customContent: customContent,
        actions: [
          CustomButton(
            text: buttonText,
            type: ButtonType.primary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  /// Zeigt einen Input-Dialog
  Future<String?> showInputDialog({
    required String title,
    String? message,
    String? initialValue,
    String? hintText,
    String confirmText = 'OK',
    String cancelText = 'Abbrechen',
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) async {
    if (_context == null) return null;

    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: _context!,
      builder: (context) => CustomAlertDialog(
        title: title,
        content: message,
        customContent: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message != null) ...[
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.paddingMedium),
              ],
              TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: hintText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  ),
                ),
                keyboardType: keyboardType,
                maxLength: maxLength,
                validator: validator,
                autofocus: true,
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            text: cancelText,
            type: ButtonType.ghost,
            onPressed: () => Navigator.of(context).pop(),
          ),
          CustomButton(
            text: confirmText,
            type: ButtonType.primary,
            onPressed: () {
              if (formKey.currentState?.validate() ?? true) {
                Navigator.of(context).pop(controller.text);
              }
            },
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }

  /// Zeigt einen Loading-Dialog
  void showLoadingDialog({
    String? message,
    bool barrierDismissible = false,
  }) {
    if (_context == null) return;

    showDialog(
      context: _context!,
      barrierDismissible: barrierDismissible,
      builder: (context) => WillPopScope(
        onWillPop: () async => barrierDismissible,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              boxShadow: AppTheme.mediumShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: AppTheme.paddingMedium),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Schließt den Loading-Dialog
  void hideLoadingDialog() {
    if (_context != null) {
      Navigator.of(_context!).pop();
    }
  }

  /// Zeigt ein Bottom Sheet
  Future<T?> showBottomSheet<T>({
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    double? height,
  }) async {
    if (_context == null) return null;

    return await showModalBottomSheet<T>(
      context: _context!,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      builder: (context) => Container(
        height: height,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.borderRadiusLarge),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: AppTheme.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.mediumGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }

  // ===== Helper Methods =====

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.info:
        return AppColors.info;
    }
  }
}

// ===== Custom Widgets =====

/// Custom Alert Dialog mit Animationen
class CustomAlertDialog extends StatefulWidget {
  final String title;
  final String? content;
  final Widget? customContent;
  final List<Widget> actions;

  const CustomAlertDialog({
    Key? key,
    required this.title,
    this.content,
    this.customContent,
    required this.actions,
  }) : super(key: key);

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.animationMedium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: AppTheme.elasticOutCurve),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
              ),
              title: Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: widget.customContent ??
                  (widget.content != null
                      ? Text(
                          widget.content!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      : null),
              actions: widget.actions,
              actionsPadding: const EdgeInsets.all(AppTheme.paddingMedium),
            ),
          ),
        );
      },
    );
  }
}

/// Toast Widget für Overlay-Benachrichtigungen
class ToastWidget extends StatefulWidget {
  final String message;
  final NotificationType type;
  final Duration duration;
  final ToastPosition position;
  final VoidCallback onDismiss;

  const ToastWidget({
    Key? key,
    required this.message,
    required this.type,
    required this.duration,
    required this.position,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppTheme.animationMedium,
      vsync: this,
    );

    final begin = widget.position == ToastPosition.top
        ? const Offset(0, -1)
        : const Offset(0, 1);

    _slideAnimation = Tween<Offset>(
      begin: begin,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppTheme.elasticOutCurve,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();

    // Auto dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) => widget.onDismiss());
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getBackgroundColor() {
    switch (widget.type) {
      case NotificationType.success:
        return AppColors.success;
      case NotificationType.error:
        return AppColors.error;
      case NotificationType.warning:
        return AppColors.warning;
      case NotificationType.info:
        return AppColors.info;
    }
  }

  IconData _getIcon() {
    switch (widget.type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.position == ToastPosition.top ? 50 : null,
      bottom: widget.position == ToastPosition.bottom ? 100 : null,
      left: AppTheme.paddingMedium,
      right: AppTheme.paddingMedium,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.paddingMedium),
                  decoration: BoxDecoration(
                    color: _getBackgroundColor(),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    boxShadow: AppTheme.mediumShadow,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getIcon(),
                        color: AppColors.white,
                        size: 24,
                      ),
                      const SizedBox(width: AppTheme.paddingMedium),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          _controller.reverse().then((_) => widget.onDismiss());
                        },
                        child: const Icon(
                          Icons.close,
                          color: AppColors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===== Enums =====

enum NotificationType { success, error, warning, info }

enum ToastPosition { top, bottom }