import Combine
import SwiftUI

// MARK: - Home ("Where will your story begin?")

struct HomeView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette

    var body: some View {
        ScreenScroll(bottomInset: 110) {
            TopBar {
                Button { app.go(.profile) } label: { AvatarBadge(initials: app.profile.initials) }
                    .buttonStyle(.plain)
            }
            HeadingBlock(eyebrow: "First, choose a feeling", line1: "Where Will Your", line2: "Story Begin? ✨", subtitle: "Pick a genre. You’ll choose what happens inside it next.")

            SectionHeader(title: "Stories Waiting to Begin", subtitle: "Choose the feeling that starts yours")
            GenreGrid(selected: $app.genre)

            Button(action: app.continueFromHome) { PrimaryLabel(title: "Choose a Topic") }
                .buttonStyle(.primary)
                .padding(.top, 18)

            HStack(alignment: .bottom) {
                SectionHeader(title: "From the Community", subtitle: "Stories shaped by readers like you")
                Spacer()
                Button("See All") { app.go(.community) }
                    .font(Theme.body(13, .semibold))
                    .foregroundStyle(Theme.lilac)
                    .padding(.bottom, 10)
            }
            .padding(.top, 26)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(app.communityFeed.prefix(3)) { story in
                        CommunityStoryCard(story: story) { app.openCommunityStory(story) }
                    }
                }
            }
        }
    }
}

struct SectionHeader: View {
    @Environment(\.palette) private var palette
    let title: String
    var subtitle: String? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(Theme.heading(14, .bold)).foregroundStyle(palette.text)
            if let subtitle { Text(subtitle).font(Theme.body(11)).foregroundStyle(palette.faint) }
        }
        .padding(.bottom, 10)
    }
}

struct CommunityStoryCard: View {
    @Environment(\.palette) private var palette
    let story: CommunityStory
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                MotifArt(motif: story.motif, accent: story.genres.first?.summaryAccent ?? Theme.violet, cornerRadius: 14)
                    .frame(height: 96)
                Text(story.title).font(Theme.heading(13, .bold)).foregroundStyle(palette.text).lineLimit(1)
                HStack(spacing: 6) {
                    AvatarBadge(initials: story.initials, size: 18)
                    Text(story.author).font(Theme.body(11)).foregroundStyle(palette.muted)
                }
                GenrePath(genres: story.genres, size: 8)
                HStack(spacing: 10) {
                    Label("\(story.comments)", systemImage: "bubble.left")
                    Label("\(story.likes)", systemImage: "heart")
                }
                .font(Theme.body(11))
                .foregroundStyle(palette.faint)
            }
            .padding(10)
            .frame(width: 200)
            .glassCard(cornerRadius: 18)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Topic

struct TopicSelectionView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette
    private let prompts = ["Enemies to lovers", "A secret invitation", "Lost memories", "One impossible night", "A hidden world"]

    private var topic: Binding<String> {
        Binding(
            get: { app.searchQuery == "surprise" ? "" : app.searchQuery },
            set: { app.searchQuery = String($0.prefix(180)) }
        )
    }

    var body: some View {
        ScreenScroll {
            TopBar(title: "\(app.genre.name) story", onBack: { app.go(.home) })

            VStack(alignment: .leading, spacing: 12) {
                GenreTag(genre: app.genre)
                GradientHeading(line1: "What Should Your", line2: "Story Be About?")
                Text("Write one sentence, or let a little magic choose for you.")
                    .font(Theme.body(14)).foregroundStyle(palette.muted)
            }
            .padding(.vertical, 20)

            VStack(alignment: .leading, spacing: 8) {
                Text("Your story idea").font(Theme.body(12, .semibold)).foregroundStyle(palette.muted)
                ZStack(alignment: .topLeading) {
                    if topic.wrappedValue.isEmpty {
                        Text("Two rivals are forced to work together and slowly fall in love...")
                            .foregroundStyle(palette.faint)
                            .padding(.top, 8).padding(.leading, 5)
                    }
                    TextEditor(text: topic)
                        .scrollContentBackground(.hidden)
                        .foregroundStyle(palette.text)
                }
                .font(Theme.body(15))
                .frame(height: 96)
                Text("\(topic.wrappedValue.count)/180")
                    .font(Theme.body(11)).foregroundStyle(palette.faint)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(14)
            .glassCard(cornerRadius: 18)

            Text("Try a spark").font(Theme.body(12, .semibold)).foregroundStyle(palette.muted).padding(.top, 18)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(prompts, id: \.self) { prompt in
                        Button(prompt) { app.searchQuery = prompt }
                            .font(Theme.body(12, .medium))
                            .foregroundStyle(palette.text)
                            .padding(.horizontal, 12).padding(.vertical, 8)
                            .glassCard(cornerRadius: 14)
                            .buttonStyle(.plain)
                    }
                }
            }
            .padding(.top, 8)

            HStack {
                Rectangle().fill(palette.surfaceBorder).frame(height: 1)
                Text("or").font(Theme.body(12)).foregroundStyle(palette.faint)
                Rectangle().fill(palette.surfaceBorder).frame(height: 1)
            }
            .padding(.vertical, 18)

            Button { app.startFromTopic("", surprise: true) } label: {
                HStack(spacing: 12) {
                    CapsuleIllustration(left: Theme.violet, right: Genre.romance.accent, width: 44)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Surprise Me").font(Theme.heading(14, .bold)).foregroundStyle(palette.text)
                        Text("Let the pill invent a \(app.genre.name.lowercased()) idea.").font(Theme.body(12)).foregroundStyle(palette.muted)
                    }
                    Spacer()
                    Image(systemName: "sparkles").foregroundStyle(Theme.lilac)
                }
                .padding(14)
                .glassCard(cornerRadius: 18, tint: Theme.violet, selected: false)
            }
            .buttonStyle(.plain)

            Button { app.startFromTopic(app.searchQuery) } label: { PrimaryLabel(title: "Find My Story") }
                .buttonStyle(.primary)
                .disabled(topic.wrappedValue.trimmingCharacters(in: .whitespaces).isEmpty)
                .padding(.top, 20)
        }
    }
}

// MARK: - Length

struct StoryLengthView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette

    var body: some View {
        ScreenScroll {
            TopBar(title: "Story length", onBack: { app.go(.storyIdea) })
            HeadingBlock(eyebrow: "Choose your pace", eyebrowIcon: "clock", line1: "How Long Will Your", line2: "Adventure Be?", subtitle: "Choose the shape of the journey ahead.")

            VStack(spacing: 12) {
                ForEach(Array(StoryLength.all.enumerated()), id: \.element.id) { index, item in
                    let selected = app.length == item
                    let accent = [Genre.fantasy.accent, Theme.violet, Genre.romance.accent][index]
                    Button { withAnimation(.easeOut(duration: 0.2)) { app.length = item } } label: {
                        HStack(spacing: 14) {
                            CapsuleIllustration(left: accent, right: accent.opacity(0.6), width: 40 + CGFloat(index) * 10)
                                .frame(width: 70)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(item.time).font(Theme.body(11)).foregroundStyle(palette.faint)
                                Text(item.name).font(Theme.heading(16, .bold)).foregroundStyle(palette.text)
                                Text(item.blurb).font(Theme.body(12)).foregroundStyle(palette.muted)
                            }
                            Spacer()
                            Circle()
                                .stroke(accent.opacity(0.6), lineWidth: 1.5)
                                .frame(width: 22, height: 22)
                                .overlay(Circle().fill(accent).frame(width: 11).opacity(selected ? 1 : 0))
                        }
                        .padding(14)
                        .glassCard(tint: accent, selected: selected)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button { app.go(.storyLoading) } label: { PrimaryLabel(title: "Continue") }
                .buttonStyle(.primary)
                .padding(.top, 22)
        }
    }
}

// MARK: - Loading (chapter one)

struct StoryLoadingView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette
    private let messages = ["A little magic is happening...", "Your story is coming to life...", "Mixing your next adventure..."]
    @State private var message = 0
    private let timer = Timer.publish(every: 0.65, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                Circle().fill(app.genre.accent.opacity(0.3)).frame(width: 220).blur(radius: 50)
                CapsuleIllustration(left: app.genre.accent, right: Genre.romance.accent, width: 170)
            }
            VStack(spacing: 12) {
                Eyebrow(text: "Chapter one", systemImage: "sparkles")
                Text(messages[message])
                    .font(Theme.heading(27))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(palette.text)
                    .id(message)
                    .transition(.opacity)
                (Text("Your ") + Text(app.genre.name.lowercased()).bold() + Text(" pill is shaping the first page."))
                    .font(Theme.body(14))
                    .foregroundStyle(palette.muted)
                LoadingDots().padding(.top, 6)
            }
            Spacer()
        }
        .padding(.horizontal, 28)
        .onReceive(timer) { _ in withAnimation { message = (message + 1) % messages.count } }
    }
}
