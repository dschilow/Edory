using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace Edory.Memory.Domain
{
    /// <summary>
    /// Service für die automatische Konsolidierung von Charakter-Erinnerungen
    /// Implementiert das hierarchische Gedächtnissystem: Akut -> Thematisch -> Persönlichkeit
    /// </summary>
    public class MemoryConsolidationService
    {
        public async Task<List<MemoryFragment>> ConsolidateAcuteMemories(
            CharacterMemory characterMemory, 
            TimeSpan acuteMemoryDuration = default)
        {
            if (acuteMemoryDuration == default)
                acuteMemoryDuration = TimeSpan.FromDays(7); // Standard: 7 Tage

            var oldAcuteMemories = characterMemory.GetMemoriesByType(MemoryType.Acute)
                .Where(m => m.Timestamp < DateTime.UtcNow - acuteMemoryDuration)
                .Where(m => m.IsActive)
                .OrderBy(m => m.Timestamp)
                .ToList();

            if (oldAcuteMemories.Count < 3)
                return new List<MemoryFragment>(); // Nicht genug Erinnerungen für Konsolidierung

            var consolidatedMemories = new List<MemoryFragment>();

            // Gruppiere ähnliche Erinnerungen nach Keywords und emotionalem Kontext
            var memoryGroups = GroupSimilarMemories(oldAcuteMemories);

            foreach (var group in memoryGroups)
            {
                if (group.Count >= 2) // Mindestens 2 ähnliche Erinnerungen
                {
                    var consolidatedMemory = CreateThematicMemory(group);
                    consolidatedMemories.Add(consolidatedMemory);

                    // Deaktiviere alte Erinnerungen
                    foreach (var oldMemory in group)
                    {
                        characterMemory.DeactivateMemory(oldMemory.Id);
                    }

                    // Füge konsolidierte Erinnerung hinzu
                    characterMemory.AddMemoryFragment(consolidatedMemory);
                }
            }

            return consolidatedMemories;
        }

        public async Task<List<MemoryFragment>> ConsolidateThematicMemories(
            CharacterMemory characterMemory,
            TimeSpan thematicMemoryDuration = default)
        {
            if (thematicMemoryDuration == default)
                thematicMemoryDuration = TimeSpan.FromDays(30); // Standard: 30 Tage

            var oldThematicMemories = characterMemory.GetMemoriesByType(MemoryType.Thematic)
                .Where(m => m.Timestamp < DateTime.UtcNow - thematicMemoryDuration)
                .Where(m => m.IsActive)
                .Where(m => m.Importance >= MemoryImportance.High)
                .OrderBy(m => m.Timestamp)
                .ToList();

            if (oldThematicMemories.Count < 2)
                return new List<MemoryFragment>();

            var consolidatedMemories = new List<MemoryFragment>();

            // Analysiere Persönlichkeitsmuster
            var personalityPatterns = ExtractPersonalityPatterns(oldThematicMemories);

            foreach (var pattern in personalityPatterns)
            {
                var personalityMemory = CreatePersonalityMemory(pattern);
                consolidatedMemories.Add(personalityMemory);

                // Deaktiviere thematische Erinnerungen
                foreach (var memory in pattern)
                {
                    characterMemory.DeactivateMemory(memory.Id);
                }

                // Füge Persönlichkeits-Erinnerung hinzu
                characterMemory.AddMemoryFragment(personalityMemory);
            }

            return consolidatedMemories;
        }

        private List<List<MemoryFragment>> GroupSimilarMemories(List<MemoryFragment> memories)
        {
            var groups = new List<List<MemoryFragment>>();
            var processedMemories = new HashSet<Guid>();

            foreach (var memory in memories)
            {
                if (processedMemories.Contains(memory.Id))
                    continue;

                var similarGroup = new List<MemoryFragment> { memory };
                processedMemories.Add(memory.Id);

                foreach (var otherMemory in memories)
                {
                    if (processedMemories.Contains(otherMemory.Id))
                        continue;

                    if (AreSimilarMemories(memory, otherMemory))
                    {
                        similarGroup.Add(otherMemory);
                        processedMemories.Add(otherMemory.Id);
                    }
                }

                if (similarGroup.Count >= 2)
                {
                    groups.Add(similarGroup);
                }
            }

            return groups;
        }

        private bool AreSimilarMemories(MemoryFragment memory1, MemoryFragment memory2)
        {
            // Prüfe gemeinsame Tags
            var commonTags = memory1.Tags.Intersect(memory2.Tags, StringComparer.OrdinalIgnoreCase).Count();
            var tagSimilarity = (double)commonTags / Math.Max(memory1.Tags.Length, memory2.Tags.Length);

            // Prüfe emotionalen Kontext
            var emotionalSimilarity = CalculateEmotionalSimilarity(
                memory1.EmotionalContext, 
                memory2.EmotionalContext);

            // Prüfe zeitliche Nähe
            var timeDifference = Math.Abs((memory1.Timestamp - memory2.Timestamp).TotalDays);
            var temporalSimilarity = Math.Max(0, 1 - (timeDifference / 7)); // 7 Tage Window

            // Gewichtete Ähnlichkeitsberechnung
            var overallSimilarity = (tagSimilarity * 0.4) + 
                                  (emotionalSimilarity * 0.4) + 
                                  (temporalSimilarity * 0.2);

            return overallSimilarity > 0.6; // 60% Ähnlichkeitsschwelle
        }

        private double CalculateEmotionalSimilarity(EmotionalContext context1, EmotionalContext context2)
        {
            var differences = new[]
            {
                Math.Abs(context1.Joy - context2.Joy),
                Math.Abs(context1.Sadness - context2.Sadness),
                Math.Abs(context1.Fear - context2.Fear),
                Math.Abs(context1.Anger - context2.Anger),
                Math.Abs(context1.Surprise - context2.Surprise),
                Math.Abs(context1.Pride - context2.Pride),
                Math.Abs(context1.Excitement - context2.Excitement),
                Math.Abs(context1.Calmness - context2.Calmness)
            };

            var avgDifference = differences.Average();
            return Math.Max(0, 1 - (avgDifference / 100.0)); // Normalisiert auf 0-1
        }

        private MemoryFragment CreateThematicMemory(List<MemoryFragment> acuteMemories)
        {
            var combinedContent = string.Join(" ", acuteMemories.Select(m => m.Content));
            var allTags = acuteMemories.SelectMany(m => m.Tags).Distinct().ToArray();
            var avgImportance = (MemoryImportance)acuteMemories.Average(m => (int)m.Importance);
            
            // Kombiniere emotionale Kontexte
            var avgEmotionalContext = CombineEmotionalContexts(
                acuteMemories.Select(m => m.EmotionalContext).ToArray());

            var consolidatedContent = $"Thematische Erinnerung: {combinedContent.Substring(0, Math.Min(450, combinedContent.Length))}";

            return MemoryFragment.CreateThematic(
                consolidatedContent,
                allTags,
                avgImportance,
                avgEmotionalContext);
        }

        private MemoryFragment CreatePersonalityMemory(List<MemoryFragment> thematicMemories)
        {
            var personalityTraits = ExtractPersonalityTraits(thematicMemories);
            var combinedTags = thematicMemories.SelectMany(m => m.Tags).Distinct().ToArray();
            
            var personalityContent = $"Persönlichkeitsmuster: {string.Join(", ", personalityTraits)}";

            var avgEmotionalContext = CombineEmotionalContexts(
                thematicMemories.Select(m => m.EmotionalContext).ToArray());

            return MemoryFragment.CreatePersonality(
                personalityContent,
                combinedTags,
                MemoryImportance.Critical,
                avgEmotionalContext);
        }

        private List<List<MemoryFragment>> ExtractPersonalityPatterns(List<MemoryFragment> thematicMemories)
        {
            // Vereinfachte Implementierung - gruppiere nach dominanten emotionalen Mustern
            var patterns = new List<List<MemoryFragment>>();
            
            var emotionalGroups = thematicMemories
                .GroupBy(m => GetDominantEmotion(m.EmotionalContext))
                .Where(g => g.Count() >= 2)
                .Select(g => g.ToList())
                .ToList();

            patterns.AddRange(emotionalGroups);
            return patterns;
        }

        private string GetDominantEmotion(EmotionalContext context)
        {
            var emotions = new Dictionary<string, int>
            {
                ["Joy"] = context.Joy,
                ["Sadness"] = context.Sadness,
                ["Fear"] = context.Fear,
                ["Anger"] = context.Anger,
                ["Surprise"] = context.Surprise,
                ["Pride"] = context.Pride,
                ["Excitement"] = context.Excitement,
                ["Calmness"] = context.Calmness
            };

            return emotions.OrderByDescending(e => e.Value).First().Key;
        }

        private string[] ExtractPersonalityTraits(List<MemoryFragment> memories)
        {
            var traits = new List<string>();
            
            // Analysiere emotionale Muster
            var avgEmotions = CombineEmotionalContexts(memories.Select(m => m.EmotionalContext).ToArray());
            
            if (avgEmotions.Joy > 70) traits.Add("Optimistisch");
            if (avgEmotions.Sadness > 70) traits.Add("Melancholisch");
            if (avgEmotions.Fear > 70) traits.Add("Vorsichtig");
            if (avgEmotions.Anger > 70) traits.Add("Temperamentvoll");
            if (avgEmotions.Pride > 70) traits.Add("Selbstbewusst");
            if (avgEmotions.Excitement > 70) traits.Add("Enthusiastisch");
            if (avgEmotions.Calmness > 70) traits.Add("Gelassen");

            return traits.ToArray();
        }

        private EmotionalContext CombineEmotionalContexts(EmotionalContext[] contexts)
        {
            if (!contexts.Any())
                return EmotionalContext.Neutral;

            var avgJoy = (int)contexts.Average(c => c.Joy);
            var avgSadness = (int)contexts.Average(c => c.Sadness);
            var avgFear = (int)contexts.Average(c => c.Fear);
            var avgAnger = (int)contexts.Average(c => c.Anger);
            var avgSurprise = (int)contexts.Average(c => c.Surprise);
            var avgPride = (int)contexts.Average(c => c.Pride);
            var avgExcitement = (int)contexts.Average(c => c.Excitement);
            var avgCalmness = (int)contexts.Average(c => c.Calmness);

            return EmotionalContext.Create(
                avgJoy, avgSadness, avgFear, avgAnger,
                avgSurprise, avgPride, avgExcitement, avgCalmness);
        }

        public async Task CleanupOldMemories(CharacterMemory characterMemory)
        {
            var allMemories = characterMemory.GetAllMemories().ToList();
            var memoriesToRemove = new List<MemoryFragment>();

            foreach (var memory in allMemories)
            {
                var shouldRemove = memory.Type switch
                {
                    MemoryType.Acute => memory.Timestamp < DateTime.UtcNow.AddDays(-30) && 
                                       memory.Importance < MemoryImportance.High,
                    MemoryType.Thematic => memory.Timestamp < DateTime.UtcNow.AddDays(-365) && 
                                          memory.Importance < MemoryImportance.Critical,
                    MemoryType.Personality => false, // Nie löschen
                    _ => false
                };

                if (shouldRemove)
                {
                    memoriesToRemove.Add(memory);
                }
            }

            foreach (var memory in memoriesToRemove)
            {
                characterMemory.RemoveMemoryFragment(memory.Id);
            }
        }
    }
}