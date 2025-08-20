-- Edory Database Schema
-- Complete database schema for all features including Memory System

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Familien/Nutzer
CREATE TABLE Families (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(255) UNIQUE NOT NULL,
    CreatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    SubscriptionLevel VARCHAR(20) DEFAULT 'Free',
    IsActive BOOLEAN DEFAULT true,
    Settings JSONB DEFAULT '{}'
);

-- Charakter DNA (Basis-Template)
CREATE TABLE CharacterDnas (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    Name VARCHAR(100) NOT NULL,
    Description TEXT NOT NULL,
    Appearance TEXT NOT NULL,
    Personality TEXT NOT NULL,
    BaseCourage INTEGER DEFAULT 50 CHECK (BaseCourage BETWEEN 0 AND 100),
    BaseCreativity INTEGER DEFAULT 50 CHECK (BaseCreativity BETWEEN 0 AND 100),
    BaseHelpfulness INTEGER DEFAULT 50 CHECK (BaseHelpfulness BETWEEN 0 AND 100),
    BaseHumor INTEGER DEFAULT 50 CHECK (BaseHumor BETWEEN 0 AND 100),
    BaseWisdom INTEGER DEFAULT 50 CHECK (BaseWisdom BETWEEN 0 AND 100),
    BaseCuriosity INTEGER DEFAULT 50 CHECK (BaseCuriosity BETWEEN 0 AND 100),
    BaseEmpathy INTEGER DEFAULT 50 CHECK (BaseEmpathy BETWEEN 0 AND 100),
    BasePersistence INTEGER DEFAULT 50 CHECK (BasePersistence BETWEEN 0 AND 100),
    CreatorFamilyId UUID REFERENCES Families(Id),
    IsPublic BOOLEAN DEFAULT false,
    AdoptionCount INTEGER DEFAULT 0,
    CreatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Charakter-Instanzen (pro Familie)
CREATE TABLE CharacterInstances (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    CharacterDnaId UUID REFERENCES CharacterDnas(Id),
    FamilyId UUID REFERENCES Families(Id),
    CustomName VARCHAR(100),
    CurrentCourage INTEGER DEFAULT 50 CHECK (CurrentCourage BETWEEN 0 AND 100),
    CurrentCreativity INTEGER DEFAULT 50 CHECK (CurrentCreativity BETWEEN 0 AND 100),
    CurrentHelpfulness INTEGER DEFAULT 50 CHECK (CurrentHelpfulness BETWEEN 0 AND 100),
    CurrentHumor INTEGER DEFAULT 50 CHECK (CurrentHumor BETWEEN 0 AND 100),
    CurrentWisdom INTEGER DEFAULT 50 CHECK (CurrentWisdom BETWEEN 0 AND 100),
    CurrentCuriosity INTEGER DEFAULT 50 CHECK (CurrentCuriosity BETWEEN 0 AND 100),
    CurrentEmpathy INTEGER DEFAULT 50 CHECK (CurrentEmpathy BETWEEN 0 AND 100),
    CurrentPersistence INTEGER DEFAULT 50 CHECK (CurrentPersistence BETWEEN 0 AND 100),
    Level INTEGER DEFAULT 1,
    ExperienceCount INTEGER DEFAULT 0,
    LastInteractionAt TIMESTAMP WITH TIME ZONE,
    CreatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    IsActive BOOLEAN DEFAULT true
);

-- Charakter-Gedächtnis (Memory System) - HIERARCHISCHES SYSTEM
CREATE TABLE CharacterMemories (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    CharacterInstanceId UUID REFERENCES CharacterInstances(Id),
    MemoryType VARCHAR(20) CHECK (MemoryType IN ('Acute', 'Thematic', 'Personality')),
    Content TEXT NOT NULL,
    EmotionalContext VARCHAR(20) CHECK (EmotionalContext IN ('Joy', 'Sadness', 'Fear', 'Anger', 'Surprise', 'Neutral')),
    Importance INTEGER CHECK (Importance BETWEEN 1 AND 10),
    StoryId UUID, -- Reference to associated story
    Keywords TEXT[],
    ConsolidatedFrom UUID[], -- IDs of memories this was consolidated from
    CreatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ConsolidatedAt TIMESTAMP WITH TIME ZONE,
    LastAccessedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    AccessCount INTEGER DEFAULT 1,
    IsActive BOOLEAN DEFAULT true
);

-- Geschichten
CREATE TABLE Stories (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    Title VARCHAR(200) NOT NULL,
    Content TEXT NOT NULL,
    CharacterInstanceId UUID REFERENCES CharacterInstances(Id),
    FamilyId UUID REFERENCES Families(Id),
    Genre VARCHAR(50) NOT NULL,
    TargetAge INTEGER NOT NULL CHECK (TargetAge BETWEEN 2 AND 18),
    Length VARCHAR(20) NOT NULL CHECK (Length IN ('Kurz', 'Mittel', 'Lang')),
    LearningObjectives TEXT[],
    Prompt TEXT,
    IsGenerated BOOLEAN DEFAULT true,
    GeneratedBy VARCHAR(50) DEFAULT 'OpenAI',
    CreatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ReadCount INTEGER DEFAULT 0,
    LikeCount INTEGER DEFAULT 0,
    IsPublic BOOLEAN DEFAULT false,
    WordCount INTEGER DEFAULT 0
);

-- Lernziele
CREATE TABLE LearningObjectives (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    Category VARCHAR(50) NOT NULL,
    TargetAgeMin INTEGER NOT NULL CHECK (TargetAgeMin BETWEEN 2 AND 18),
    TargetAgeMax INTEGER NOT NULL CHECK (TargetAgeMax BETWEEN 2 AND 18),
    Keywords TEXT[],
    SuccessCriteria TEXT[],
    Priority INTEGER DEFAULT 5 CHECK (Priority BETWEEN 1 AND 10),
    IsActive BOOLEAN DEFAULT true,
    CreatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Charakter-Interaktionen (für Experience/Trait Updates)
CREATE TABLE CharacterInteractions (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    CharacterInstanceId UUID REFERENCES CharacterInstances(Id),
    StoryId UUID REFERENCES Stories(Id),
    InteractionType VARCHAR(50) NOT NULL,
    TraitChanges JSONB, -- JSON object with trait changes
    MemoryFragments TEXT[],
    ExperienceGained INTEGER DEFAULT 0,
    Timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Story-Bewertungen
CREATE TABLE StoryRatings (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    StoryId UUID REFERENCES Stories(Id),
    FamilyId UUID REFERENCES Families(Id),
    Rating INTEGER CHECK (Rating BETWEEN 1 AND 5),
    Comment TEXT,
    CreatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(StoryId, FamilyId)
);

-- Lernfortschritt
CREATE TABLE LearningProgress (
    Id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    FamilyId UUID REFERENCES Families(Id),
    CharacterInstanceId UUID REFERENCES CharacterInstances(Id),
    LearningObjectiveId UUID REFERENCES LearningObjectives(Id),
    Progress INTEGER DEFAULT 0 CHECK (Progress BETWEEN 0 AND 100),
    CompletedAt TIMESTAMP WITH TIME ZONE,
    CreatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UpdatedAt TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indizes für Performance
CREATE INDEX idx_character_instances_family ON CharacterInstances(FamilyId);
CREATE INDEX idx_character_instances_dna ON CharacterInstances(CharacterDnaId);
CREATE INDEX idx_character_memories_instance ON CharacterMemories(CharacterInstanceId);
CREATE INDEX idx_character_memories_type ON CharacterMemories(MemoryType);
CREATE INDEX idx_character_memories_importance ON CharacterMemories(Importance);
CREATE INDEX idx_stories_family ON Stories(FamilyId);
CREATE INDEX idx_stories_character ON Stories(CharacterInstanceId);
CREATE INDEX idx_stories_created ON Stories(CreatedAt);
CREATE INDEX idx_character_interactions_instance ON CharacterInteractions(CharacterInstanceId);
CREATE INDEX idx_character_interactions_story ON CharacterInteractions(StoryId);
CREATE INDEX idx_learning_progress_family ON LearningProgress(FamilyId);

-- Funktionen für automatische Updates
CREATE OR REPLACE FUNCTION update_character_experience()
RETURNS TRIGGER AS $$
BEGIN
    -- Update character experience and level when interaction is added
    UPDATE CharacterInstances 
    SET 
        ExperienceCount = ExperienceCount + COALESCE(NEW.ExperienceGained, 1),
        Level = GREATEST(1, (ExperienceCount + COALESCE(NEW.ExperienceGained, 1)) / 5),
        LastInteractionAt = NEW.Timestamp
    WHERE Id = NEW.CharacterInstanceId;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_character_experience
    AFTER INSERT ON CharacterInteractions
    FOR EACH ROW
    EXECUTE FUNCTION update_character_experience();

-- Memory Consolidation Function
CREATE OR REPLACE FUNCTION consolidate_old_memories()
RETURNS void AS $$
DECLARE
    old_memory RECORD;
    consolidated_content TEXT;
BEGIN
    -- Find old acute memories (older than 7 days)
    FOR old_memory IN 
        SELECT CharacterInstanceId, ARRAY_AGG(Id) as memory_ids, ARRAY_AGG(Content) as contents
        FROM CharacterMemories 
        WHERE MemoryType = 'Acute' 
        AND CreatedAt < NOW() - INTERVAL '7 days'
        AND IsActive = true
        GROUP BY CharacterInstanceId
        HAVING COUNT(*) >= 3
    LOOP
        -- Create consolidated thematic memory
        consolidated_content := 'Consolidated memory: ' || ARRAY_TO_STRING(old_memory.contents, ' | ');
        
        INSERT INTO CharacterMemories (
            CharacterInstanceId, MemoryType, Content, EmotionalContext, 
            Importance, ConsolidatedFrom, ConsolidatedAt
        ) VALUES (
            old_memory.CharacterInstanceId, 'Thematic', consolidated_content, 'Neutral',
            7, old_memory.memory_ids, NOW()
        );
        
        -- Deactivate old memories
        UPDATE CharacterMemories 
        SET IsActive = false 
        WHERE Id = ANY(old_memory.memory_ids);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Beispiel-Daten einfügen
INSERT INTO Families (Name, Email, SubscriptionLevel) VALUES 
('Familie Schmidt', 'schmidt@example.com', 'Premium'),
('Familie Müller', 'mueller@example.com', 'Family'),
('Familie Weber', 'weber@example.com', 'Free');

-- Beispiel-Lernziele
INSERT INTO LearningObjectives (Name, Description, Category, TargetAgeMin, TargetAgeMax, Keywords, SuccessCriteria) VALUES 
('Mut entwickeln', 'Hilft Kindern dabei, mutige Entscheidungen zu treffen und Ängste zu überwinden', 'Persönlichkeit', 4, 12, 
 ARRAY['mut', 'tapferkeit', 'herausforderung', 'angst', 'selbstvertrauen'], 
 ARRAY['Kind zeigt mutiges Verhalten in der Geschichte', 'Charakter überwindet eine Furcht']),
 
('Vokabular erweitern', 'Erweitert den Wortschatz spielerisch durch neue Begriffe und Ausdrücke', 'Sprache', 3, 10, 
 ARRAY['wörter', 'sprache', 'kommunikation', 'begriffe', 'vokabeln'], 
 ARRAY['Mindestens 5 neue Wörter pro Geschichte', 'Verwendung komplexerer Satzstrukturen']),
 
('Empathie fördern', 'Entwickelt Mitgefühl und Verständnis für andere Charaktere und Situationen', 'Sozial', 4, 12, 
 ARRAY['gefühle', 'mitgefühl', 'freundschaft', 'verstehen', 'helfen'], 
 ARRAY['Charakter hilft anderen', 'Verständnis für andere Perspektiven zeigen']),
 
('Problemlösung', 'Fördert logisches Denken und kreative Lösungsansätze', 'Kognition', 5, 14, 
 ARRAY['denken', 'lösung', 'problem', 'kreativität', 'logik'], 
 ARRAY['Charakter löst ein komplexes Problem', 'Verwendung von logischen Schritten']),
 
('Umweltbewusstsein', 'Sensibilisiert für Umweltthemen und Nachhaltigkeit', 'Werte', 6, 16, 
 ARRAY['natur', 'umwelt', 'tiere', 'nachhaltigkeit', 'schutz'], 
 ARRAY['Umweltfreundliches Verhalten gezeigt', 'Verständnis für Naturschutz entwickelt']);

-- Beispiel Charakter-DNA
INSERT INTO CharacterDnas (Name, Description, Appearance, Personality, BaseCourage, BaseCreativity, BaseHelpfulness, BaseHumor, BaseWisdom, BaseCuriosity, BaseEmpathy, BasePersistence, CreatorFamilyId, IsPublic) 
SELECT 
    'Luna die Entdeckerin',
    'Eine mutige junge Abenteurerin, die neue Welten erkundet und anderen hilft',
    'Lange braune Haare, grüne Augen, trägt eine Entdeckerausrüstung mit Kompass und Rucksack',
    'Neugierig, mutig, hilfsbereit und optimistisch. Liebt es, neue Dinge zu lernen und Freunden zu helfen.',
    85, 70, 80, 60, 65, 95, 75, 80,
    f.Id, true
FROM Families f WHERE f.Email = 'schmidt@example.com';

INSERT INTO CharacterDnas (Name, Description, Appearance, Personality, BaseCourage, BaseCreativity, BaseHelpfulness, BaseHumor, BaseWisdom, BaseCuriosity, BaseEmpathy, BasePersistence, CreatorFamilyId, IsPublic) 
SELECT 
    'Max der Erfinder',
    'Ein kreativer Tüftler, der fantastische Maschinen und Gadgets erfindet',
    'Kurze blonde Haare, blaue Augen, immer mit Werkzeuggürtel und Schutzbrille',
    'Kreativ, geduldig, einfallsreich und begeisterungsfähig. Löst gerne knifflige Probleme.',
    65, 95, 85, 75, 70, 80, 70, 90,
    f.Id, true
FROM Families f WHERE f.Email = 'mueller@example.com';

-- Beispiel Charakter-Instanzen
INSERT INTO CharacterInstances (CharacterDnaId, FamilyId, CustomName, CurrentCourage, CurrentCreativity, CurrentHelpfulness, CurrentHumor, CurrentWisdom, CurrentCuriosity, CurrentEmpathy, CurrentPersistence, Level, ExperienceCount)
SELECT 
    dna.Id, f.Id, NULL, 
    dna.BaseCourage, dna.BaseCreativity, dna.BaseHelpfulness, dna.BaseHumor, 
    dna.BaseWisdom, dna.BaseCuriosity, dna.BaseEmpathy, dna.BasePersistence,
    1, 0
FROM CharacterDnas dna
JOIN Families f ON dna.CreatorFamilyId = f.Id;

-- Beispiel Stories
INSERT INTO Stories (Title, Content, CharacterInstanceId, FamilyId, Genre, TargetAge, Length, LearningObjectives, Prompt, WordCount)
SELECT 
    'Das Geheimnis der verschwundenen Sterne',
    'Luna die Entdeckerin bemerkte eines Nachts, dass die Sterne am Himmel langsam verschwanden. Mit ihrem treuen Kompass machte sie sich auf eine abenteuerliche Reise durch verschiedene Welten, um herauszufinden, was mit den Sternen geschehen war. Dabei traf sie auf freundliche Aliens, die ihr erklärten, dass ein trauriger Drache die Sterne gesammelt hatte, weil er sich einsam fühlte. Luna zeigte dem Drachen, wie schön es ist, die Sterne mit allen zu teilen, und gemeinsam brachten sie die Sterne zurück an den Himmel.',
    ci.Id, f.Id, 'Fantasy', 7, 'Mittel',
    ARRAY['Empathie fördern', 'Mut entwickeln'],
    'Ein Abenteuer im Weltraum mit verschwundenen Sternen',
    156
FROM CharacterInstances ci
JOIN Families f ON ci.FamilyId = f.Id
JOIN CharacterDnas dna ON ci.CharacterDnaId = dna.Id
WHERE dna.Name = 'Luna die Entdeckerin'
LIMIT 1;

-- Beispiel Charakter-Memories
INSERT INTO CharacterMemories (CharacterInstanceId, MemoryType, Content, EmotionalContext, Importance, Keywords)
SELECT 
    ci.Id, 'Acute', 
    'Luna traf zum ersten Mal einen einsamen Drachen und zeigte Mitgefühl für seine Einsamkeit.',
    'Joy', 8,
    ARRAY['drache', 'einsamkeit', 'mitgefühl', 'erste begegnung']
FROM CharacterInstances ci
JOIN CharacterDnas dna ON ci.CharacterDnaId = dna.Id
WHERE dna.Name = 'Luna die Entdeckerin'
LIMIT 1;

-- Views für einfachere Abfragen
CREATE VIEW CharacterWithDna AS
SELECT 
    ci.Id as InstanceId,
    ci.CustomName,
    ci.Level,
    ci.ExperienceCount,
    ci.LastInteractionAt,
    dna.Name as DnaName,
    dna.Description,
    dna.Appearance,
    dna.Personality,
    dna.IsPublic,
    ci.CurrentCourage,
    ci.CurrentCreativity,
    ci.CurrentHelpfulness,
    ci.CurrentHumor,
    ci.CurrentWisdom,
    ci.CurrentCuriosity,
    ci.CurrentEmpathy,
    ci.CurrentPersistence,
    f.Name as FamilyName
FROM CharacterInstances ci
JOIN CharacterDnas dna ON ci.CharacterDnaId = dna.Id
JOIN Families f ON ci.FamilyId = f.Id
WHERE ci.IsActive = true;

-- Erfolgsmeldung
DO $$
BEGIN
    RAISE NOTICE 'Edory database schema created successfully!';
    RAISE NOTICE 'Created tables: Families, CharacterDnas, CharacterInstances, CharacterMemories, Stories, LearningObjectives, CharacterInteractions, StoryRatings, LearningProgress';
    RAISE NOTICE 'Inserted sample data for testing';
    RAISE NOTICE 'Memory system with hierarchical structure (Acute -> Thematic -> Personality) is ready';
END $$;
