// Avatales.Widgets.CustomInputWidgets
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:edory_app/core/theme/app_theme.dart';
import 'package:edory_app/core/theme/app_colors.dart';
import 'package:edory_app/core/utils/app_utils.dart';

/// Animiertes Custom TextField mit erweiterten Features
class CustomTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final BorderRadius? borderRadius;
  final bool showCounter;
  final bool animateLabel;

  const CustomTextField({
    Key? key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.contentPadding,
    this.fillColor,
    this.borderRadius,
    this.showCounter = false,
    this.animateLabel = true,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _focusAnimation;
  late Animation<Color?> _colorAnimation;
  
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _initializeAnimations();
    _setupFocusListener();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppTheme.animationMedium,
      vsync: this,
    );

    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.animationCurve,
    ));

    _colorAnimation = ColorTween(
      begin: AppColors.mediumGray,
      end: AppColors.primaryBlue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.animationCurve,
    ));
  }

  void _setupFocusListener() {
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });

      if (_isFocused) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final hadError = _hasError;
    _hasError = widget.errorText != null;
    
    if (_hasError != hadError) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildLabel() {
    if (widget.label == null || !widget.animateLabel) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _focusAnimation,
      builder: (context, child) {
        final hasContent = widget.controller?.text.isNotEmpty ?? false;
        final shouldFloat = _isFocused || hasContent;

        return AnimatedPositioned(
          duration: AppTheme.animationMedium,
          curve: AppTheme.animationCurve,
          left: shouldFloat ? 0 : 16,
          top: shouldFloat ? -8 : 16,
          child: AnimatedDefaultTextStyle(
            duration: AppTheme.animationMedium,
            style: TextStyle(
              fontSize: shouldFloat ? 12 : 16,
              color: _hasError 
                  ? AppColors.error 
                  : (_isFocused ? AppColors.primaryBlue : AppColors.secondaryText),
              fontWeight: shouldFloat ? FontWeight.w500 : FontWeight.w400,
            ),
            child: Container(
              padding: shouldFloat 
                  ? const EdgeInsets.symmetric(horizontal: 4)
                  : EdgeInsets.zero,
              color: shouldFloat ? (widget.fillColor ?? AppColors.white) : null,
              child: Text(widget.label!),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrefixIcon() {
    if (widget.prefixIcon == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(AppTheme.paddingSmall),
          child: Icon(
            widget.prefixIcon,
            color: _hasError 
                ? AppColors.error 
                : (_isFocused ? _colorAnimation.value : AppColors.secondaryText),
            size: 20,
          ),
        );
      },
    );
  }

  Widget _buildSuffixIcon() {
    if (widget.suffixIcon == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: widget.onSuffixTap,
      child: AnimatedBuilder(
        animation: _focusAnimation,
        builder: (context, child) {
          return Container(
            padding: const EdgeInsets.all(AppTheme.paddingSmall),
            child: Transform.scale(
              scale: 1.0 + (_focusAnimation.value * 0.1),
              child: Icon(
                widget.suffixIcon,
                color: _hasError 
                    ? AppColors.error 
                    : (_isFocused ? AppColors.primaryBlue : AppColors.secondaryText),
                size: 20,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHelperText() {
    if (widget.helperText == null && widget.errorText == null && !widget.showCounter) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.only(
        left: AppTheme.paddingMedium,
        right: AppTheme.paddingMedium,
        top: AppTheme.paddingSmall,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.errorText ?? widget.helperText ?? '',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: widget.errorText != null 
                    ? AppColors.error 
                    : AppColors.secondaryText,
              ),
            ),
          ),
          if (widget.showCounter && widget.maxLength != null)
            Text(
              '${widget.controller?.text.length ?? 0}/${widget.maxLength}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            AnimatedBuilder(
              animation: _focusAnimation,
              builder: (context, child) {
                return AnimatedContainer(
                  duration: AppTheme.animationMedium,
                  curve: AppTheme.animationCurve,
                  decoration: BoxDecoration(
                    color: widget.fillColor ?? AppColors.lightGray,
                    borderRadius: widget.borderRadius ?? AppTheme.radiusMedium,
                    border: Border.all(
                      color: _hasError 
                          ? AppColors.error
                          : (_isFocused 
                              ? AppColors.primaryBlue 
                              : Colors.transparent),
                      width: _isFocused ? 2 : 1,
                    ),
                    boxShadow: _isFocused
                        ? [
                            BoxShadow(
                              color: AppColors.primaryBlue.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    obscureText: widget.obscureText,
                    enabled: widget.enabled,
                    readOnly: widget.readOnly,
                    maxLines: widget.maxLines,
                    maxLength: widget.maxLength,
                    inputFormatters: widget.inputFormatters,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    onTap: widget.onTap,
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      hintText: widget.animateLabel ? null : widget.hint,
                      prefixIcon: _buildPrefixIcon(),
                      suffixIcon: _buildSuffixIcon(),
                      contentPadding: widget.contentPadding ?? 
                          const EdgeInsets.all(AppTheme.paddingMedium),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                );
              },
            ),
            if (widget.animateLabel && widget.label != null)
              _buildLabel(),
          ],
        ),
        _buildHelperText(),
      ],
    );
  }
}

/// Password TextField mit Sichtbarkeits-Toggle und Stärke-Anzeige
class PasswordTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool showStrengthIndicator;
  final bool enabled;

  const PasswordTextField({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.validator,
    this.showStrengthIndicator = true,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;
  PasswordStrength _strength = PasswordStrength.empty;

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
    AppUtils.lightHaptic();
  }

  void _onPasswordChanged(String password) {
    setState(() {
      _strength = AppUtils.getPasswordStrength(password);
    });
    widget.onChanged?.call(password);
  }

  Widget _buildStrengthIndicator() {
    if (!widget.showStrengthIndicator) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.only(
        left: AppTheme.paddingMedium,
        right: AppTheme.paddingMedium,
        top: AppTheme.paddingSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: AppTheme.animationMedium,
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: AppColors.lightGray,
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _strength.progress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: _strength.color,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.paddingMedium),
              Text(
                _strength.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _strength.color,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (_strength == PasswordStrength.weak && widget.controller?.text.isNotEmpty == true)
            Padding(
              padding: const EdgeInsets.only(top: AppTheme.paddingSmall / 2),
              child: Text(
                'Verwende mindestens 8 Zeichen mit Groß- und Kleinbuchstaben',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          label: widget.label,
          hint: widget.hint,
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _obscureText,
          enabled: widget.enabled,
          prefixIcon: Icons.lock_outline,
          suffixIcon: _obscureText ? Icons.visibility : Icons.visibility_off,
          onSuffixTap: _toggleVisibility,
          onChanged: _onPasswordChanged,
          validator: widget.validator,
          keyboardType: TextInputType.visiblePassword,
        ),
        _buildStrengthIndicator(),
      ],
    );
  }
}

/// Suchfeld mit erweiterten Features
class SearchTextField extends StatefulWidget {
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final bool enabled;
  final bool showFilterButton;
  final VoidCallback? onFilterTap;

  const SearchTextField({
    Key? key,
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.enabled = true,
    this.showFilterButton = false,
    this.onFilterTap,
  }) : super(key: key);

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late TextEditingController _controller;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _animationController = AnimationController(
      duration: AppTheme.animationMedium,
      vsync: this,
    );
    
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
      
      if (hasText) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
    
    widget.onChanged?.call(_controller.text);
  }

  void _clearText() {
    _controller.clear();
    widget.onClear?.call();
    AppUtils.lightHaptic();
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      controller: _controller,
      hint: widget.hint ?? 'Suchen...',
      enabled: widget.enabled,
      prefixIcon: Icons.search,
      suffixIcon: _hasText ? Icons.clear : (widget.showFilterButton ? Icons.filter_list : null),
      onSuffixTap: _hasText ? _clearText : widget.onFilterTap,
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
      animateLabel: false,
      fillColor: AppColors.white,
      borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
    );
  }
}

/// Multi-Line TextArea für längere Texte
class CustomTextArea extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final bool showCounter;

  const CustomTextArea({
    Key? key,
    this.label,
    this.hint,
    this.controller,
    this.focusNode,
    this.minLines = 3,
    this.maxLines = 6,
    this.maxLength,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.showCounter = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      hint: hint,
      controller: controller,
      focusNode: focusNode,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
      showCounter: showCounter,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      contentPadding: const EdgeInsets.all(AppTheme.paddingMedium),
    );
  }
}

/// Dropdown-ähnliches SelectField
class CustomSelectField extends StatelessWidget {
  final String? label;
  final String? hint;
  final String? value;
  final List<SelectOption> options;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final IconData? prefixIcon;

  const CustomSelectField({
    Key? key,
    this.label,
    this.hint,
    this.value,
    required this.options,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.prefixIcon,
  }) : super(key: key);

  void _showOptions(BuildContext context) {
    AppUtils.lightHaptic();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.borderRadiusLarge),
          ),
        ),
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Text(
                label!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppTheme.paddingLarge),
            ],
            ...options.map((option) {
              return ListTile(
                leading: option.icon != null 
                    ? Icon(option.icon, color: AppColors.primaryBlue)
                    : null,
                title: Text(option.label),
                subtitle: option.subtitle != null 
                    ? Text(option.subtitle!)
                    : null,
                trailing: value == option.value
                    ? const Icon(Icons.check, color: AppColors.primaryBlue)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onChanged?.call(option.value);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = options.firstWhere(
      (option) => option.value == value,
      orElse: () => SelectOption(value: '', label: hint ?? 'Auswählen...'),
    );

    return CustomTextField(
      label: label,
      hint: hint,
      controller: TextEditingController(text: selectedOption.label),
      enabled: enabled,
      readOnly: true,
      prefixIcon: prefixIcon,
      suffixIcon: Icons.arrow_drop_down,
      onTap: enabled ? () => _showOptions(context) : null,
      validator: validator,
    );
  }
}

/// Tag Input Field für mehrere Tags
class TagInputField extends StatefulWidget {
  final String? label;
  final String? hint;
  final List<String> tags;
  final ValueChanged<List<String>>? onChanged;
  final int? maxTags;
  final bool enabled;

  const TagInputField({
    Key? key,
    this.label,
    this.hint,
    required this.tags,
    this.onChanged,
    this.maxTags,
    this.enabled = true,
  }) : super(key: key);

  @override
  State<TagInputField> createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _addTag(String tag) {
    final trimmedTag = tag.trim();
    if (trimmedTag.isNotEmpty && 
        !widget.tags.contains(trimmedTag) &&
        (widget.maxTags == null || widget.tags.length < widget.maxTags!)) {
      
      final newTags = List<String>.from(widget.tags)..add(trimmedTag);
      widget.onChanged?.call(newTags);
      _controller.clear();
      AppUtils.lightHaptic();
    }
  }

  void _removeTag(String tag) {
    final newTags = List<String>.from(widget.tags)..remove(tag);
    widget.onChanged?.call(newTags);
    AppUtils.lightHaptic();
  }

  Widget _buildTag(String tag) {
    return Container(
      margin: const EdgeInsets.only(right: AppTheme.paddingSmall / 2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.paddingMedium,
        vertical: AppTheme.paddingSmall / 2,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.createCustomGradient(
          startColor: AppColors.primaryBlue.withOpacity(0.2),
          endColor: AppColors.primaryMint.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: AppColors.primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: AppTheme.paddingSmall / 2),
          GestureDetector(
            onTap: () => _removeTag(tag),
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
        ],
        
        // Tags Display
        if (widget.tags.isNotEmpty) ...[
          Wrap(
            children: widget.tags.map(_buildTag).toList(),
          ),
          const SizedBox(height: AppTheme.paddingSmall),
        ],
        
        // Input Field
        CustomTextField(
          controller: _controller,
          focusNode: _focusNode,
          hint: widget.hint ?? 'Tag hinzufügen...',
          enabled: widget.enabled && 
                   (widget.maxTags == null || widget.tags.length < widget.maxTags!),
          prefixIcon: Icons.tag,
          suffixIcon: Icons.add,
          onSuffixTap: () => _addTag(_controller.text),
          onSubmitted: _addTag,
          textInputAction: TextInputAction.done,
          animateLabel: false,
        ),
        
        // Counter
        if (widget.maxTags != null)
          Padding(
            padding: const EdgeInsets.only(
              left: AppTheme.paddingMedium,
              top: AppTheme.paddingSmall,
            ),
            child: Text(
              '${widget.tags.length}/${widget.maxTags} Tags',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

// ===== Data Models =====

class SelectOption {
  final String value;
  final String label;
  final String? subtitle;
  final IconData? icon;

  const SelectOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
  });
}