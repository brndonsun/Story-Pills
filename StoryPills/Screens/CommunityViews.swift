import SwiftUI

// MARK: - Community feed

struct CommunityView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette
    @State private var filter: Genre?
    @State private var visibleCount = 4
    @State private var commentStoryID: String?

    private var filtered: [CommunityStory] {
        guard let filter else { return app.communityFeed }
        return app.communityFeed.filter { $0.genres.contains(filter) }
    }

    /// The prototype repeats stories to simulate an infinite feed (max 12).
    private var visible: [CommunityStory] {
        guard !filtered.isEmpty else { return [] }
        return (0..<min(visibleCount, 12)).map { filtered[$0 % filtered.count] }
    }

    var body: some View {
        ScreenScroll(bottomInset: 110) {
            TopBar()
            HeadingBlock(eyebrow: "Read what others created", eyebrowIcon: nil, line1: "Stories From", line2: "Other Readers")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chip("All", selected: filter == nil) { filter = nil }
                    ForEach(Genre.allCases) { genre in
                        chip(genre.name, selected: filter == genre) { filter = genre }
                    }
                }
            }
            .padding(.bottom, 14)

            LazyVStack(spacing: 16) {
                ForEach(Array(visible.enumerated()), id: \.offset) { index, story in
                    feedCard(story)
                        .onAppear {
                            if index == visible.count - 1 && visibleCount < 12 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { visibleCount = min(12, visibleCount + 2) }
                            }
                        }
                }
                if visibleCount < 12 && !visible.isEmpty {
                    LoadingDots().padding(.vertical, 12)
                }
            }
        }
        .sheet(isPresented: Binding(get: { commentStoryID != nil }, set: { if !$0 { commentStoryID = nil } })) {
            if let id = commentStoryID {
                CommentsSheet(
                    comments: Binding(get: { app.communityComments[id] ?? [] }, set: { app.communityComments[id] = $0 }),
                    chapter: 1,
                    genre: app.communityFeed.first { $0.id == id }?.genres.first ?? .mystery,
                    simple: true,
                    onSend: { app.incrementCommentCount(storyID: id) }
                )
            }
        }
    }

    private func chip(_ title: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(title) { withAnimation { action(); visibleCount = 4 } }
            .font(Theme.body(13, .semibold))
            .foregroundStyle(selected ? .white : palette.muted)
            .padding(.horizontal, 14).padding(.vertical, 8)
            .background(selected ? AnyShapeStyle(Theme.primaryGradient) : AnyShapeStyle(palette.surface), in: Capsule())
            .overlay(Capsule().stroke(palette.surfaceBorder))
            .buttonStyle(.plain)
    }

    private func feedCard(_ story: CommunityStory) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                AvatarBadge(initials: story.initials, size: 34)
                VStack(alignment: .leading, spacing: 1) {
                    Text(story.author).font(Theme.body(13, .semibold)).foregroundStyle(palette.text)
                    Text(story.sharedAgo).font(Theme.body(11)).foregroundStyle(palette.faint)
                }
                Spacer()
                Image(systemName: "ellipsis").foregroundStyle(palette.faint)
            }
            MotifArt(motif: story.motif, accent: story.genres.first?.summaryAccent ?? Theme.violet)
                .frame(height: 170)
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(story.title).font(Theme.heading(16, .bold)).foregroundStyle(palette.text).lineLimit(1)
                    Text(story.length).font(Theme.body(11)).foregroundStyle(palette.faint)
                }
                Spacer()
                Image(systemName: "book").foregroundStyle(palette.muted)
            }
            GenrePath(genres: story.genres, size: 10)
            Text("\(story.opening) \(story.summary)")
                .font(Theme.body(13)).foregroundStyle(palette.muted).lineLimit(3)
            HStack(spacing: 8) {
                Button { app.toggleLike(storyID: story.id) } label: {
                    Label("\(story.likes)", systemImage: story.liked ? "heart.fill" : "heart")
                        .foregroundStyle(story.liked ? Genre.romance.accent : palette.text)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .glassCard(cornerRadius: 12)
                }
                Button { commentStoryID = story.id } label: {
                    Label("\(story.comments)", systemImage: "bubble.left")
                        .foregroundStyle(palette.text)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .glassCard(cornerRadius: 12)
                }
                Spacer()
                Button("Read Story") { app.openCommunityStory(story) }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Theme.primaryGradient, in: RoundedRectangle(cornerRadius: 12))
            }
            .font(Theme.body(12, .semibold))
            .buttonStyle(.plain)
        }
        .padding(14)
        .glassCard(cornerRadius: 22)
    }
}

// MARK: - Community story preview ("Take a peek inside")

struct CommunityPreviewView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette

    var body: some View {
        let story = app.selectedCommunity
        ScreenScroll {
            TopBar(title: "Story opening", onBack: { app.go(.community) })
            HeadingBlock(eyebrow: "Take a peek inside", line1: "Take a Peek", line2: "Inside ✨")

            VStack(alignment: .leading, spacing: 0) {
                MotifArt(motif: story.motif, accent: story.genres.first?.summaryAccent ?? Theme.violet, cornerRadius: 0)
                    .frame(height: 180)
                VStack(alignment: .leading, spacing: 10) {
                    Text("Created by \(story.author)".uppercased()).font(.system(size: 10, weight: .bold)).tracking(1).foregroundStyle(Theme.eyebrow)
                    Text(story.title).font(Theme.heading(22)).tracking(-0.7).foregroundStyle(palette.text)
                    Text(story.summary).font(Theme.body(14)).foregroundStyle(palette.muted)
                    HStack {
                        Rectangle().fill(palette.surfaceBorder).frame(height: 1)
                        Text("✦").foregroundStyle(Theme.lilac)
                        Rectangle().fill(palette.surfaceBorder).frame(height: 1)
                    }
                    .padding(.vertical, 6)
                    Text("OPENING SCENE").font(.system(size: 10, weight: .bold)).tracking(1).foregroundStyle(palette.faint)
                    Text("“\(story.opening)”").font(Theme.reading).italic().foregroundStyle(palette.text.opacity(0.9)).lineSpacing(6)
                }
                .padding(18)
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .glassCard(cornerRadius: 24)

            VStack(spacing: 10) {
                Button(action: app.readCommunityStory) { PrimaryLabel(title: "Read Story", systemImage: "book") }
                    .buttonStyle(.primary)
                Button("Back to Community") { app.go(.community) }
                    .buttonStyle(.secondary)
            }
            .padding(.top, 20)
        }
    }
}
