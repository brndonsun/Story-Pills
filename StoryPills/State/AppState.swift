import SwiftUI

/// Every screen in the prototype. Mirrors the `Screen` union in App.tsx.
enum Screen: Hashable {
    case onboarding(Int)
    case auth
    case home            // "length" in the prototype: genre picker + community row
    case storyIdea
    case storyLength
    case storyLoading
    case reading
    case pills
    case generating
    case ending
    case library
    case details
    case journey
    case profile
    case community
    case communityPreview

    /// Screens that show the floating bottom tab bar.
    var showsTabBar: Bool {
        switch self {
        case .home, .community, .library, .profile: true
        default: false
        }
    }
}

enum AuthMode { case signup, login, forgot }

/// Central app state. Ported from the `App` component's useState hooks and handlers.
@MainActor
final class AppState: ObservableObject {
    @Published var screen: Screen
    @Published var authMode: AuthMode = .signup
    @Published var profile: UserProfile
    @Published var length = StoryLength.all[0]
    @Published var genre: Genre = .mystery
    @Published var chapter = 1
    @Published var searchQuery = ""
    @Published var searchBatch = 0
    @Published var selectedConcept: StoryConcept?
    @Published var selectedCommunity = SampleData.communityStories[0]
    @Published var readerComments = SampleData.readerComments
    @Published var communityFeed = SampleData.communityStories
    @Published var communityComments = SampleData.communityComments()
    @Published var journey: [Genre] = [.mystery]
    @Published var selectedBook = SampleData.libraryBooks[0]
    @Published var journeyBack: Screen = .ending
    @Published var journeyCompleted = true

    @AppStorage("story-pills-light-theme") var lightTheme = false

    private let authKey = "story-pills-auth"
    private let onboardingKey = "story-pills-onboarding"
    private var pendingTask: Task<Void, Never>?

    init() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: authKey),
           let saved = try? JSONDecoder().decode(UserProfile.self, from: data) {
            profile = saved
            screen = .home
        } else {
            profile = UserProfile(name: "Alex Morgan", email: "alex@example.com")
            screen = defaults.string(forKey: onboardingKey) == "complete" ? .auth : .onboarding(1)
        }
    }

    func go(_ next: Screen) {
        withAnimation(.easeInOut(duration: 0.3)) { screen = next }
        scheduleAutoAdvance(for: next)
    }

    /// Loading screens advance automatically after 2.3s, as in the prototype.
    private func scheduleAutoAdvance(for next: Screen) {
        pendingTask?.cancel()
        guard next == .storyLoading || next == .generating else { return }
        pendingTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 2_300_000_000)
            guard let self, !Task.isCancelled, self.screen == next else { return }
            if next == .storyLoading { self.chapter = 1 } else { self.chapter += 1 }
            self.go(.reading)
        }
    }

    // MARK: Auth

    func openAuth(_ mode: AuthMode) {
        UserDefaults.standard.set("complete", forKey: onboardingKey)
        authMode = mode
        go(.auth)
    }

    func authenticate(_ newProfile: UserProfile) {
        profile = newProfile
        // Passwords are never persisted. Move this to the Keychain / a real auth service later.
        if let data = try? JSONEncoder().encode(newProfile) {
            UserDefaults.standard.set(data, forKey: authKey)
        }
        UserDefaults.standard.set("complete", forKey: onboardingKey)
        go(.home)
    }

    func logout() {
        UserDefaults.standard.removeObject(forKey: authKey)
        authMode = .login
        go(.auth)
    }

    // MARK: Story flow

    func continueFromHome() {
        journey = [genre]
        searchQuery = ""
        go(.storyIdea)
    }

    func startFromTopic(_ topic: String, surprise: Bool = false) {
        let clean = topic.trimmingCharacters(in: .whitespaces).trimmingCharacters(in: CharacterSet(charactersIn: ".!?"))
        let nextBatch = surprise ? searchBatch + 1 : 0
        let concept: StoryConcept
        if surprise {
            concept = SampleData.searchConcepts(genre.name, batch: nextBatch)[0]
        } else {
            let motif: Motif = genre == .romance ? .letter : (genre == .mystery || genre == .horror) ? .door : .moon
            concept = StoryConcept(
                title: "\(genre.name): \(clean.split(separator: " ").prefix(5).joined(separator: " "))",
                description: "A \(genre.name.lowercased()) story created from your idea: \(clean).",
                opening: "\(clean). That was the moment everything began to change.",
                motif: motif,
                tags: [genre.name.lowercased(), clean.lowercased()]
            )
        }
        searchQuery = surprise ? "surprise" : topic
        searchBatch = nextBatch
        selectedConcept = concept
        journey = [genre]
        chapter = 1
        go(.storyLength)
    }

    func nextFromReading() {
        go(chapter >= length.chapters ? .ending : .pills)
    }

    func choosePill(_ value: Genre) {
        genre = value
        journey.append(value)
        go(.generating)
    }

    func restart() {
        chapter = 1
        journey = [.mystery]
        genre = .mystery
        selectedConcept = nil
        searchQuery = ""
        go(.home)
    }

    // MARK: Library

    func openBook(_ book: LibraryBook) {
        selectedBook = book
        go(.details)
    }

    func openJourney(back: Screen, bookJourney: [Genre]? = nil) {
        journeyBack = back
        journeyCompleted = back == .ending || (back == .details && selectedBook.status == .completed)
        if back == .details, let bookJourney { journey = bookJourney }
        go(.journey)
    }

    func readBook() {
        selectedConcept = nil
        length = selectedBook.id == "letters" ? StoryLength.all[1] : StoryLength.all[0]
        genre = selectedBook.journey[0]
        journey = selectedBook.journey
        chapter = selectedBook.status == .completed ? 1 : 2
        go(.reading)
    }

    // MARK: Community

    func openCommunityStory(_ story: CommunityStory) {
        selectedCommunity = story
        go(.communityPreview)
    }

    func readCommunityStory() {
        let story = selectedCommunity
        selectedConcept = StoryConcept(title: story.title, description: story.summary, opening: story.opening, motif: story.motif, tags: story.genres.map { $0.name.lowercased() })
        genre = story.genres.first ?? .mystery
        journey = story.genres
        length = StoryLength.all[0]
        chapter = 1
        go(.reading)
    }

    func toggleLike(storyID: String) {
        guard let index = communityFeed.firstIndex(where: { $0.id == storyID }) else { return }
        communityFeed[index].likes += communityFeed[index].liked ? -1 : 1
        communityFeed[index].liked.toggle()
    }

    func incrementCommentCount(storyID: String) {
        guard let index = communityFeed.firstIndex(where: { $0.id == storyID }) else { return }
        communityFeed[index].comments += 1
    }
}
