// lib/features/characters/presentation/pages/character_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/gradient_card.dart';
import '../providers/characters_provider.dart';
import '../widgets/character_traits_widget.dart';

class CharacterDetailPage extends ConsumerWidget {
  const CharacterDetailPage({
    super.key,
    required this.characterId,
  });

  final String characterId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersState = ref.watch(charactersProvider);

    return charactersState.when(
      data: (characters) {
        final character = characters.where((c) => c.id == characterId).firstOrNull;
        
        if (character == null) {
          return AppScaffold(
            title: 'Charakter nicht gefunden',
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: ModernDesignSystem.secondaryTextColor),
                  const SizedBox(height: 16),
                  Text(
                    'Charakter nicht gefunden',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/characters'),
                    child: const Text('Zurück zu Charakteren'),
                  ),
                ],
              ),
            ),
          );
        }

        return AppScaffold(
          title: character.displayName,
          subtitle: character.description,
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 150),
                    
                    // Character Avatar & Info
                    GradientCard(
                      gradient: ModernDesignSystem.primaryGradient,
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: ModernDesignSystem.orangeGradient,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: ModernDesignSystem.orangeGradient.colors.first.withOpacity(0.3),
                                  blurRadius: 32,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                character.name.isNotEmpty ? character.name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.w700,
                                  color: ModernDesignSystem.whiteTextColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            character.displayName,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: ModernDesignSystem.whiteTextColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            character.description,
                            style: TextStyle(
                              fontSize: 16,
                              color: ModernDesignSystem.whiteTextColor.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem('Level', character.level.toString(), '🎯'),
                              _buildStatItem('Geschichten', character.experienceCount.toString(), '📚'),
                              _buildStatItem('Punkte', character.traits.averageValue.round().toString(), '⭐'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Character Traits
                    CharacterTraitsWidget(
                      traits: character.traits,
                      showLabels: true,
                      compact: false,
                    ),

                    // Character Info
                    GradientCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '📋 Charakterinformationen',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 16),
                          
                          _buildInfoRow('Erstellt am', _formatDate(character.createdAt)),
                          _buildInfoRow('Status', character.isPublic ? 'Öffentlich' : 'Privat'),
                          _buildInfoRow('Aktivität', character.isActive ? 'Aktiv' : 'Inaktiv'),
                          _buildInfoRow('Dominante Eigenschaft', character.traits.dominantTrait),
                          
                          if (character.lastInteractionAt != null)
                            _buildInfoRow('Letzte Interaktion', _formatDate(character.lastInteractionAt!)),
                        ],
                      ),
                    ),

                    // Actions
                    GradientCard(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => context.go('/stories/create'),
                                  icon: const Icon(Icons.auto_stories),
                                  label: const Text('Geschichte erstellen'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ModernDesignSystem.primaryGradient.colors.first,
                                    foregroundColor: ModernDesignSystem.whiteTextColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Charakter bearbeiten - Coming Soon!'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Bearbeiten'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ModernDesignSystem.orangeGradient.colors.first,
                                    foregroundColor: ModernDesignSystem.whiteTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (character.isPublic) ...[
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('In Community teilen - Coming Soon!'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('In Community teilen'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ModernDesignSystem.greenGradient.colors.first,
                                foregroundColor: ModernDesignSystem.whiteTextColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const AppScaffold(
        title: 'Lade...',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AppScaffold(
        title: 'Fehler',
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Fehler: $error'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/characters'),
                child: const Text('Zurück'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: ModernDesignSystem.whiteTextColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: ModernDesignSystem.whiteTextColor.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: ModernDesignSystem.secondaryTextColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: ModernDesignSystem.primaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} Tag(e) her';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} Stunde(n) her';
    } else {
      return '${difference.inMinutes} Minute(n) her';
    }
  }
}
