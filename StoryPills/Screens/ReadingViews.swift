import SwiftUI

// MARK: - Reading

struct ReadingView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette
    @State private var page = 0
    @State private var forward = true
    @State private var commentsOpen = false

    private var chapterData: Chapter {
        if app.chapter == 1, let concept = app.selectedConcept {
            return Chapter(title: concept.title, kicker: "The opening you chose", text: [
                concept.opening,
                concept.description,
                "The \(app.genre.name.lowercased()) pill warmed in the hero's pocket, changing not what had already happened, but what the next moment might become.",
                "A quiet detail at the edge of the scene suddenly felt important. It had been there from the beginning, waiting for someone to notice.",
                "Beyond the familiar path, something shifted with the soft click of a lock opening in another room.",
                "There was still time to turn back. Instead, the first step carried the story forward.",
            ])
        }
        return SampleData.chapters[min(app.chapter - 1, SampleData.chapters.count - 1)]
    }

    private var pages: [[String]] {
        let text = chapterData.text
        return stride(from: 0, to: text.count, by: 2).map { Array(text[$0..<min($0 + 2, text.count)]) }
    }

    private var isLastPage: Bool { page == pages.count - 1 }
    private var progress: Double {
        (Double(app.chapter - 1) + Double(page + 1) / Double(pages.count)) / Double(app.length.chapters)
    }

    var body: some View {
        VStack(spacing: 0) {
            TopBar(onBack: { app.go(app.chapter == 1 ? .storyLength : .library) }) {
                Text("Ch. \(app.chapter) · \(page + 1)/\(pages.count)")
                    .font(Theme.body(12, .semibold))
                    .foregroundStyle(palette.muted)
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .glassCard(cornerRadius: 12)
            }
            .padding(.horizontal, 20)
            GradientProgress(value: progress, height: 3).padding(.horizontal, 20)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("Chapter \(app.chapter) · Page \(page + 1)".uppercased())
                            .font(.system(size: 11, weight: .bold)).tracking(1.2).foregroundStyle(Theme.eyebrow)
                        Spacer()
                        if app.chapter > 1 {
                            Label("Shaped by you", systemImage: "sparkles")
                                .font(Theme.body(11, .semibold)).foregroundStyle(Theme.lilac)
                        }
                    }
                    Text(chapterData.title)
                        .font(Theme.heading(30)).tracking(-1.2)
                        .foregroundStyle(palette.text)
                        .padding(.top, 12)
                    Text(chapterData.kicker).font(Theme.body(14)).italic().foregroundStyle(palette.muted).padding(.top, 4)
                    HStack {
                        Rectangle().fill(palette.surfaceBorder).frame(height: 1)
                        Text("✦").foregroundStyle(Theme.lilac)
                        Rectangle().fill(palette.surfaceBorder).frame(height: 1)
                    }
                    .padding(.vertical, 18)

                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(Array(pages[page].enumerated()), id: \.offset) { _, paragraph in
                            Text(paragraph)
                                .font(Theme.reading)
                                .lineSpacing(9)
                                .foregroundStyle(palette.text.opacity(0.9))
                        }
                    }
                    .id(page)
                    .transition(.asymmetric(
                        insertion: .move(edge: forward ? .trailing : .leading).combined(with: .opacity),
                        removal: .move(edge: forward ? .leading : .trailing).combined(with: .opacity)
                    ))

                    if isLastPage {
                        Text("End of chapter \(app.chapter)")
                            .font(Theme.body(12, .semibold)).foregroundStyle(palette.faint)
                            .frame(maxWidth: .infinity).padding(.vertical, 18)
                        CommentsPeek(comments: app.readerComments) { commentsOpen = true }
                    }
                }
                .padding(22)
                .glassCard(cornerRadius: 26)
                .padding(.horizontal, 16)
                .padding(.top, 14)
            }
            .contentShape(Rectangle())
            .gesture(DragGesture(minimumDistance: 30).onEnded { value in
                if abs(value.translation.width) > 42, abs(value.translation.width) > abs(value.translation.height) {
                    turnPage(next: value.translation.width < 0)
                }
            })

            // Page footer
            HStack {
                IconButton(systemImage: "chevron.left") { turnPage(next: false) }
                    .disabled(page == 0).opacity(page == 0 ? 0.4 : 1)
                Spacer()
                VStack(spacing: 5) {
                    Text("\(page + 1) of \(pages.count)").font(Theme.body(12)).foregroundStyle(palette.muted)
                    HStack(spacing: 5) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Capsule().fill(index == page ? Theme.lilac : palette.surfaceBorder).frame(width: index == page ? 16 : 6, height: 6)
                        }
                    }
                }
                Spacer()
                IconButton(systemImage: "arrow.right") { turnPage(next: true) }
            }
            .padding(.horizontal, 20).padding(.top, 10)

            HStack {
                Text(app.genre.name)
                    .font(Theme.body(11, .semibold)).foregroundStyle(app.genre.accent)
                    .padding(.horizontal, 9).padding(.vertical, 6)
                    .background(app.genre.accent.opacity(0.15), in: RoundedRectangle(cornerRadius: 12))
                Button { commentsOpen = true } label: {
                    Label("\(12 + app.readerComments.filter(\.own).count)", systemImage: "bubble.left")
                        .font(Theme.body(12, .semibold)).foregroundStyle(palette.muted)
                }
                .buttonStyle(.plain)
                Spacer()
                Text(isLastPage ? (app.chapter >= app.length.chapters ? "Tap → to finish" : "Tap → to choose a pill") : "Swipe or tap to turn the page")
                    .font(Theme.body(11)).foregroundStyle(isLastPage ? Theme.lilac : palette.faint)
            }
            .padding(.horizontal, 20).padding(.vertical, 10)
        }
        .onChange(of: app.chapter) { page = 0 }
        .sheet(isPresented: $commentsOpen) {
            CommentsSheet(comments: $app.readerComments, chapter: app.chapter, genre: app.genre)
        }
    }

    private func turnPage(next: Bool) {
        if !next && page == 0 { return }
        if next && isLastPage { app.nextFromReading(); return }
        forward = next
        withAnimation(.easeInOut(duration: 0.3)) { page += next ? 1 : -1 }
    }
}

// MARK: - Pill selection

struct PillSelectionView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette
    @State private var selected: Genre?

    var body: some View {
        ScreenScroll {
            TopBar(title: "Shape the story", onBack: { app.go(.reading) })
            VStack(spacing: 12) {
                CapsuleIllustration(width: 70)
                Eyebrow(text: "The path is yours")
                GradientHeading(line1: "Where should your", line2: "story go next?", alignment: .center)
                Text("Pick a pill to guide the next chapter.").font(Theme.body(14)).foregroundStyle(palette.muted)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)

            VStack(spacing: 10) {
                ForEach(Genre.allCases) { genre in
                    let isSelected = selected == genre
                    Button { withAnimation(.easeOut(duration: 0.2)) { selected = genre } } label: {
                        HStack(spacing: 12) {
                            GenreSymbol(genre: genre, size: 45, circle: true)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(genre.name).font(Theme.heading(15, .bold)).foregroundStyle(palette.text)
                                Text(genre.detail).font(Theme.body(12)).foregroundStyle(palette.muted)
                            }
                            Spacer()
                            Circle()
                                .stroke(genre.accent.opacity(0.5), lineWidth: 1)
                                .frame(width: 20, height: 20)
                                .overlay(Circle().fill(genre.accent).frame(width: 10).shadow(color: genre.accent, radius: 5).opacity(isSelected ? 1 : 0))
                        }
                        .padding(.leading, 8).padding(.trailing, 14)
                        .frame(minHeight: 61)
                        .background(LinearGradient(colors: [genre.accent.opacity(0.14), palette.surface], startPoint: .leading, endPoint: .trailing), in: Capsule())
                        .overlay(Capsule().stroke(isSelected ? genre.accent : palette.surfaceBorder))
                        .shadow(color: genre.accent.opacity(isSelected ? 0.25 : 0), radius: 12, y: 8)
                        .offset(x: isSelected ? 3 : 0)
                    }
                    .buttonStyle(.plain)
                }
            }

            Button { if let selected { app.choosePill(selected) } } label: { PrimaryLabel(title: "Create next chapter", systemImage: "sparkles") }
                .buttonStyle(.primary)
                .disabled(selected == nil)
                .padding(.top, 20)
        }
    }
}

// MARK: - Generating

struct GeneratingView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette
    @State private var spin = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()
            ZStack {
                ForEach(0..<3) { ring in
                    Circle()
                        .stroke(app.genre.accent.opacity(0.25 - Double(ring) * 0.06), lineWidth: 1)
                        .frame(width: 150 + CGFloat(ring) * 50)
                        .rotationEffect(.degrees(spin ? 360 : 0))
                }
                CapsuleIllustration(left: app.genre.accent, right: Genre.romance.accent, width: 130)
            }
            .onAppear { withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) { spin = true } }

            VStack(spacing: 12) {
                Eyebrow(text: "Chapter \(app.chapter + 1)", systemImage: "sparkles")
                GradientHeading(line1: "Creating your", line2: "next chapter...", alignment: .center)
                (Text("Weaving in a touch of ") + Text(app.genre.name.lowercased()).bold() + Text(" and following the path you chose."))
                    .font(Theme.body(14)).foregroundStyle(palette.muted).multilineTextAlignment(.center)
                LoadingDots().padding(.top, 4)
            }
            Spacer()
            Label("Your choices make every story unique.", systemImage: "book")
                .font(Theme.body(13)).foregroundStyle(palette.muted)
                .padding(14).frame(maxWidth: .infinity).glassCard(cornerRadius: 16)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}

// MARK: - Ending

struct EndingView: View {
    @EnvironmentObject private var app: AppState
    @Environment(\.palette) private var palette
    @State private var commentsOpen = false

    var body: some View {
        ScreenScroll {
            VStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .font(.system(size: 28)).foregroundStyle(.white)
                    .frame(width: 70, height: 70)
                    .background(Theme.primaryGradient, in: Circle())
                    .shadow(color: Theme.violet.opacity(0.6), radius: 24)
                    .padding(.top, 40)
                Eyebrow(text: "Your story is complete")
                HStack(spacing: 10) {
                    Text("The").foregroundStyle(palette.text)
                    Text("End.").foregroundStyle(Theme.titleGradient)
                }
                .font(Theme.heading(44))
                Text("Every choice made this story yours.").font(Theme.body(14)).foregroundStyle(palette.muted)
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 22)

            VStack(spacing: 0) {
                StoryJourneyView(journey: app.journey, compact: true)
                Divider().overlay(palette.surfaceBorder).padding(.vertical, 12)
                Button { app.openJourney(back: .ending) } label: {
                    HStack {
                        Text("Explore your story journey").font(Theme.heading(13, .semibold))
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundStyle(palette.text)
                }
                .buttonStyle(.plain)
            }
            .padding(16)
            .glassCard()

            CommentsPeek(comments: app.readerComments) { commentsOpen = true }.padding(.top, 16)

            Button(action: app.restart) { PrimaryLabel(title: "Start a new story") }
                .buttonStyle(.primary).padding(.top, 20)
            Button("View in my library") { app.go(.library) }
                .font(Theme.body(14, .semibold)).foregroundStyle(Theme.lilac)
                .frame(maxWidth: .infinity).padding(.top, 14)
                .buttonStyle(.plain)
        }
        .sheet(isPresented: $commentsOpen) {
            CommentsSheet(comments: $app.readerComments, chapter: app.journey.count, genre: app.journey.last ?? .mystery)
        }
    }
}

// MARK: - Comments

struct CommentsPeek: View {
    @Environment(\.palette) private var palette
    let comments: [ReaderComment]
    let onViewAll: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("See What Readers Think").font(Theme.heading(13, .bold)).foregroundStyle(palette.text)
                Spacer()
                Button("View All Comments", action: onViewAll)
                    .font(Theme.body(12, .semibold)).foregroundStyle(Theme.lilac).buttonStyle(.plain)
            }
            ForEach(comments.filter { $0.parentId == nil }.prefix(2)) { comment in
                HStack(alignment: .top, spacing: 10) {
                    AvatarBadge(initials: comment.initials, size: 30)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(comment.name).font(Theme.body(12, .semibold)).foregroundStyle(palette.text)
                        Text(comment.text).font(Theme.body(12)).foregroundStyle(palette.muted).lineLimit(2)
                    }
                }
            }
        }
        .padding(14)
        .glassCard(cornerRadius: 18)
    }
}

struct CommentsSheet: View {
    @Environment(\.palette) private var palette
    @Environment(\.dismiss) private var dismiss
    @Binding var comments: [ReaderComment]
    let chapter: Int
    let genre: Genre
    var simple = false
    var onSend: (() -> Void)? = nil

    @State private var tab = "Newest"
    @State private var draft = ""
    @State private var spoiler = false
    @State private var replyTo: Int?

    private var roots: [ReaderComment] {
        comments.filter { $0.parentId == nil }
            .sorted { tab == "Top" ? $0.likes > $1.likes : $0.id > $1.id }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Eyebrow(text: "Reader comments")
                    GradientHeading(line1: "What Did You", line2: "Think?", size: 26)
                }
                Spacer()
                Button { dismiss() } label: { Image(systemName: "xmark") }
                    .foregroundStyle(palette.muted).buttonStyle(.plain)
            }
            .padding(.top, 24)

            if !simple {
                Picker("Sort", selection: $tab) {
                    Text("Newest").tag("Newest")
                    Text("Top").tag("Top")
                }
                .pickerStyle(.segmented)
                .padding(.top, 14)
            }

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 14) {
                    if roots.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "bubble.left.and.bubble.right").font(.system(size: 28))
                            Text("No comments yet. Be the first to share your thoughts!").font(Theme.body(14))
                        }
                        .foregroundStyle(palette.muted)
                        .frame(maxWidth: .infinity).padding(.top, 40)
                    }
                    ForEach(roots) { comment in
                        commentRow(comment, reply: false)
                        ForEach(comments.filter { $0.parentId == comment.id }) { reply in
                            commentRow(reply, reply: true).padding(.leading, 40)
                        }
                    }
                }
                .padding(.vertical, 16)
            }

            // Composer
            VStack(alignment: .leading, spacing: 8) {
                if let replyTo, let name = comments.first(where: { $0.id == replyTo })?.name {
                    HStack {
                        Text("Replying to \(name)").font(Theme.body(12)).foregroundStyle(palette.muted)
                        Button { self.replyTo = nil } label: { Image(systemName: "xmark.circle.fill") }
                            .buttonStyle(.plain).foregroundStyle(palette.faint)
                    }
                }
                if !simple {
                    Toggle("Contains Spoilers", isOn: $spoiler).font(Theme.body(12)).tint(Theme.violet)
                }
                HStack(spacing: 10) {
                    AvatarBadge(initials: "AM", size: 32)
                    TextField(replyTo == nil ? "Add a comment…" : "Write a reply…", text: $draft, axis: .vertical)
                        .lineLimit(1...4)
                        .font(Theme.body(14))
                        .onChange(of: draft) { _, value in if value.count > 300 { draft = String(value.prefix(300)) } }
                    Text("\(draft.count) / 300").font(Theme.body(10)).foregroundStyle(palette.faint)
                    Button(action: send) {
                        Image(systemName: "arrow.up").font(.system(size: 14, weight: .bold)).foregroundStyle(.white)
                            .frame(width: 34, height: 34).background(Theme.primaryGradient, in: Circle())
                    }
                    .buttonStyle(.plain)
                    .disabled(draft.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(draft.trimmingCharacters(in: .whitespaces).isEmpty ? 0.45 : 1)
                }
                .padding(10)
                .glassCard(cornerRadius: 18)
            }
            .padding(.bottom, 10)
        }
        .padding(.horizontal, 20)
        .background(AppBackground())
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func commentRow(_ comment: ReaderComment, reply: Bool) -> some View {
        HStack(alignment: .top, spacing: 10) {
            AvatarBadge(initials: comment.initials, size: reply ? 28 : 34)
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Text(comment.name).font(Theme.body(13, .semibold)).foregroundStyle(palette.text)
                    if !simple {
                        Text("Ch. \(comment.chapter) · \(comment.genre.name)")
                            .font(Theme.body(10, .semibold)).foregroundStyle(comment.genre.summaryAccent)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(comment.genre.summaryAccent.opacity(0.14), in: Capsule())
                    }
                    Text(comment.time).font(Theme.body(11)).foregroundStyle(palette.faint)
                    Spacer()
                    if !simple {
                        Menu {
                            Button("Report Comment", role: .none) {}
                            if comment.own { Button("Delete", role: .destructive) { remove(comment.id) } }
                        } label: { Image(systemName: "ellipsis").foregroundStyle(palette.faint).frame(width: 24, height: 24) }
                    }
                }
                if comment.spoiler && !comment.revealed {
                    Button { update(comment.id) { $0.revealed = true } } label: {
                        ZStack {
                            Text(comment.text).font(Theme.body(14)).blur(radius: 6)
                            Text("Tap to Reveal Spoiler").font(Theme.body(12, .bold)).foregroundStyle(Theme.lilac)
                        }
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(comment.text).font(Theme.body(14)).foregroundStyle(palette.text.opacity(0.9))
                }
                HStack(spacing: 16) {
                    Button { update(comment.id) { $0.likes += $0.liked ? -1 : 1; $0.liked.toggle() } } label: {
                        Label("\(comment.likes)", systemImage: comment.liked ? "heart.fill" : "heart")
                            .foregroundStyle(comment.liked ? Genre.romance.accent : palette.faint)
                    }
                    if !simple && !reply {
                        Button("Reply") { replyTo = comment.id }.foregroundStyle(palette.faint)
                    }
                }
                .font(Theme.body(12, .semibold))
                .buttonStyle(.plain)
            }
        }
    }

    private func update(_ id: Int, _ change: (inout ReaderComment) -> Void) {
        guard let index = comments.firstIndex(where: { $0.id == id }) else { return }
        change(&comments[index])
    }

    private func remove(_ id: Int) {
        comments.removeAll { $0.id == id || $0.parentId == id }
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        let new = ReaderComment(id: Int(Date().timeIntervalSince1970 * 1000), name: "Alex Morgan", initials: "AM", chapter: chapter, genre: genre, time: "Just now", text: text, likes: 0, spoiler: spoiler, own: true, parentId: replyTo)
        withAnimation { comments.insert(new, at: 0) }
        draft = ""
        spoiler = false
        replyTo = nil
        tab = "Newest"
        onSend?()
    }
}
