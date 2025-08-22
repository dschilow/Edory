// lib/shared/presentation/pages/error_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/modern_design_system.dart';

/// Error Page für Fehlerbehandlung
class ErrorPage extends StatelessWidget {
  const ErrorPage({
    super.key,
    required this.error,
    required this.message,
    this.showBackButton = true,
  });

  final String error;
  final String message;
  final bool showBackButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fehler'),
        backgroundColor: ModernDesignSystem.backgroundPrimary,
        foregroundColor: ModernDesignSystem.textPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: ModernDesignSystem.errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 60,
                  color: ModernDesignSystem.errorColor,
                ),
              ),
              const SizedBox(height: 32),
              
              // Error Title
              Text(
                error,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: ModernDesignSystem.errorColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Error Message
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: ModernDesignSystem.secondaryTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showBackButton)
                    ElevatedButton.icon(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Zurück'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ModernDesignSystem.accentPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  if (showBackButton) const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/home'),
                    icon: const Icon(Icons.home),
                    label: const Text('Startseite'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ModernDesignSystem.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
