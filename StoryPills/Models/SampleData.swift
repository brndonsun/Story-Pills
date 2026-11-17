import Foundation

// Mock content ported from the prototype. Replace with your backend / AI generation later.
enum SampleData {
    static let storyConcepts: [StoryConcept] = [
        StoryConcept(title: "The Last Letter", description: "Every morning, a letter arrives from someone who hasn't been born yet.", opening: "On Tuesday morning, the blue envelope was waiting beneath Mia's door again. This time, the handwriting belonged to someone who would not be born for another twenty-three years.", motif: .letter, tags: ["romance", "time travel", "lost memories"]),
        StoryConcept(title: "Midnight at the Museum", description: "When the clock strikes twelve, every painting in the museum begins to change.", opening: "At exactly midnight, the girl in the oldest portrait turned her head and looked directly at Nora. Then she lifted one painted finger to her lips and pointed beyond the frame.", motif: .moon, tags: ["magic", "mystery", "adventure"]),
        StoryConcept(title: "The Forgotten Summer", description: "Two strangers discover they share memories of a summer that never happened.", opening: "Leo recognized the photograph before he recognized the girl holding it. He had stood beside that lake, beneath that impossible violet sky, though every calendar insisted the summer had never existed.", motif: .door, tags: ["romance", "lost memories", "mystery"]),
        StoryConcept(title: "The Academy of Forgotten Spells", description: "A student discovers a hidden school where forgotten magic is taught.", opening: "On the morning of her seventeenth birthday, Elara received a letter written in ink that disappeared whenever she tried to read it. By midnight, the words returned with an invitation to a school erased from every map.", motif: .map, tags: ["magic", "magical academy", "fantasy"]),
        StoryConcept(title: "The Girl Who Couldn't Cast", description: "In a world where everyone has magic, one girl discovers her unusual power.", opening: "Everyone in Linnea's class could summon light by age six. At seventeen, she still produced only silence—until the silence answered her back.", motif: .moon, tags: ["magic", "magical academy", "fantasy"]),
        StoryConcept(title: "The Last Spellkeeper", description: "A mysterious invitation leads a teenager to a school that shouldn't exist.", opening: "The invitation appeared inside a locked library book, addressed to Ash in handwriting identical to his own. Beneath his name were four words: You already know why.", motif: .letter, tags: ["magic", "magical academy", "mystery"]),
        StoryConcept(title: "The House That Hummed", description: "A haunted mansion begins singing the childhood song of its newest visitor.", opening: "The house had been empty for eighty years, yet someone was humming behind the nursery wall. Wren knew the melody; her mother used to sing it before she disappeared.", motif: .door, tags: ["horror", "haunted mansion", "mystery"]),
        StoryConcept(title: "Tomorrow, Again", description: "A clockmaker relives one hour until she can prevent a stranger's disappearance.", opening: "At 4:17, every clock in the shop stopped. At 4:18, the stranger vanished. At 4:19, June opened her eyes and it was 4:17 again.", motif: .moon, tags: ["time travel", "mystery", "adventure"]),
    ]

    static func searchConcepts(_ query: String, batch: Int = 0) -> [StoryConcept] {
        let normalized = query.lowercased().trimmingCharacters(in: .whitespaces)
        if normalized.isEmpty || normalized == "surprise" {
            return (0..<4).map { storyConcepts[($0 + batch * 3) % storyConcepts.count] }
        }
        let words = normalized.split(separator: " ").map(String.init)
        let matches = storyConcepts.filter { concept in
            concept.tags.contains { tag in words.contains { tag.contains($0) || $0.contains(tag) } }
        }
        if matches.count >= 3 {
            return (0..<min(5, matches.count)).map { matches[($0 + batch) % matches.count] }
        }
        let topic = query.trimmingCharacters(in: .whitespaces).capitalized
        let lower = query.lowercased()
        let generated = [
            StoryConcept(title: "The \(topic) Archive", description: "A hidden archive reveals that every story about \(lower) was recording the same impossible event.", opening: "The file labeled “\(topic)” had no author, no date, and one unsettling instruction: do not read this alone. Mara opened it anyway.", motif: .letter, tags: [normalized]),
            StoryConcept(title: "Before \(topic) Disappears", description: "Two strangers have one night to protect the last trace of \(lower) from being erased.", opening: "By sunrise, nobody would remember \(lower). Only Inez and the stranger at her window seemed to know that anything was missing.", motif: .moon, tags: [normalized]),
            StoryConcept(title: "The Door to \(topic)", description: "An ordinary doorway opens onto a world shaped by \(lower) and one rule nobody dares to break.", opening: "The door appeared between platforms eight and nine, painted the exact color of a forgotten dream. Above its handle, a brass plaque read: \(topic).", motif: .door, tags: [normalized]),
            StoryConcept(title: "A Map Made of \(topic)", description: "A mapmaker follows a shifting trail connected to \(lower) and a memory that may not belong to her.", opening: "Each morning, a new road drew itself across Sora's map. Today it formed a single word in silver ink: \(topic).", motif: .map, tags: [normalized]),
        ]
        let pool = matches + generated
        return (0..<4).map { pool[($0 + batch) % pool.count] }
    }

    static let chapters: [Chapter] = [
        Chapter(title: "The Door Without a Shadow", kicker: "A city of impossible doors", text: [
            "Mara first noticed the door at 2:17 in the morning, where the brick wall of the old observatory had always been.",
            "It was the color of a sky just before a storm—deep violet threaded with silver. No handle. No keyhole. And strangest of all, beneath the hard white moonlight, it cast no shadow.",
            "Her phone buzzed in her pocket. A message from an unknown number lit the screen: Some doors only appear when you are ready to lose what you know.",
            "Mara read the words twice. Across the courtyard, the observatory windows reflected constellations that had vanished centuries ago.",
            "She should have called someone. Instead, she reached toward the door and felt a low vibration humming through the rain-cold air.",
            "The silver threads brightened beneath her fingertips. Somewhere beyond the wall, a child laughed—and the impossible door slowly opened inward.",
        ]),
        Chapter(title: "A Map Written in Starlight", kicker: "The door remembers her name", text: [
            "Mara pressed her palm to the violet surface. The door answered with a warm pulse, like a second heartbeat beneath her skin.",
            "Silver lines bloomed outward from her fingers, drawing streets she recognized—and others that could not exist. At the center of the luminous map, a tiny star flickered over her childhood home.",
            "Then the door whispered her name in her mother's voice. Behind her, footsteps crossed the empty courtyard, slow and deliberate.",
            "She stepped through. The observatory remained behind her, but gravity loosened and the streets folded upward like pages in an enormous book.",
            "Every window held a different version of the night: one raining upward, one filled with summer, one where Mara had never left home.",
            "The star on the map pulsed faster. Whoever followed her had crossed the threshold too.",
        ]),
        Chapter(title: "The Keeper of Lost Hours", kicker: "Every mystery keeps a price", text: [
            "The figure who stepped into the moonlight wore a coat stitched with dozens of silent watch faces. Each showed a different hour.",
            "“You have three minutes,” the stranger said, though none of the watches moved. “Choose the truth you want, not the one you think you deserve.”",
            "The map shifted. Two paths now glowed: one toward the star, one spiraling below the city, where something enormous seemed to be dreaming.",
            "Mara asked what would happen when the three minutes ended. The Keeper smiled sadly and opened one empty hand.",
            "Inside it lay an hour she remembered losing: the last afternoon with her mother, whole and bright as amber.",
            "Below them, the dreaming thing turned over. All the floating streets trembled, and one by one, their lights went out.",
        ]),
        Chapter(title: "Where All Doors Begin", kicker: "One last impossible choice", text: [
            "Mara chose the path beneath the city. The silver map wrapped around her like a ribbon, and the observatory vanished into a sky filled with a thousand floating doors.",
            "At their center waited a little girl with Mara's eyes, holding the memory she had spent half her life trying to forget.",
            "This time, Mara did not turn away. She took the girl's hand, and every locked door in the city opened to the dawn.",
            "The Keeper's watches began to tick in unison. Their sound rolled through the impossible city like soft rain.",
            "Mara gave the borrowed hour back—not to the past, but to the girl she had been. The memory became a small, steady star.",
            "When she returned to the observatory, the violet door was gone. But in every ordinary doorway, a silver thread waited for her to notice.",
        ]),
    ]

    static let chapterSummaries: [ChapterSummary] = [
        ChapterSummary(summary: "Mara discovers a violet door at the abandoned observatory that casts no shadow.", events: ["An impossible door appears", "A message warns her", "The threshold opens"]),
        ChapterSummary(summary: "A living map draws Mara into a city made from alternate versions of her life.", events: ["The door speaks", "A starlit map awakens", "Someone follows her"]),
        ChapterSummary(summary: "The Keeper offers Mara a lost hour and a choice between two dangerous truths.", events: ["Time stands still", "A lost memory returns", "The city begins to darken"]),
        ChapterSummary(summary: "Mara faces the memory she avoided and opens every locked door to a new dawn.", events: ["She descends below", "Her younger self waits", "The doors finally open"]),
        ChapterSummary(summary: "Beyond the final door, Mara finds a new constellation forming from every choice she made.", events: ["The city remembers", "A new path appears", "Her story becomes a map"]),
    ]

    static let chapterChoices: [ChapterChoice] = [
        ChapterChoice(decision: "You chose to open the door.", impact: "That single decision led Mara into a world where shadows could speak."),
        ChapterChoice(decision: "You chose to trust the living map.", impact: "Following its light turned a warning into a path through impossible streets."),
        ChapterChoice(decision: "You chose the truth over the lost hour.", impact: "Mara let go of the past and uncovered what the city had been hiding."),
        ChapterChoice(decision: "You chose to face the memory.", impact: "By reaching for her younger self, Mara opened every door to a different future."),
        ChapterChoice(decision: "You chose to leave a light behind.", impact: "Her journey became a constellation that could guide the next lost traveler."),
    ]

    static let libraryBooks: [LibraryBook] = [
        LibraryBook(id: "door", title: "The Door Without a Shadow", meta: "Mystery · Short story", status: .inProgress, progress: 50, chapterLabel: "Chapter 2 of 4", genre: .mystery, summary: "A sleepless cartographer finds a door that leads into a city built from lost memories—and discovers it already knows her name.", journey: [.mystery, .fantasy, .horror, .mystery]),
        LibraryBook(id: "letters", title: "Letters From Tomorrow", meta: "Romance · Novella", status: .completed, progress: 100, chapterLabel: "8 chapters · Completed", genre: .romance, summary: "Two strangers separated by seven years exchange letters through a library book that refuses to stay in either timeline.", journey: [.romance, .mystery, .romance, .humor, .fantasy]),
        LibraryBook(id: "moon", title: "The Cartographer's Moon", meta: "Fantasy · Short story", status: .completed, progress: 100, chapterLabel: "4 chapters · Completed", genre: .fantasy, summary: "A mapmaker charts a moon that changes its geography every night, revealing a path to a kingdom erased from history.", journey: [.fantasy, .mystery, .horror, .fantasy]),
    ]

    static let communityStories: [CommunityStory] = [
        CommunityStory(id: "museum", title: "Midnight at the Museum", author: "Nora Vale", initials: "NV", genres: [.mystery, .horror, .humor], summary: "At midnight, every painting changes—and one of them starts painting Nora back.", opening: "At exactly midnight, the girl in the oldest portrait turned her head and looked directly at Nora.", motif: .moon, comments: 12, likes: 86, sharedAgo: "8m ago", length: "Short Story"),
        CommunityStory(id: "starlight", title: "A Map Written in Starlight", author: "Milo Chen", initials: "MC", genres: [.fantasy, .adventure, .mystery], summary: "A mapmaker discovers a constellation that redraws the world each time someone makes a brave choice.", opening: "The first new star appeared above the harbor on a night when the sky was supposed to be empty.", motif: .map, comments: 0, likes: 143, sharedAgo: "24m ago", length: "Novella"),
        CommunityStory(id: "letters", title: "Letters From Tomorrow", author: "Sofia Reed", initials: "SR", genres: [.romance, .mystery, .fantasy], summary: "Two strangers seven years apart exchange letters through a library book that refuses to stay in one timeline.", opening: "The letter was tucked into a book nobody had checked out in seven years, and it began with Sofia's name.", motif: .letter, comments: 41, likes: 219, sharedAgo: "1h ago", length: "Novel"),
        CommunityStory(id: "house", title: "The House That Hummed", author: "Iris Moon", initials: "IM", genres: [.horror, .mystery, .adventure], summary: "An abandoned house begins singing the childhood song of its newest visitor.", opening: "The house had been empty for eighty years, yet someone was humming behind the nursery wall.", motif: .door, comments: 19, likes: 104, sharedAgo: "2h ago", length: "Short Story"),
    ]

    static let readerComments: [ReaderComment] = [
        ReaderComment(id: 1, name: "Sofia Reed", initials: "SR", chapter: 1, genre: .mystery, time: "2m ago", text: "That final line made me stop and reread the whole page. The atmosphere is so good.", likes: 18),
        ReaderComment(id: 2, name: "Milo Chen", initials: "MC", chapter: 1, genre: .horror, time: "8m ago", text: "The detail about the shadow is going to matter later, isn't it?", likes: 11, spoiler: true),
        ReaderComment(id: 3, name: "Alex Morgan", initials: "AM", chapter: 1, genre: .fantasy, time: "12m ago", text: "I love how the pill changed the mood without changing the opening.", likes: 7, own: true),
        ReaderComment(id: 4, name: "Nora Vale", initials: "NV", chapter: 1, genre: .mystery, time: "10m ago", text: "Exactly what I was thinking.", likes: 3, parentId: 1),
    ]

    static func communityComments() -> [String: [ReaderComment]] {
        let plain = readerComments.prefix(3).map { comment -> ReaderComment in
            var c = comment
            c.spoiler = false
            c.parentId = nil
            return c
        }
        return [
            "museum": Array(plain),
            "starlight": [],
            "letters": Array(plain),
            "house": Array(plain.prefix(1)),
        ]
    }
}
