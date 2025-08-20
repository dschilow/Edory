// lib/features/characters/presentation/pages/create_character_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';
import '../../../../core/theme/modern_design_system.dart';
import '../../../../shared/presentation/widgets/app_scaffold.dart';
import '../../../../shared/presentation/widgets/gradient_card.dart';
import '../../domain/entities/character.dart';
import '../../domain/entities/character_traits.dart';
import '../providers/characters_provider.dart';
import '../widgets/character_traits_editor.dart';

class CreateCharacterPage extends ConsumerStatefulWidget {
  const CreateCharacterPage({super.key});

  @override
  ConsumerState<CreateCharacterPage> createState() => _CreateCharacterPageState();
}

class _CreateCharacterPageState extends ConsumerState<CreateCharacterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  CharacterTraits _traits = CharacterTraits.neutral();
  bool _isPublic = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(characterCreationProvider);

    return AppScaffold(
      title: 'Charakter erstellen',
      subtitle: 'Erschaffe deinen eigenen Helden',
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 150),
                  
                  // Basic Information
                  GradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📝 Grundinformationen',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 20),
                        
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Charaktername',
                            hintText: 'z.B. Luna die Entdeckerin',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte geben Sie einen Namen ein';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Beschreibung',
                            hintText: 'Beschreiben Sie den Charakter...',
                            prefixIcon: Icon(Icons.description),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Bitte geben Sie eine Beschreibung ein';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  // Character Traits
                  GradientCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '⚡ Eigenschaften',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _traits = const CharacterTraits(
                                    courage: 60, creativity: 65, helpfulness: 70,
                                    humor: 55, wisdom: 60, curiosity: 65,
                                    empathy: 70, persistence: 60,
                                  );
                                });
                              },
                              child: const Text('Ausbalancieren'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CharacterTraitsEditor(
                          traits: _traits,
                          onTraitsChanged: (newTraits) => setState(() => _traits = newTraits),
                        ),
                      ],
                    ),
                  ),
                  
                  // Settings
                  GradientCard(
                    child: Row(
                      children: [
                        const Icon(Icons.public),
                        const SizedBox(width: 12),
                        const Expanded(child: Text('Öffentlich teilen')),
                        Switch(
                          value: _isPublic,
                          onChanged: (value) => setState(() => _isPublic = value),
                        ),
                      ],
                    ),
                  ),
                  
                  // Create Button
                  Container(
                    margin: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: creationState.isLoading ? null : _createCharacter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ModernDesignSystem.primaryGradient.colors.first,
                        foregroundColor: ModernDesignSystem.whiteTextColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: creationState.isLoading
                          ? const CircularProgressIndicator(color: ModernDesignSystem.whiteTextColor)
                          : const Text('Charakter erstellen'),
                    ),
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _createCharacter() {
    if (!_formKey.currentState!.validate()) return;

    final character = Character(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      appearance: 'Magisches Aussehen',
      personality: 'Freundlich und hilfsbereit',
      traits: _traits,
      isPublic: _isPublic,
      createdAt: DateTime.now(),
      level: 1,
      experienceCount: 0,
    );

    ref.read(characterCreationProvider.notifier).createCharacter(character);
    
    ref.listen(characterCreationProvider, (previous, next) {
      next.whenOrNull(
        data: (createdCharacter) {
          if (createdCharacter != null && previous?.value == null) {
            ref.read(charactersProvider.notifier).addCharacter(createdCharacter);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${createdCharacter.name} wurde erstellt!'),
                backgroundColor: ModernDesignSystem.greenGradient.colors.first,
              ),
            );
            context.go('/characters');
          }
        },
      );
    });
  }
}
