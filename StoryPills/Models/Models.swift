import SwiftUI

enum Genre: String, CaseIterable, Identifiable, Hashable {
    case mystery = "Mystery"
    case romance = "Romance"
    case horror = "Horror"
    case fantasy = "Fantasy"
    case humor = "Humor"
    case adventure = "Adventure"

    var id: String { rawValue }
    var name: String { rawValue }

    var detail: String {
        switch self {
        case .mystery: "Secrets & clues"
        case .romance: "Hearts & chance"
        case .horror: "Shadows & chills"
        case .fantasy: "Magic & wonder"
        case .humor: "Chaos & laughs"
        case .adventure: "Risk & discovery"
        }
    }

    var symbol: String {
        switch self {
        case .mystery: "?"
        case .romance: "♡"
        case .horror: "◇"
        case .fantasy: "✦"
        case .humor: "∿"
        case .adventure: "↗"
        }
    }

    /// Accent used on cards and pills (`genres[].color` in the prototype).
    var accent: Color {
        switch self {
        case .mystery: Color(hex: 0x966CFF)   // violet
        case .romance: Color(hex: 0xF05AB5)   // pink
        case .horror: Color(hex: 0x5579FF)    // blue
        case .fantasy: Color(hex: 0x2ED3E0)   // cyan
        case .humor: Color(hex: 0xF59B58)     // orange
        case .adventure: Color(hex: 0xE7B85D) // gold
        }
    }

    /// Accent used in journeys, summaries and community paths (`summaryGenreColors`).
    var summaryAccent: Color {
        switch self {
        case .horror: Color(hex: 0xC65378) // crimson
        default: accent
        }
    }
}

struct StoryLength: Identifiable, Hashable {
    let name: String
    let chapters: Int
    let time: String
    let blurb: String
    var id: String { name }

    static let all: [StoryLength] = [
        StoryLength(name: "Short Story", chapters: 4, time: "5–10k words · 4 chapters", blurb: "A little magic in one sitting."),
        StoryLength(name: "Novella", chapters: 8, time: "20–40k words · 8 chapters", blurb: "Just enough time to get lost."),
        StoryLength(name: "Novel", chapters: 12, time: "50–100k words · 12 chapters", blurb: "For stories you never want to end."),
    ]
}

enum Motif: String, Hashable {
    case letter, moon, door, map

    var systemImage: String {
        switch self {
        case .letter: "envelope.fill"
        case .moon: "moon.stars.fill"
        case .door: "door.left.hand.open"
        case .map: "map.fill"
        }
    }
}

struct StoryConcept: Identifiable, Hashable {
    let title: String
    let description: String
    let opening: String
    let motif: Motif
    let tags: [String]
    var id: String { title }
}

struct Chapter {
    let title: String
    let kicker: String
    let text: [String]
}

struct ChapterSummary {
    let summary: String
    let events: [String]
}

struct ChapterChoice {
    let decision: String
    let impact: String
}

struct LibraryBook: Identifiable, Hashable {
    enum Status: String { case inProgress = "In Progress", completed = "Completed" }
    let id: String
    let title: String
    let meta: String
    let status: Status
    let progress: Int
    let chapterLabel: String
    let genre: Genre
    let summary: String
    let journey: [Genre]
}

struct CommunityStory: Identifiable, Hashable {
    let id: String
    let title: String
    let author: String
    let initials: String
    let genres: [Genre]
    let summary: String
    let opening: String
    let motif: Motif
    var comments: Int
    var likes: Int
    var sharedAgo: String
    var length: String
    var liked = false
}

struct ReaderComment: Identifiable, Hashable {
    let id: Int
    let name: String
    let initials: String
    let chapter: Int
    let genre: Genre
    let time: String
    let text: String
    var likes: Int
    var liked = false
    var spoiler = false
    var revealed = false
    var own = false
    var parentId: Int? = nil
}

struct UserProfile: Codable, Equatable {
    var name: String
    var email: String

    var initials: String {
        name.split(separator: " ").compactMap(\.first).prefix(2).map(String.init).joined().uppercased()
    }
}

// MARK: - Story DNA

struct StoryDNA {
    struct Segment: Identifiable {
        let genre: Genre
        let count: Int
        let percentage: Int
        var id: Genre { genre }
    }
    let segments: [Segment]
    let title: String
    let description: String

    init(journey: [Genre]) {
        var counts: [Genre: Int] = [:]
        for genre in journey { counts[genre, default: 0] += 1 }
        let total = max(journey.count, 1)
        segments = counts
            .map { Segment(genre: $0.key, count: $0.value, percentage: Int((Double($0.value) / Double(total) * 100).rounded())) }
            .sorted { $0.count > $1.count }

        let identities: [Genre: (String, String)] = [
            .fantasy: ("The Dream Weaver", "You followed wonder into the unknown and gave the impossible room to become real."),
            .mystery: ("The Curious Detective", "You noticed what others missed and followed every quiet clue toward the truth."),
            .horror: ("The Fearless Wanderer", "You stepped toward the shadows, even when the safer path was behind you."),
            .romance: ("The Heart Chaser", "You trusted connection to transform the story when it mattered most."),
            .adventure: ("The Bold Explorer", "You chose momentum, discovery, and the thrill of one more horizon."),
        ]
        let hasClearLead = segments.count == 1 || (segments.count > 1 && segments[0].count > segments[1].count)
        if hasClearLead, let dominant = segments.first, let identity = identities[dominant.genre] {
            (title, description) = identity
        } else {
            title = "The Plot Twister"
            description = "You blended wonder, tension, and surprise into a story that could only be yours."
        }
    }
}
